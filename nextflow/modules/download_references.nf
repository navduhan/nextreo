process download_references {

    input:
        tuple val(id), path(blast_results)  // Input BLAST results file

    output:
        path "${id}_reference_genomes.fasta", emit: reference_genomes  // Emit the reference genomes file

    script:
    """  
    # Run the Python script to download the reference genomes
    python3 ${workflow.projectDir}/bin/download_references.py -f ${blast_results} -o ${id}_reference_genomes.fasta
    """
}
