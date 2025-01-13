import argparse
from Bio import SeqIO

def modify_fasta_headers(input_fasta, output_fasta, prefix):
    # Define the custom order for segments
    segment_order = {"L1": 1, "L2": 2, "L3": 3, "M1": 4, "M2": 5, "M3": 6, "S1": 7, "S2": 8, "S3": 9, "S4": 10}
    
    # Store records with segment information
    records = []
    
    # Read the sequences and store them with their segment info
    for record in SeqIO.parse(input_fasta, 'fasta'):
        # Calculate the sequence length
        seq_length = len(record.seq)
        
        # Extract and modify the description
        original_description = record.description
        segment = None
        
        # Look for segment information in the description
        for part in original_description.split("|"):
            if "segment=" in part:
                segment = part.split("=")[1]  # Extract the segment identifier
                break
        
        # If no segment is found, leave it as None
        if segment is None:
            segment = "Unknown"  # Optionally, you can leave it as None or set a default value
        
        # Reconstruct the new description with prefix, length, and segment
        new_description = f"{prefix}|length={seq_length}|segment={segment}"
        
        # Store the record with its segment info for sorting
        records.append((segment, new_description, record.seq))
    
    # Sort records based on the custom segment order
    records.sort(key=lambda x: segment_order.get(x[0], 999))  # 999 as default for unrecognized segments
    
    # Write the sorted records to the output file
    with open(output_fasta, 'w') as outfile:
        for _, new_description, seq in records:
            outfile.write(f">{new_description}\n{seq}\n")

def main():
    parser = argparse.ArgumentParser(description="Modify all FASTA headers by replacing the first part with a prefix, adding sequence length, and sorting by segment.")
    parser.add_argument("-i", "--input", required=True, help="Path to the input FASTA file.")
    parser.add_argument("-o", "--output", required=True, help="Path to the output FASTA file.")
    parser.add_argument("-p", "--prefix", required=True, help="Prefix to replace the first part of the description in the FASTA file.")
    
    args = parser.parse_args()
    
    modify_fasta_headers(args.input, args.output, args.prefix)

if __name__ == "__main__":
    main()
