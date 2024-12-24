import argparse
from Bio import SeqIO

def rename_fasta_headers(input_fasta, output_fasta):
    # Open the input and output FASTA files
    with open(input_fasta, 'r') as infile, open(output_fasta, 'w') as outfile:
        # Iterate over the sequences and modify headers
        for num, record in enumerate(SeqIO.parse(infile, "fasta"), start=1):
            # Rename the header to "nextreo_contigs_<num>"
            record.id = f"nextreo_contigs_{num}_{len(record.seq)}"
            record.description = ""  # Clear the description (optional)
            # Write the modified record to the output file
            SeqIO.write(record, outfile, "fasta")
        print(f"Renamed headers and saved to {output_fasta}")

def main():
    # Set up argparse to handle command-line arguments
    parser = argparse.ArgumentParser(description="Rename headers in a FASTA file")
    parser.add_argument("-i", "--input", required=True, help="Path to the input FASTA file")
    parser.add_argument("-o", "--output", required=True, help="Path to save the output FASTA file with renamed headers")

    # Parse the arguments
    args = parser.parse_args()

    # Call the function to rename headers
    rename_fasta_headers(args.input, args.output)

if __name__ == "__main__":
    main()
