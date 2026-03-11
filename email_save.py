#!/usr/bin/env python


import os
import argparse
import email
from email import policy
from email.parser import BytesParser

def extract_email_body_and_attachments(eml_file_path, output_dir, suffix):
    # Parse the .eml file
    with open(eml_file_path, 'rb') as eml_file:
        msg = BytesParser(policy=policy.default).parse(eml_file)

    # Get the subject line and clean it to create a valid filename
    subject = msg['subject']
    if subject is None:
        subject = 'no_subject'
    # Remove any illegal characters from the filename
    valid_filename = ''.join(c if c.isalnum() or c in ' ._-' else '_' for c in subject)

    # Add suffix to the filename
    output_filename = f"{valid_filename}_{suffix}.txt"
    
    # Combine output directory and filename
    output_file_path = os.path.join(output_dir, output_filename)
    
    # Get the body of the email
    body = ""
    if msg.is_multipart():
        # If the message is multipart, iterate through parts
        for part in msg.iter_parts():
            # Get the content type and filename of each part
            content_type = part.get_content_type()
            filename = part.get_filename()
            
            if content_type == 'text/plain' and not filename:
                # If the part is plain text and doesn't have a filename, it's the body
                body = part.get_content()
            elif filename:
                # If the part has a filename, it's an attachment
                attachment_filename = f"{eml_file_path}{suffix}{filename}"
                attachment_path = os.path.join(output_dir, attachment_filename)
                # Save the attachment
                with open(attachment_path, 'wb') as attachment_file:
                    attachment_file.write(part.get_payload(decode=True))
                print(f"Attachment saved to '{attachment_path}'.")
    else:
        # If the message is not multipart, get the payload directly
        body = msg.get_payload()

    # Write the body content to the output file
    with open(output_file_path, 'w') as output_file:
        output_file.write(body)
    
    print(f"Body of the email saved to '{output_file_path}'.")

def main():
    # Set up the argument parser
    parser = argparse.ArgumentParser(description="Extract the body of an email from an .eml file, save it as a text file, and save attachments in the specified directory.")
    
    # Define the named arguments
    parser.add_argument("--eml_file", required=True, help="Path to the .eml file")
    parser.add_argument("--output_directory", required=True, help="Output directory to save the .txt file and attachments")
    parser.add_argument("--suffix", required=True, help="Suffix for the output file and attachment names")
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Extract the email body and attachments
    extract_email_body_and_attachments(args.eml_file, args.output_directory, args.suffix)

if __name__ == "__main__":
    main()

# import os
# import argparse
# import email
# from email import policy
# from email.parser import BytesParser
# def extract_email_body_to_txt(eml_file_path, output_dir, suffix):
#     # Parse the .eml file
#     with open(eml_file_path, 'rb') as eml_file:
#         msg = BytesParser(policy=policy.default).parse(eml_file)
#     # Get the subject line and clean it to create a valid filename
#     subject = msg['subject']
#     if subject is None:
#         subject = 'no_subject'
#     # Remove any illegal characters from the filename
#     valid_filename = ''.join(c if c.isalnum() or c in ' ._-,' else '_' for c in subject)
#     # Add suffix to the filename
#     output_filename = f"{valid_filename}_{suffix}.txt"

#     # Combine output directory and filename
#     output_file_path = os.path.join(output_dir, output_filename)

#     # Get the body of the email
#     if msg.is_multipart():
#         # If the message is multipart, iterate through parts and find the text part
#         body = ""
#         for part in msg.iter_parts():
#             content_type = part.get_content_type()
#             # Look for the text/plain content type
#             if content_type == 'text/plain':
#                 body = part.get_content()
#                 break
#     else:
#         # If the message is not multipart, get the payload directly
#         body = msg.get_payload()

#     # Write the body content to the output file
#     with open(output_file_path, 'w') as output_file:
#         output_file.write(body)
    
#     print(f"Body of the email saved to '{output_file_path}'.")

# def main():
#     # Set up the argument parser
#     parser = argparse.ArgumentParser(description="Extract the body of an email from an .eml file and save it as a text file.")
    
#     # Define the named arguments
#     parser.add_argument("--eml_file", required=True, help="Path to the .eml file")
#     parser.add_argument("--output_directory", required=True, help="Output directory to save the .txt file")
#     parser.add_argument("--suffix", required=True, help="Suffix for the output file")
    
#     # Parse the arguments
#     args = parser.parse_args()
    
#     # Extract the email body to the specified output location with the given suffix
#     extract_email_body_to_txt(args.eml_file, args.output_directory, args.suffix)

# if __name__ == "__main__":
#     main()

