process krona {
    // tag "$id" // Tag each task with the sample ID

    label 'kraken2' // Assign a label for resource management if needed

    publishDir "${params.outdir}/", mode: 'copy' // Define output directory

    input:
        tuple val(id), path(kraken_report) // Input: Kraken2 report file

    output:
        tuple val(id), path("krona_results/${id}_krona.html"), emit: krona_html

    script:
    """
    mkdir -p krona_results

    # Generate Krona HTML visualization
    ktImportTaxonomy \\
        -t 5 \\
        -m 3 \\
        -o krona_results/${id}_krona.html \\
        ${kraken_report}
    """
}
