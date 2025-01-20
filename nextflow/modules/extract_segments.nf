process extract_segments {
    tag "$id"
    label 'blast'

    publishDir "${params.outdir}/", mode: 'copy'

    input:
        tuple val(id), path(cds)

    output:

        tuple val(id), path("final_segments/*"),   emit: final_segments

    

    script:
    """

    # Run BLAST search
    diamond blastx \
        --query ${cds} \
        --db ${params.diamonddb} \
        --out ${id}_nr.txt \
        --max-target-seqs 1 \
        --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send qcovhsp evalue bitscore qlen slen stitle staxids qstrand \
        --threads ${task.cpus}

    python3 ${workflow.projectDir}/bin/get_cds_seqs.py -f ${cds} -b ${id}_nr.txt -o ${id}_nr_cds.fasta

    mkdir -p final_segments

    python3 ${workflow.projectDir}/bin/extract_segments.py -i ${id}_nr_cds.fasta -o final_segments/${id} -p ${id}
    """

}