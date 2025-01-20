process flexbar{
    tag "$id"

    label 'trimming'

    publishDir "${params.outdir}/", mode: 'copy'

    input:
        tuple val(id), path(reads1), path(reads2)  // Optional second file for paired-end reads

    output:
        tuple val(id), path("trimmed_reads/${id}_trimmed_1.fastq.gz"), emit: clean_reads1
        tuple val(id), path("trimmed_reads/${id}_trimmed_2.fastq.gz"), emit: clean_reads2

    script:
    """
    mkdir -p trimmed_reads

    if [ -n "$reads2" ]; then
        # Paired-end reads
        flexbar -r $reads1 -p $reads2 -t trimmed_reads/${id}_trimmed -qt ${params.quality} -n ${task.cpus} -z GZ -a ${params.adapters}
    else
        # Single-end reads
        flexbar -r $reads1 -t trimmed_reads/$id -qt ${params.quality} -n ${task.cpus} -z GZ -a ${params.adapters}
    fi
    """
}
