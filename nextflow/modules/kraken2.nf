process kraken2 {
    tag "$id" // Tag each task with the sample ID

    label 'kraken2' // Assign a label for resource management if needed

    publishDir "${params.outdir}/", mode: 'copy' // Define output directory

    input:
        tuple val(id), path(reads1), path(reads2)

    output:
        tuple val(id), path("kraken2_results/${id}_kraken2_report.txt"), emit: report
        tuple val(id), path("kraken2_results/${id}_kraken2_output.txt"), emit: classified_reads

    script:
    """
    mkdir -p kraken2_results

    if [ -n "${reads2}" ]; then
        # Paired-end reads
        kraken2 \\
            --db ${params.kraken2_db} \\
            --paired \\
            --threads ${task.cpus} \\
            --output kraken2_results/${id}_kraken2_output.txt \\
            --report kraken2_results/${id}_kraken2_report.txt \\
            --memory-mapping \\
            ${reads1} ${reads2}
    else
        # Single-end reads
        kraken2 \\
            --db ${params.kraken2_db} \\
            --threads ${task.cpus} \\
            --output kraken2_results/${id}_kraken2_output.txt \\
            --report kraken2_results/${id}_kraken2_report.txt \\
            ${reads1}
    fi
    """
}
