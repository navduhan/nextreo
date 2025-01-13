import argparse
from Bio import SeqIO
import re
import os

def extract_and_concat_fasta(input_file, output_dir, prefix):
    # Create a list to store sequences for the concatenation
    concat_sequence = ''

    os.makedirs(output_dir, exist_ok=True)

    # Open the input FASTA file
    with open(input_file, 'r') as fasta_file:
        for record in SeqIO.parse(fasta_file, 'fasta'):
            # Extract the header and sequence
            header = record.id
            sequence = record.seq

            # Use regex to extract the segment value from the header (e.g., 'S3' from 'MN24-16346_S3|length=1202|segment=S3')
            segment_match = re.search(r"segment=([A-Za-z0-9_]+)", header)
            if segment_match:
                segment = segment_match.group(1)  # Extracted segment value
            else:
                segment = "unknown"  # Default value if no segment is found


            # Write each sequence to a separate file named with the prefix and segment value
            output_file = f"{output_dir}/{prefix}_{segment}.fa"
            with open(output_file, 'w') as out_file:
                out_file.write(f">{header}|{len(sequence)}\n{sequence}\n")

            # Check if the segment matches the specified ones for concatenation
            if segment in ["L1_1", "L2_1", "L3_1", "M1_1", "M2_1", "M3_1", "S1_3", "S2_1", "S3_1", "S4_1"]:
                concat_sequence+=(str(sequence))

    # Concatenate the selected sequences and write to a file
    concatenated_seq = concat_sequence
    with open(f"{output_dir}/{prefix}_concatenated.fa", 'w') as concat_file:
        concat_file.write(f">{prefix}_concatenated|length={len(concatenated_seq)}\n{concatenated_seq}\n")

def main():
    # Set up the argument parser
    parser = argparse.ArgumentParser(description="Extract and concatenate specific sequences from a FASTA file.")
    
    # Define command-line arguments
    parser.add_argument("-i", "--input_file", help="Path to the input FASTA file")
    parser.add_argument("-o", "--output_dir", help="Directory to store the output files")
    parser.add_argument("-p", "--prefix", help="Prefix for the output filenames")

    # Parse the command-line arguments
    args = parser.parse_args()

    # Call the function with the parsed arguments
    extract_and_concat_fasta(args.input_file, args.output_dir, args.prefix)

if __name__ == "__main__":
    main()
