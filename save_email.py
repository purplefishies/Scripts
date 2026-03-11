#!/usr/bin/env python

import os
import argparse
import uuid
from email import policy
from email.parser import BytesParser

def extract_email_body_and_attachments(eml_file_path, output_dir, suffix, org_file_path=None):
    """
    Extract the email body and attachments from an .eml file, save them in the specified output directory,
    and optionally update an ORG file with email and attachments details.

    Parameters:
        eml_file_path (str): Path to the .eml file.
        output_dir (str): Directory to save the .txt file and attachments.
        suffix (str): Suffix for the output file and attachment names.
        org_file_path (str, optional): Path to the ORG file to update with email and attachments details.

    Returns:
        None
    """
    # Parse the .eml file
    with open(eml_file_path, 'rb') as eml_file:
        msg = BytesParser(policy=policy.default).parse(eml_file)

    # Get the subject line
    subject = msg['subject'] or 'no_subject'
    
    # Capitalize the "TODO" part of the subject
    subject = ' '.join(word.upper() if word.lower() == 'todo' else word for word in subject.split())
    
    # Create a valid filename from the subject
    valid_filename = ''.join(c if c.isalnum() or c in ' ._-/' else '_' for c in subject)
    
    # Combine the suffix to create the output file path for the email body
    output_filename = f"{valid_filename}_{suffix}.txt"
    unique_id = uuid.uuid4().hex
    output_file_path = os.path.join(output_dir, output_filename + unique_id)

    # Initialize the body
    body = ""

    # List to keep track of attachment file paths for ORG file updates
    attachment_paths = []

    # Process the email's parts
    if msg.is_multipart():
        # Iterate through the email parts
        for part in msg.iter_parts():
            content_type = part.get_content_type()
            filename = part.get_filename()

            # Check for plain text (body) without a filename
            if content_type == 'text/plain' or content_type == 'multipart/alternative':
                if not filename:
                    body += part.get_content()

            # Save attachments
            elif filename:
                # Generate a unique identifier for the attachment filename
                unique_id = uuid.uuid4().hex
                
                # Determine the file extension and suffix
                extension = os.path.splitext(filename)[1]
                
                # Calculate the saved attachment filename using the unique ID
                saved_attachment_filename = f"{valid_filename}_{unique_id}_{suffix}{extension}"
                
                # Determine the path to save the attachment
                attachment_path = os.path.join(output_dir, saved_attachment_filename)

                # Save attachment to the specified path
                with open(attachment_path, 'wb') as attachment_file:
                    attachment_file.write(part.get_payload(decode=True))
                print(f"Attachment saved to '{attachment_path}'.")

                # Keep track of the saved attachment path for updating the ORG file
                attachment_paths.append(attachment_path)
    else:
        # For single-part emails, the payload is the body
        body += msg.get_payload()

    # Save the body content as a text file
    with open(output_file_path, 'w') as output_file:
        output_file.write(body)
    print(f"Email body saved to '{output_file_path}'.")

    # Update the ORG file if provided
    if org_file_path:
        with open(org_file_path, 'a') as org_file:
            # Write the headline for the email
            org_file.write(f"\n** {valid_filename}\n")
            
            # Write the email body
            org_file.write(f"{body}\n")
            
            # Add a subheadline for attachments if there are any
            if attachment_paths:
                org_file.write("\n*** Attachments\n")
            
                # Add links to attachments in the ORG file
                for attachment_path in attachment_paths:
                    # Calculate the relative path from the ORG file to the attachment file
                    relative_attachment_path = os.path.relpath(attachment_path, os.path.dirname(org_file_path))
                    
                    # Write the relative link to the ORG file
                    org_file.write(f"[[file:{relative_attachment_path}]]\n")
                    print(f"Added attachment link to '{org_file_path}'.")
                    
def main():
    # Set up the argument parser
    parser = argparse.ArgumentParser(description="Extract the email body and attachments from an .eml file, save them in the specified output directory, and optionally update an ORG file with email and attachments details.")

    # Define the arguments
    parser.add_argument("--path_to_eml_file", required=True, help="Path to the .eml file.")
    parser.add_argument("--output_directory", required=True, help="Output directory to save the .txt file and attachments.")
    parser.add_argument("--suffix", required=True, help="Suffix for the output file and attachment names.")
    parser.add_argument("--org", help="Path to the ORG file to update with email and attachments details (optional).")

    # Parse the arguments
    args = parser.parse_args()

    # Extract email body and attachments, and update the ORG file if provided
    extract_email_body_and_attachments(args.path_to_eml_file, args.output_directory, args.suffix, args.org)

if __name__ == "__main__":
    main()
