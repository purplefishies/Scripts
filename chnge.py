import fitz  # PyMuPDF
import sys

def change_highlight_color(pdf_path, output_path, new_color):
    doc = fitz.open(pdf_path)
    for page in doc:
        highlights = page.search_for("highlighted text")
        for highlight in highlights:
            annot = page.add_highlight_annot(highlight)
            annot.set_colors(stroke=new_color)
            annot.update()
    doc.save(output_path)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 chngcolor.py <input_pdf> <output_pdf>")
        sys.exit(1)

    input_pdf = sys.argv[1]
    output_pdf = sys.argv[2]


    new_color = [128 / 255, 255 / 255, 0 / 255]
    change_highlight_color(input_pdf, output_pdf, new_color)

