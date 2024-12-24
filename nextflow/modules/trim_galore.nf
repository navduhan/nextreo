process trim_galore {
    tag "$id"

    label 'trim_galore'

    publishDir "${params.outdir}/", mode: 'copy'

    input:
        tuple val(id), path(reads1), path(reads2) 

    output:
        tuple val(id), path("trimmed_reads/${id}_1_trimmed.fastq.gz"), emit: "clean_reads1"
        tuple val(id), path("trimmed_reads/${id}_2_trimmed.fastq.gz"), emit: "clean_reads2" // For paired-end reads

    script:
    """
    mkdir -p trimmed_reads

    if ([ -n "${reads2}" ]); then
        # Paired-end reads
        trim_galore --paired --quality ${params.quality} --cores ${task.cpus} --output_dir trimmed_reads ${reads1} ${reads2}
    else
        # Single-end reads
        trim_galore --quality ${params.quality} --cores ${task.cpus} --output_dir trimmed_reads ${reads1}
    fi
    """
}
