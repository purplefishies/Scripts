#!/usr/bin/env python3
from PIL import Image
import argparse
import sys

ASCII_CHARS = "@%#*+=-:. "

def convert_to_ascii(image_path, width):
    try:
        img = Image.open(image_path)
    except FileNotFoundError:
        print(f"❌ File not found: {image_path}")
        sys.exit(1)

    img = img.convert("L")  # grayscale

    # maintain aspect ratio
    aspect_ratio = img.height / img.width
    height = int(width * aspect_ratio * 0.5)
    img = img.resize((width, height))

    pixels = img.getdata()
    ascii_str = "".join(ASCII_CHARS[p // 25] for p in pixels)

    ascii_img = "\n".join(
        ascii_str[i:i + width]
        for i in range(0, len(ascii_str), width)
    )
    return ascii_img


def main():
    parser = argparse.ArgumentParser(
        description="Convert an image to ASCII art."
    )
    parser.add_argument("image", help="Path to image file (.png / .jpg / etc.)")
    parser.add_argument(
        "-w", "--width",
        type=int,
        default=120,
        help="Output width (default: 120 characters)"
    )

    args = parser.parse_args()

    ascii_art = convert_to_ascii(args.image, args.width)
    print(ascii_art)


if __name__ == "__main__":
    main()

