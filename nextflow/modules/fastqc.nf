// Author: Naveen Duhan

process fastqc {
    // tag "$id"
    label 'fastqc'

    input:
    tuple val(id), path(reads1), path(reads2)  // Single-end or paired-end reads

    output:
    path "fastqc_reports/*", emit: fastqc_report

    // Use publishDir to save outputs in a specific directory
    publishDir "${params.outdir}/", mode: 'copy'

    script:
    """
    mkdir -p fastqc_reports

    # Print log statement before running FastQC
    echo "Executing FastQC on files: ${reads1} and ${reads2}"

    # Check if files are paired-end or single-end
    if [ -z "${reads2}" ]; then
        # Single-end
        fastqc -t ${task.cpus} -o fastqc_reports ${reads1}
    else
        # Paired-end
        fastqc -t ${task.cpus} -o fastqc_reports ${reads1} ${reads2}
    fi
    """
}
