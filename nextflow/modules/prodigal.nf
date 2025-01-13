process prodigal {
    // Define input and output channels
    input:
        tuple val(id), path(genome)       // Path to the input genome file (FASTA)
    
    output:
        tuple val(id), path("annotations/${id}/${id}.gff"),      emit: gff     // Path to the GFF output file
        tuple val(id), path("annotations/${id}/${id}-cds.fa"),   emit: cds     // Path to the CDS output file
        tuple val(id), path("annotations/${id}/${id}-aa.fa"),    emit: aa     // Path to the AA output file
    
    // Use publishDir to save outputs in a specific directory
    publishDir "results", mode: 'copy'
    // Define the script block to run Prodigal
    script:

    """

    mkdir -p "annotations/${id}"

    prodigal -i ${genome} -o "annotations/${id}/${id}.gff" -a "annotations/${id}/${id}-aa.fa" -d "annotations/${id}/${id}-cds.fa" -p meta

    """
}