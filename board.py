import chess
import sys
import os

# Unicode characters for chess pieces
UNICODE_PIECES = {
    'P': '♙', 'R': '♖', 'N': '♘', 'B': '♗', 'Q': '♕', 'K': '♔',
    'p': '♟', 'r': '♜', 'n': '♞', 'b': '♝', 'q': '♛', 'k': '♚'
}

# ANSI escape codes for background colors
WHITE_SQUARE = "\033[47m"  # White background
BLACK_SQUARE = "\033[40m"  # Black background
GREEN_SQUARE = "\033[102m" # Light green background (for "black" squares)
WHITE_TEXT = "\033[97m"    # White text (for white pieces)
BLACK_TEXT = "\033[30m"    # Black text (for black pieces)
RESET_COLOR = "\033[0m"    # Reset to default terminal color


def pretty_print_board(fen: str):
    # Create a chess board object from the FEN
    board = chess.Board(fen)

    # Iterate through ranks (1 to 8) from bottom to top
    for rank in range(8, 0, -1):
        line = ""
        for file in range(8):
            piece = board.piece_at(chess.square(file, rank - 1))
            # Alternate background color: if (rank + file) is even, it's white square
            if (rank + file) % 2 == 0:
                square_color = WHITE_SQUARE
            else:
                square_color = GREEN_SQUARE
            
            # Determine if the piece is white or black and choose text color accordingly
            if piece:
                if piece.color == chess.WHITE:
                    text_color = WHITE_TEXT  # White pieces (light foreground)
                else:
                    text_color = BLACK_TEXT  # Black pieces (dark foreground)
                symbol = UNICODE_PIECES[piece.symbol()]
            else:
                text_color = ""  # No text color for empty squares
                symbol = " "  # Empty square

            # Add the piece with the correct background and text color
            line += square_color + text_color + " " + symbol + " " + RESET_COLOR

            # # Get the piece's unicode symbol or space for empty squares
            # symbol = UNICODE_PIECES[piece.symbol()] if piece else " "
            
            # # Add the piece with the correct background color
            # line += square_color + " " + symbol + " " + RESET_COLOR
        
        # print each rank's pieces with colored squares
        print(line)
    print()  # Empty line for better formatting

def read_fen_input(input_value: str):
    # Check if the input is a valid file
    if os.path.isfile(input_value):
        with open(input_value, 'r') as f:
            return f.readline().strip()  # Read the first line as FEN
    else:
        return input_value  # Assume the input is a FEN string

if __name__ == "__main__":
    # Check if the user provided an argument (file or FEN string)
    if len(sys.argv) != 2:
        print("Usage: python chess_pretty_print.py <fen_string_or_filename>")
        sys.exit(1)
    
    # Get the FEN string or read from the file
    input_value = sys.argv[1]
    fen = read_fen_input(input_value)
    
    # Print the chessboard with alternating colors
    pretty_print_board(fen)

