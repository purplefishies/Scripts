#!/usr/bin/env python3
"""Extract receipt files from paths emitted by notmuch search --output=files.

The MIME handlers are intentionally separate from message traversal and output
naming. To support another format, add a PartHandler and register it in
default_handlers().
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from email import policy
from email.message import Message
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
from pathlib import Path
from typing import Iterable, Iterator, Sequence, TextIO


def safe_component(value: str, default: str, limit: int = 80) -> str:
    value = re.sub(r"[\x00-\x1f\x7f/\\]+", "_", value)
    value = re.sub(r"[^\w.,+()=@ -]+", "_", value, flags=re.UNICODE)
    value = re.sub(r"[\s_]+", "_", value).strip("._- ")
    return (value or default)[:limit].rstrip("._- ")


def message_date(message: Message) -> str:
    try:
        return parsedate_to_datetime(message.get("Date", "")).strftime("%Y-%m-%d")
    except (TypeError, ValueError, OverflowError):
        return datetime.now().strftime("%Y-%m-%d")


def dated_stem(message: Message) -> str:
    date = message_date(message)
    sender = str(message.get("From", "unknown")).split("<", 1)[0].strip(' "')
    subject = str(message.get("Subject", "receipt"))
    return "_".join(
        (
            date,
            safe_component(sender, "unknown", 40),
            safe_component(subject, "receipt", 100),
        )
    )


def decoded_payload(part: Message) -> bytes:
    payload = part.get_payload(decode=True)
    if payload is not None:
        return payload
    value = part.get_payload()
    if isinstance(value, str):
        return value.encode(part.get_content_charset() or "utf-8", errors="replace")
    return b""


@dataclass(frozen=True)
class Artifact:
    data: bytes
    suffix: str
    label: str
    kind: str


class PartHandler:
    """Extension point for converting one MIME part into an artifact."""

    def extract(self, part: Message) -> Artifact | None:
        raise NotImplementedError


class AttachmentHandler(PartHandler):
    """Handle PDF, PNG, and HTML attachments."""

    MIME_SUFFIXES = {
        "application/pdf": ".pdf",
        "image/png": ".png",
        "text/html": ".html",
    }
    ALLOWED_SUFFIXES = {".pdf", ".png", ".html", ".htm"}

    def extract(self, part: Message) -> Artifact | None:
        filename = part.get_filename()
        if not filename and part.get_content_disposition() != "attachment":
            return None
        named_suffix = Path(filename or "").suffix.lower()
        suffix = (
            named_suffix
            if named_suffix in self.ALLOWED_SUFFIXES
            else self.MIME_SUFFIXES.get(part.get_content_type())
        )
        if not suffix:
            return None
        suffix = ".html" if suffix == ".htm" else suffix
        label = safe_component(Path(filename).stem, "attachment") if filename else "attachment"
        return Artifact(decoded_payload(part), suffix, label, "attachment")


class HtmlBodyHandler(PartHandler):
    def extract(self, part: Message) -> Artifact | None:
        if part.get_content_type() == "text/html" and not part.get_filename():
            return Artifact(decoded_payload(part), ".html", "body", "html-body")
        return None


class PlainTextBodyHandler(PartHandler):
    def extract(self, part: Message) -> Artifact | None:
        if part.get_content_type() == "text/plain" and not part.get_filename():
            return Artifact(decoded_payload(part), ".txt", "body", "text-body")
        return None


class OutputStore:
    def __init__(self, directory: Path, overwrite: bool = False) -> None:
        self.directory = directory
        self.overwrite = overwrite

    def save(
        self, date: str, stem: str, artifact: Artifact, index: int
    ) -> Path:
        year, month = date.split("-", 2)[:2]
        destination = self.directory / year / month
        destination.mkdir(parents=True, exist_ok=True)
        base = f"{stem}_{index:02d}_{artifact.label}"
        path = destination / f"{base}{artifact.suffix}"
        if not self.overwrite:
            counter = 2
            while path.exists():
                path = destination / f"{base}_{counter}{artifact.suffix}"
                counter += 1
        path.write_bytes(artifact.data)
        return path


def leaf_parts(message: Message) -> Iterator[Message]:
    for part in message.walk():
        if not part.is_multipart():
            yield part


class ReceiptExtractor:
    def __init__(
        self,
        store: OutputStore,
        attachment_handlers: Sequence[PartHandler],
        body_handlers: Sequence[PartHandler],
    ) -> None:
        self.store = store
        self.attachment_handlers = attachment_handlers
        self.body_handlers = body_handlers
        self.seen: set[str] = set()

    @staticmethod
    def collect(
        parts: Iterable[Message], handlers: Sequence[PartHandler]
    ) -> list[Artifact]:
        artifacts = []
        for part in parts:
            for handler in handlers:
                artifact = handler.extract(part)
                if artifact is not None:
                    artifacts.append(artifact)
                    break
        return artifacts

    def extract_file(self, source: Path) -> tuple[list[Path], str | None]:
        raw = source.read_bytes()
        message = BytesParser(policy=policy.default).parsebytes(raw)
        identity = (
            str(message.get("Message-ID", "")).strip().lower()
            or hashlib.sha256(raw).hexdigest()
        )
        if identity in self.seen:
            return [], "duplicate"
        self.seen.add(identity)

        parts = list(leaf_parts(message))
        artifacts = self.collect(parts, self.attachment_handlers)
        if not artifacts:
            artifacts = self.collect(parts, self.body_handlers)
        if not artifacts:
            return [], "no supported receipt content"

        date = message_date(message)
        stem = dated_stem(message)
        return [
            self.store.save(date, stem, artifact, index)
            for index, artifact in enumerate(artifacts, 1)
        ], None


def input_paths(arguments: Sequence[str], stream: TextIO) -> Iterator[Path]:
    """Read path arguments or newline/NUL-delimited paths from stdin."""
    if arguments:
        for value in arguments:
            yield Path(value).expanduser()
        return
    data = stream.buffer.read() if hasattr(stream, "buffer") else stream.read()
    if isinstance(data, str):
        data = data.encode()
    separator = b"\0" if b"\0" in data else b"\n"
    for value in data.split(separator):
        if value.strip():
            yield Path(value.strip().decode(errors="surrogateescape")).expanduser()


def default_handlers(
    include_text: bool,
) -> tuple[list[PartHandler], list[PartHandler]]:
    body_handlers: list[PartHandler] = [HtmlBodyHandler()]
    if include_text:
        body_handlers.append(PlainTextBodyHandler())
    return [AttachmentHandler()], body_handlers


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description="Extract PDF, PNG, or HTML receipts from email files."
    )
    result.add_argument("files", nargs="*", help="Email paths (default: stdin)")
    result.add_argument("-o", "--output-dir", required=True, type=Path)
    result.add_argument(
        "--include-text",
        action="store_true",
        help="Use a plain-text body when no attachment or HTML body exists",
    )
    result.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Describe each message and receipt as it is processed",
    )
    result.add_argument("--overwrite", action="store_true")
    result.add_argument(
        "--strict",
        action="store_true",
        help="Fail when a message is duplicated or has no supported content",
    )
    return result


def main(argv: Sequence[str] | None = None) -> int:
    args = parser().parse_args(argv)
    attachment_handlers, body_handlers = default_handlers(args.include_text)
    extractor = ReceiptExtractor(
        OutputStore(args.output_dir.expanduser(), args.overwrite),
        attachment_handlers,
        body_handlers,
    )
    processed = saved = skipped = errors = 0
    for source in input_paths(args.files, sys.stdin):
        processed += 1
        if args.verbose:
            print(f"processing: {source}", file=sys.stderr)
        try:
            paths, reason = extractor.extract_file(source)
            if reason:
                skipped += 1
                print(f"skip: {source}: {reason}", file=sys.stderr)
            for path in paths:
                saved += 1
                print(path)
                if args.verbose:
                    print(f"saved: {path}", file=sys.stderr)
        except (OSError, ValueError) as exc:
            errors += 1
            print(f"error: {source}: {exc}", file=sys.stderr)
    print(
        f"processed={processed} saved={saved} skipped={skipped} errors={errors}",
        file=sys.stderr,
    )
    return 1 if errors or (args.strict and skipped) else 0


if __name__ == "__main__":
    raise SystemExit(main())
