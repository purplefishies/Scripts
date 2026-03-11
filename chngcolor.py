import fitz  # PyMuPDF
import sys

def change_highlight_color_to_chartreuse(pdf_path, output_path):
    try:
        # Open the PDF file using fitz.open()
        pdf_document = fitz.open(pdf_path)

        # Chartreuse RGB color (128, 255, 0) normalized to 0-1 range
        chartreuse_color = [128 / 255, 255 / 255, 0 / 255]

        # Iterate through each page
        for page_num in range(pdf_document.page_count):
            page = pdf_document.load_page(page_num)

            # Get all annotations on the page
            annotations = page.annots()

            if annotations:
                for annot in annotations:
                    # Check if the annotation is a highlight
                    if annot.type[0] == 8:  # 8 corresponds to highlight annotation
                        print(f"Changing color of highlight on page {page_num + 1}")
                        # Set the new color to chartreuse
                        annot.set_colors(stroke=chartreuse_color)
                        annot.update()

        # Save the modified PDF to the output path
        pdf_document.save(output_path)
        pdf_document.close()

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Check that the script receives exactly 2 arguments: input and output file paths
    if len(sys.argv) != 3:
        print("Usage: python3 chngcolor.py <input_pdf> <output_pdf>")
        sys.exit(1)

    input_pdf = sys.argv[1]
    output_pdf = sys.argv[2]

    change_highlight_color_to_chartreuse(input_pdf, output_pdf)
    print(f"Saved the modified PDF to {output_pdf}")

