#!/usr/bin/env python3

import argparse
import subprocess
import sys

def evaluate_command(cmd):
    """Run the command and return its output as a list of colors."""
    try:
        result = subprocess.check_output(cmd, shell=True, text=True).strip()
        return [color for color in result.split() if color]  # Filter out empty entries
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}\n{e}")
        return []

def colorize_string(input_string, fg_colors, bg_colors):
    """Colorize each character in the input string with fg and bg colors."""
    length = len(input_string)
    fg_length = len(fg_colors)
    bg_length = len(bg_colors)
    
    output = []
    
    for i, char in enumerate(input_string):
        fg = fg_colors[i % fg_length] if fg_colors else None
        bg = bg_colors[i % bg_length] if bg_colors else None
        
        if fg and bg:
            output.append(f"#[fg={fg},bg={bg}]{char}")
        elif fg:
            output.append(f"#[fg={fg}]{char}")
        elif bg:
            output.append(f"#[bg={bg}]{char}")
        else:
            output.append(char)
    
    return ''.join(output)

def main():
    # Set up argparse for command-line options
    parser = argparse.ArgumentParser(description="Colorize a string for tmux.")
    parser.add_argument("-fg", help="Foreground color generation command", default="")
    parser.add_argument("-bg", help="Background color generation command", default="")
    
    args = parser.parse_args()

    # Evaluate the commands for fg and bg
    fg_colors = evaluate_command(args.fg) if args.fg else []
    bg_colors = evaluate_command(args.bg) if args.bg else []

    # Read the string from stdin
    input_string = sys.stdin.read().strip()

    # Colorize the string
    colorized_string = colorize_string(input_string, fg_colors, bg_colors)

    # Output the colorized string
    print(colorized_string)

if __name__ == "__main__":
    main()
