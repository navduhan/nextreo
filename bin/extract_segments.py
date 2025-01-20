import argparse
import os
import re
from Bio import SeqIO

def extract_and_concat_fasta(input_file, output_dir, prefix):
    # Create a list to store sequences for the concatenation
    concat_sequence = ''

    # Define segment fallback priority
    priority_segments = {
        "S1_3": ["S1_2", "S1_1"],  # Fallbacks for S1_3
        "S1_2": ["S1_1"],          # Fallbacks for S1_2
    }

    # Dictionary to store extracted sequences by segment
    sequences_dict = {}

    os.makedirs(output_dir, exist_ok=True)

    # Open the input FASTA file
    with open(input_file, 'r') as fasta_file:
        for record in SeqIO.parse(fasta_file, 'fasta'):
            # Extract the header and sequence
            header = record.id
            sequence = record.seq

            # Use regex to extract the segment value from the header
            segment_match = re.search(r"segment=([A-Za-z0-9_]+)", header)
            if segment_match:
                segment = segment_match.group(1)  # Extracted segment value
            else:
                segment = "unknown"  # Default value if no segment is found

            # Store sequence by segment in a dictionary for fallback use
            sequences_dict[segment] = sequence

            # Write each sequence to a separate file named with the prefix and segment value
            output_file = f"{output_dir}/{prefix}_{segment}.fa"

            sid,_,seg = header.split("|")
            with open(output_file, 'w') as out_file:
                out_file.write(f">{sid}|{seg}|{len(sequence)}\n{sequence}\n")

    # Loop through required segments and handle fallback mechanism
    required_segments = ["L1_1", "L2_1", "L3_1", "M1_1", "M2_1", "M3_1", "S1_3", "S2_1", "S3_1", "S4_1"]
    for segment in required_segments:
        if segment in sequences_dict:
            concat_sequence += str(sequences_dict[segment])
        elif segment in priority_segments:
            for fallback_segment in priority_segments[segment]:
                if fallback_segment in sequences_dict:
                    concat_sequence += str(sequences_dict[fallback_segment])
                    break  # Stop looking for further fallbacks once a match is found

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
