process megahit {
    tag "$id" // Tag the task with the sample ID

    label 'assembly' // Assign a label for resource management if needed

    publishDir "${params.outdir}/", mode: 'copy' // Define output directory

    input:
        tuple val(id), path(reads1), path(reads2)

    output:
        tuple val(id), path("assembly/${id}/${id}_nextreo_contigs.fa"), emit: contigs

    script:
    """
    mkdir -p assembly

    if [ -n "${reads2}" ]; then
        # Paired-end reads
        megahit \\
            -1 ${reads1} \\
            -2 ${reads2} \\
            --out-dir assembly/${id} \\
            --out-prefix ${id} \\
            --no-mercy \\
            --num-cpu-threads ${task.cpus} \\
            --min-contig-len ${params.min_contig_length}
    else
        # Single-end reads
        megahit \\
            -r ${reads1} \\
            --out-dir assembly/${id} \\
            --out-prefix ${id} \\
            --no-mercy \\
            --num-cpu-threads ${task.cpus} \\
            --min-contig-len ${params.min_contig_length}
    fi

    # After assembly, rename the contig headers using the Python script
    python3 ${projectDir}/bin/rename_contigs.py -i assembly/${id}/${id}.contigs.fa -o assembly/${id}/${id}_nextreo_contigs.fa
    """
}
