#!/usr/bin/env python3
"""Archive receipts from email messages or direct receipt files.

Input may be PDF/PNG/HTML files supplied as arguments, or newline/NUL-delimited
email paths from ``notmuch search --output=files`` on stdin. Receipt artifacts
are stored under RECEIPTS_DIR/YYYY/MM. Filename fields such as p=, a=, d=,
f=, t=, and tags= can be used to create GNU Ledger entries.

When --backup is used, only directly supplied receipt files are deleted, and
only after the archive and backup copies have matching SHA-256 hashes and any
requested ledger update has been flushed successfully. Email/Maildir sources
are never deleted.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import sys
import tempfile
from dataclasses import dataclass, replace
from datetime import datetime
from email import policy
from email.message import Message
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
from pathlib import Path
from typing import Iterable, Iterator, Sequence, TextIO


DIRECT_SUFFIXES = {".pdf", ".png", ".html", ".htm", ".jpg", ".jpeg"}


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def safe_component(value: str, default: str, limit: int = 100) -> str:
    value = re.sub(r"[\x00-\x1f\x7f/\\]+", "_", value)
    value = re.sub(r"[^\w.,+'()=@ $-]+", "_", value, flags=re.UNICODE)
    value = re.sub(r"[\s_]+", "_", value).strip("._- ")
    return (value or default)[:limit].rstrip("._- ")


def normalize_date(value: str) -> str:
    value = value.replace("/", "-").replace(".", "-")
    try:
        return datetime.strptime(value, "%Y-%m-%d").strftime("%Y-%m-%d")
    except ValueError as exc:
        raise ValueError(f"invalid date {value!r}; expected YYYY-MM-DD") from exc


def email_date(message: Message) -> str:
    try:
        return parsedate_to_datetime(message.get("Date", "")).strftime("%Y-%m-%d")
    except (TypeError, ValueError, OverflowError):
        return datetime.now().strftime("%Y-%m-%d")


def decoded_payload(part: Message) -> bytes:
    payload = part.get_payload(decode=True)
    if payload is not None:
        return payload
    value = part.get_payload()
    if isinstance(value, str):
        return value.encode(part.get_content_charset() or "utf-8", errors="replace")
    return b""


@dataclass(frozen=True)
class Metadata:
    date: str
    payee: str | None = None
    amount: str | None = None
    from_account: str = ""
    to_account: str = ""
    tags: tuple[str, ...] = ()

    @property
    def ledger_ready(self) -> bool:
        return bool(
            self.payee and self.amount and self.from_account and self.to_account
        )

    def missing_ledger_fields(self) -> tuple[str, ...]:
        values = {
            "payee (p= or --payee)": self.payee,
            "amount (a= or --amount)": self.amount,
            "from account (f= or --from)": self.from_account,
            "to account (t= or --to)": self.to_account,
        }
        return tuple(label for label, value in values.items() if not value)


@dataclass(frozen=True)
class Receipt:
    data: bytes
    filename: str
    metadata: Metadata
    kind: str


@dataclass(frozen=True)
class ArchivedReceipt:
    receipt: Receipt
    path: Path
    digest: str


@dataclass(frozen=True)
class ProcessedInput:
    source: Path
    receipts: tuple[Receipt, ...]
    direct: bool


def field(filename: str, names: str) -> str | None:
    # Fields are separated by underscores. The extension terminates the last one.
    pattern = rf"(?:^|_)(?:{names})=([^_]+?)(?=_(?:[A-Za-z]+)=|\.[^.]+$|$)"
    match = re.search(pattern, Path(filename).name, re.IGNORECASE)
    return match.group(1).strip() if match else None


def metadata_from_name(filename: str, defaults: Metadata) -> Metadata:
    basename = Path(filename).name
    date_match = re.search(r"^(\d{4}[-./]\d{2}[-./]\d{2})", basename)
    named_date = field(basename, r"D|Date")
    date = normalize_date((date_match.group(1) if date_match else named_date) or defaults.date)
    amount = field(basename, r"A|Amt|Amount|Ammout")
    if amount:
        amount = amount.lstrip("$")
        if not re.fullmatch(r"\d+(?:\.\d{1,2})?", amount):
            raise ValueError(f"invalid amount {amount!r} in {basename}")
    tags_value = field(basename, r"tags")
    return Metadata(
        date=date,
        payee=field(basename, r"P|Payee") or defaults.payee,
        amount=amount or defaults.amount,
        from_account=field(basename, r"F|From") or defaults.from_account,
        to_account=field(basename, r"T|To") or defaults.to_account,
        tags=tuple(x.strip() for x in tags_value.split(",") if x.strip())
        if tags_value
        else defaults.tags,
    )


class PartHandler:
    """Extension point for converting one MIME leaf into a receipt."""

    def extract(self, part: Message, defaults: Metadata, stem: str) -> Receipt | None:
        raise NotImplementedError


class AttachmentHandler(PartHandler):
    MIME_SUFFIXES = {
        "application/pdf": ".pdf",
        "image/png": ".png",
        "image/jpeg": ".jpg",
        "text/html": ".html",
    }

    def extract(self, part: Message, defaults: Metadata, stem: str) -> Receipt | None:
        original = part.get_filename()
        if not original and part.get_content_disposition() != "attachment":
            return None
        suffix = Path(original or "").suffix.lower()
        if not suffix:
            suffix = self.MIME_SUFFIXES.get(part.get_content_type(), ".bin")
        if suffix == ".htm":
            suffix = ".html"
        label = safe_component(Path(original).stem, "attachment") if original else "attachment"
        filename = f"{stem}_{label}{suffix}"
        metadata = metadata_from_name(original or filename, defaults)
        return Receipt(decoded_payload(part), filename, metadata, "attachment")


class HtmlBodyHandler(PartHandler):
    def extract(self, part: Message, defaults: Metadata, stem: str) -> Receipt | None:
        if part.get_content_type() != "text/html" or part.get_filename():
            return None
        return Receipt(decoded_payload(part), f"{stem}_body.html", defaults, "html-body")


class PlainTextBodyHandler(PartHandler):
    def extract(self, part: Message, defaults: Metadata, stem: str) -> Receipt | None:
        if part.get_content_type() != "text/plain" or part.get_filename():
            return None
        return Receipt(decoded_payload(part), f"{stem}_body.txt", defaults, "text-body")


def leaf_parts(message: Message) -> Iterator[Message]:
    for part in message.walk():
        if not part.is_multipart():
            yield part


class EmailProcessor:
    def __init__(self, include_text: bool = False) -> None:
        self.attachment_handlers: list[PartHandler] = [AttachmentHandler()]
        self.body_handlers: list[PartHandler] = [HtmlBodyHandler()]
        if include_text:
            self.body_handlers.append(PlainTextBodyHandler())
        self.seen: set[str] = set()

    @staticmethod
    def collect(
        parts: Iterable[Message], handlers: Sequence[PartHandler], defaults: Metadata, stem: str
    ) -> list[Receipt]:
        receipts = []
        for part in parts:
            for handler in handlers:
                receipt = handler.extract(part, defaults, stem)
                if receipt is not None:
                    receipts.append(receipt)
                    break
        return receipts

    def process(self, source: Path, cli_defaults: Metadata) -> ProcessedInput | None:
        raw = source.read_bytes()
        message = BytesParser(policy=policy.default).parsebytes(raw)
        identity = str(message.get("Message-ID", "")).strip().lower() or sha256_bytes(raw)
        if identity in self.seen:
            return None
        self.seen.add(identity)
        date = email_date(message)
        defaults = replace(cli_defaults, date=date)
        sender = str(message.get("From", "unknown")).split("<", 1)[0].strip(' "')
        subject = str(message.get("Subject", "receipt"))
        stem = "_".join(
            (date, safe_component(sender, "unknown", 40), safe_component(subject, "receipt", 100))
        )
        parts = list(leaf_parts(message))
        receipts = self.collect(parts, self.attachment_handlers, defaults, stem)
        if not receipts:
            receipts = self.collect(parts, self.body_handlers, defaults, stem)
        return ProcessedInput(source, tuple(receipts), direct=False)


def process_direct(source: Path, defaults: Metadata) -> ProcessedInput:
    suffix = source.suffix.lower()
    if suffix not in DIRECT_SUFFIXES:
        raise ValueError(f"unsupported direct receipt type: {suffix or '(none)'}")
    normalized_suffix = ".html" if suffix == ".htm" else suffix
    metadata = metadata_from_name(source.name, defaults)
    filename = safe_component(source.stem, "receipt", 180) + normalized_suffix
    return ProcessedInput(
        source, (Receipt(source.read_bytes(), filename, metadata, "direct-file"),), direct=True
    )


class ArchiveStore:
    def __init__(self, root: Path, overwrite: bool = False) -> None:
        self.root = root
        self.overwrite = overwrite

    def store(self, receipt: Receipt) -> ArchivedReceipt:
        year, month = receipt.metadata.date.split("-", 2)[:2]
        directory = self.root / year / month
        directory.mkdir(parents=True, exist_ok=True)
        candidate = directory / receipt.filename
        digest = sha256_bytes(receipt.data)
        if candidate.exists() and sha256_file(candidate) == digest:
            return ArchivedReceipt(receipt, candidate, digest)
        if candidate.exists() and not self.overwrite:
            counter = 2
            while candidate.exists():
                candidate = directory / f"{Path(receipt.filename).stem}_{counter}{Path(receipt.filename).suffix}"
                if candidate.exists() and sha256_file(candidate) == digest:
                    return ArchivedReceipt(receipt, candidate, digest)
                counter += 1
        fd, temporary = tempfile.mkstemp(prefix=".receipt-", dir=directory)
        try:
            with os.fdopen(fd, "wb") as stream:
                stream.write(receipt.data)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, candidate)
        except BaseException:
            Path(temporary).unlink(missing_ok=True)
            raise
        if sha256_file(candidate) != digest:
            raise OSError(f"archive verification failed: {candidate}")
        return ArchivedReceipt(receipt, candidate, digest)


def backup_and_verify(archived: ArchivedReceipt, receipts_root: Path, backup_root: Path) -> Path:
    if not backup_root.is_dir():
        raise ValueError(f"backup directory does not exist: {backup_root}")
    relative = archived.path.relative_to(receipts_root)
    destination = backup_root / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    if not destination.exists() or sha256_file(destination) != archived.digest:
        temporary = destination.with_name(f".{destination.name}.tmp-{os.getpid()}")
        shutil.copyfile(archived.path, temporary)
        if sha256_file(temporary) != archived.digest:
            temporary.unlink(missing_ok=True)
            raise OSError(f"backup verification failed: {destination}")
        os.replace(temporary, destination)
    if sha256_file(destination) != archived.digest:
        raise OSError(f"backup verification failed: {destination}")
    return destination


def ledger_entry(archived: ArchivedReceipt) -> str | None:
    metadata = archived.receipt.metadata
    if not metadata.ledger_ready:
        return None
    entry = f"{metadata.date.replace('-', '/')} {metadata.payee}\n"
    entry += f"    {metadata.from_account}   ${metadata.amount}\n"
    entry += f"    {metadata.to_account}\n"
    if metadata.tags:
        entry += f"    ; tags:{','.join(metadata.tags)}\n"
    entry += f"    ; receipt: {archived.path.resolve().as_uri()}\n"
    return entry


def append_ledger(path: Path, archived: Sequence[ArchivedReceipt], verbose: bool) -> int:
    entries = [(item, ledger_entry(item)) for item in archived]
    entries = [(item, entry) for item, entry in entries if entry]
    if not entries:
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = path.read_text(errors="replace") if path.exists() else ""
    pending = []
    for item, entry in entries:
        assert entry is not None
        uri = item.path.resolve().as_uri()
        if uri in existing:
            if verbose:
                print(f"ledger already contains: {uri}", file=sys.stderr)
            continue
        pending.append(entry)
    if not pending:
        return 0
    with path.open("a", encoding="utf-8") as stream:
        for entry in pending:
            stream.write("\n" + entry + "\n")
        stream.flush()
        os.fsync(stream.fileno())
    return len(pending)


def input_paths(arguments: Sequence[str], legacy_filename: str | None, stream: TextIO) -> Iterator[Path]:
    values = list(arguments)
    if legacy_filename:
        values.append(legacy_filename)
    if values:
        for value in values:
            yield Path(value).expanduser()
        return
    data = stream.buffer.read() if hasattr(stream, "buffer") else stream.read()
    if isinstance(data, str):
        data = data.encode()
    separator = b"\0" if b"\0" in data else b"\n"
    for value in data.split(separator):
        if value.strip():
            yield Path(value.strip().decode(errors="surrogateescape")).expanduser()


def build_parser() -> argparse.ArgumentParser:
    env_receipts = os.environ.get("RECEIPTS_DIR") or os.environ.get("RECEIPTS_DIRECTORY")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="Email or receipt files; default: stdin")
    parser.add_argument("--filename", help="Legacy alias for one input file")
    parser.add_argument(
        "--receipts-dir", type=Path, default=Path(env_receipts).expanduser() if env_receipts else None,
        help="Receipt archive root (or RECEIPTS_DIR/RECEIPTS_DIRECTORY)",
    )
    parser.add_argument(
        "--ledger-file", type=Path,
        default=Path(os.environ["LEDGER_FILE"]).expanduser() if os.environ.get("LEDGER_FILE") else None,
        help="GNU Ledger file to update (or LEDGER_FILE)",
    )
    parser.add_argument("--backup", type=Path, help="Existing backup root; verified copies permit direct-source deletion")
    parser.add_argument("--from", dest="from_account", default="", help="First ledger account")
    parser.add_argument("--to", dest="to_account", default="", help="Balancing ledger account")
    parser.add_argument("--date", default=datetime.now().strftime("%Y-%m-%d"))
    parser.add_argument("--payee")
    parser.add_argument("--amount")
    parser.add_argument("--tag", action="append", default=[], help="Ledger tag; may be repeated")
    parser.add_argument("--include-text", action="store_true", help="Use plain-text email body as last resort")
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--strict", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.receipts_dir is None:
        print("error: --receipts-dir is required (or set RECEIPTS_DIR)", file=sys.stderr)
        return 2
    receipts_root = args.receipts_dir.expanduser().resolve()
    backup_root = args.backup.expanduser().resolve() if args.backup else None
    if backup_root and not backup_root.is_dir():
        print(f"error: backup directory does not exist: {backup_root}", file=sys.stderr)
        return 2
    defaults = Metadata(
        normalize_date(args.date), args.payee, args.amount, args.from_account,
        args.to_account, tuple(args.tag),
    )
    store = ArchiveStore(receipts_root, args.overwrite)
    email_processor = EmailProcessor(args.include_text)
    processed = saved = skipped = errors = ledger_count = deleted = 0
    for source in input_paths(args.files, args.filename, sys.stdin):
        processed += 1
        source = source.resolve()
        if args.verbose:
            print(f"processing: {source}", file=sys.stderr)
        try:
            direct = source.suffix.lower() in DIRECT_SUFFIXES
            item = process_direct(source, defaults) if direct else email_processor.process(source, defaults)
            if item is None:
                skipped += 1
                print(f"skip: {source}: duplicate email", file=sys.stderr)
                continue
            if not item.receipts:
                skipped += 1
                print(f"skip: {source}: no receipt attachment or supported body", file=sys.stderr)
                continue
            if item.direct and args.ledger_file:
                incomplete = [
                    receipt.metadata.missing_ledger_fields()
                    for receipt in item.receipts
                    if not receipt.metadata.ledger_ready
                ]
                if incomplete:
                    raise ValueError(
                        "ledger entry incomplete; missing " + ", ".join(incomplete[0])
                    )
            archived = [store.store(receipt) for receipt in item.receipts]
            for result in archived:
                saved += 1
                print(result.path)
                if args.verbose:
                    print(f"archived+verified sha256={result.digest}: {result.path}", file=sys.stderr)
            if backup_root:
                for result in archived:
                    destination = backup_and_verify(result, receipts_root, backup_root)
                    if args.verbose:
                        print(f"backup+verified sha256={result.digest}: {destination}", file=sys.stderr)
            if args.ledger_file:
                count = append_ledger(args.ledger_file.expanduser(), archived, args.verbose)
                ledger_count += count
                if args.verbose and count:
                    print(f"ledger appended ({count}): {args.ledger_file.expanduser()}", file=sys.stderr)
            elif args.verbose and any(result.receipt.metadata.ledger_ready for result in archived):
                print("ledger metadata found, but no --ledger-file/LEDGER_FILE was supplied", file=sys.stderr)
            if backup_root and item.direct:
                # --backup explicitly authorizes deletion, but never for Maildir/email inputs.
                if source == receipts_root or receipts_root in source.parents:
                    raise ValueError(f"refusing to delete a source inside receipts directory: {source}")
                source.unlink()
                deleted += 1
                if args.verbose:
                    print(f"deleted verified direct source: {source}", file=sys.stderr)
        except (OSError, ValueError) as exc:
            errors += 1
            print(f"error: {source}: {exc}", file=sys.stderr)
    print(
        f"processed={processed} saved={saved} ledger={ledger_count} "
        f"deleted={deleted} skipped={skipped} errors={errors}", file=sys.stderr,
    )
    return 1 if errors or (args.strict and skipped) else 0


if __name__ == "__main__":
    raise SystemExit(main())
