process metaspades {
    tag "$id"

    input:
        tuple val(id), path(reads1), path(reads2) 

    output:
        tuple val(id), path("metaspades_results/${id}/${id}_contigs.fa"), emit: contigs

    script:
    """
    mkdir -p metaspades_results

    if ([ -n "${reads2}" ]); then
        # Paired-end assembly
        spades.py \\
            --meta \\
            --pe1-1 ${reads1} --pe1-2 ${reads2} \\
            -t ${task.cpus} \\
            -m ${task.memory.toMega()} \\
            -o metaspades_results/${id}
    else
        # Single-end assembly
        spades.py \\
            --meta \\
            -s ${reads1} \\
            -t ${task.cpus} \\
            -m ${task.memory.toMega()} \\
            -o metaspades_results/${id}
    fi

    mv metaspades_results/${id}/scaffolds.fasta metaspades_results/${id}/${id}.contigs.fa

    """
}
