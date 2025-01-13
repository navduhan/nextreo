process snippy {

    // Define input channels
    input:
    tuple val(id), path(reads1), path(reads2)
    path(ref)

    // Define output
    output:
    tuple val(id), path("genomes/${id}/${id}_all_segments.fa"), emit: all_segments  // Output the consensus genome for each reference genome

    // Use publishDir to save outputs in a specific directory
    publishDir "results", mode: 'copy'

    // Define the script to run Snippy
    script:
    """
    mkdir -p genomes
    snippy --reference ${ref} \
        --outdir "genomes/${id}" \
        --R1 ${reads1} \
        --R2 ${reads2} \
        --cpus ${task.cpus} \
        --prefix "${id}"

    python3 ${projectDir}/bin/name_genomes.py -i genomes/${id}/${id}.consensus.fa -o genomes/${id}/${id}_all_segments.fa -p ${id}

    """
}
