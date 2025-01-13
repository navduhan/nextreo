import os
import pandas as pd
import argparse
from Bio import Entrez

# Define the mapping
mapping = {
    'lambda A': 'L1',
    'lambda B': 'L2',
    'lambda C': 'L3',
    'segment L1': 'L1',
    'segment L2': 'L2',
    'segment L3': 'L3',
    'muA': 'M1',
    'segment M1': 'M1',
    'muB': 'M2',
    'segment M2': 'M2',
    'segment M3': 'M3',
    'muNS': 'M3',
    'segment S1': 'S1',
    'sigma C': 'S1',
    'segment S2': 'S2',
    'sigma A': 'S2',
    'segment S3': 'S3',
    'sigma B': 'S3',
    'sigma NS': 'S4',
    'segment S4': 'S4',
}

# Function to filter DataFrame by genus and add segment column
def filter_and_add_segment_column(df):
    filtered_df = df[df['genus'] == 'Orthoreovirus'].copy()

    def find_segment(title):
        for key, value in mapping.items():
            if key in title:
                return value
        return None  # Return None if no match is found

    filtered_df['segment'] = filtered_df['subject_title'].apply(find_segment)
    return filtered_df

# Function to retrieve the subject sequence from NCBI based on subject_id
def fetch_subject_sequence(subject_id):
    Entrez.email = "duhan27dec@gmail.com"  # Set your email here
    search_handle = Entrez.esearch(db="nucleotide", term=subject_id)
    search_results = Entrez.read(search_handle)
    search_handle.close()

    if len(search_results["IdList"]) > 0:
        accession = search_results["IdList"][0]
        fetch_handle = Entrez.efetch(db="nucleotide", id=accession, rettype="fasta", retmode="text")
        fetch_results = fetch_handle.read()
        fetch_handle.close()

        # Extract the sequence, remove the header, and join lines to get a single line sequence
        sequence = "".join(fetch_results.splitlines()[1:])  # Skip the header line and join the sequence parts into one line
        
        return sequence
    else:
        return None  # If subject_id is not found

# Function to download sequences for the top hits of each segment and save them in a single file
def download_top_hits_sequences(blast_results_file, output_file="all_sequences.fasta"):
    # Load BLAST results
    blast_results = pd.read_csv(blast_results_file, sep='\t')

    # Filter and add segment column
    blast_results = filter_and_add_segment_column(blast_results)

    # Dictionary to track downloaded sequences
    downloaded_segments = {}

    with open(output_file, "w") as outfile:
        for _, row in blast_results.iterrows():
            segment = row['segment']
            
            # Skip downloading if the segment has already been downloaded
            if segment in downloaded_segments:
                continue

            subject_id = row['subject_id'].split("|")[3]
            
            # Fetch the sequence for the subject_id
            subject_sequence = fetch_subject_sequence(subject_id)
            
            if subject_sequence:
                # Add sequence to the output file with segment label in the header
                outfile.write(f">{subject_id}|segment={segment}\n{subject_sequence}\n")
                downloaded_segments[segment] = subject_id
                print(f"Downloaded and saved sequence for {segment} ({subject_id})")
            else:
                print(f"Failed to fetch sequence for {subject_id}")

# Main function to parse arguments and call download function
def main():
    parser = argparse.ArgumentParser(description="Download top hits FASTA sequences and save them to a file.")
    parser.add_argument("-f", "--blast_results_file", help="The file containing BLAST results in tabular format.")
    parser.add_argument('-o', "--output_file", default="all_sequences.fasta", help="File to save the downloaded FASTA sequences.")
    
    args = parser.parse_args()
    
    # Download sequences for top hits
    download_top_hits_sequences(args.blast_results_file, args.output_file)

if __name__ == "__main__":
    main()
