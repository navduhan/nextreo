process download_references {

    input:
        path blast_results  // Input BLAST results file

    output:
        path "reference_genomes.fasta", emit: reference_genomes  // Emit the reference genomes file

    script:
    """  
    # Run the Python script to download the reference genomes
    python3 ${projectDir}/bin/download_references.py -f ${blast_results} -o reference_genomes.fasta
    """
}
