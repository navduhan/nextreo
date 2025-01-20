import argparse
from Bio import SeqIO
import pandas as pd
from Bio.SeqRecord import SeqRecord

def trim_fasta(fasta_file, blast_df, output_file):
    # Create a dictionary from BLAST DataFrame using 'query_id', 'query_start', and 'query_end'
    blast_results = blast_df[['query_id', 'query_start', 'query_end']].dropna().set_index('query_id').to_dict(orient='index')

    # Read FASTA and trim based on BLAST results
    # Prepare trimmed sequences
    trimmed_sequences = []
    for record in SeqIO.parse(fasta_file, 'fasta'):
        query_id = record.id
        if query_id in blast_results:
            start, end = blast_results[query_id]['query_start'], blast_results[query_id]['query_end']
            trimmed_seq = record.seq[start-1:end]
            
            # Create a new SeqRecord with the trimmed sequence
            trimmed_record = SeqRecord(
                trimmed_seq,
                id=record.id,
                name=record.name,
                description=f"{record.description} | Trimmed {start}-{end}"
            )
            trimmed_sequences.append(trimmed_record)
        else:
            # Keep the original record if no trimming is needed
            trimmed_sequences.append(record)

    # Write trimmed FASTA
    with open(output_file, 'w') as output:
        SeqIO.write(trimmed_sequences, output, 'fasta')

    print(f'Trimmed FASTA written to {output_file}')

def main():
    parser = argparse.ArgumentParser(description="Trim FASTA file based on BLAST results.")
    parser.add_argument("-f", "--fasta", required=True, help="Input FASTA file.")
    parser.add_argument("-b", "--blast", required=True, help="BLAST results DataFrame file (CSV).")
    parser.add_argument("-o", "--output", required=True, help="Output trimmed FASTA file.")
    args = parser.parse_args()

    # Read BLAST results DataFrame
    col_names = [
        'query_id', 'subject_id', 'percent_identity', 'alignment_length', 'mismatches',
        'gap_opens', 'query_start', 'query_end', 'subject_start', 'subject_end',
        'query_coverage', 'evalue', 'bit_score', 'query_length', 'subject_length',
        'subject_title', 'tax_id', 'subject_strand'
    ]
    blast_df = pd.read_csv(args.blast, sep="\t", names=col_names)
    blast_df['query_id'] = blast_df['query_id'].str.strip()
    
    trim_fasta(args.fasta, blast_df, args.output)

if __name__ == "__main__":
    main()
