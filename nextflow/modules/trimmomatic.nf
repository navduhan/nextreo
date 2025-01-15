process trimmomatic {
    tag "$id"

    label 'trimmomatic'

    publishDir "${params.outdir}/", mode: 'copy'

    input:
        tuple val(id), path(reads1), path(reads2)

    output:
        tuple val(id), path("trimmed_reads/${id}_1_trimmed.fastq.gz"), emit: clean_reads1
        tuple val(id), path("trimmed_reads/${id}_2_trimmed.fastq.gz"), emit: clean_reads2 // For paired-end reads

    script:
    """
    mkdir -p trimmed_reads

    if ([ -n "${reads2}" ]); then
        # Paired-end reads
        trimmomatic PE -phred33 ${reads1} ${reads2} trimmed_reads/${id}_1_trimmed.fastq.gz trimmed_reads/${id}_1_unpaired.fastq.gz trimmed_reads/${id}_2_trimmed.fastq.gz trimmed_reads/${id}_2_unpaired.fastq.gz ILLUMINACLIP:${params.adapters}:2:30:10 SLIDINGWINDOW:${params.window_size}:${params.phred_quality} MINLEN:${params.min_length}
    else
        # Single-end reads
        trimmomatic SE -phred33 ${reads1} trimmed_reads/${id}_trimmed.fastq.gz ILLUMINACLIP:${params.adapters}:2:30:10 SLIDINGWINDOW:${params.window_size}:${params.phred_quality} MINLEN:${params.min_length}
    fi
    """
}
