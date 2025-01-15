process blastn {
    tag "$id" // Use the query ID for task labeling
    label 'blast'

    publishDir "${params.outdir}/blast_results", mode: 'copy'

    input:
        tuple val(id), path(fasta_file) //, path(blastdb)

    output:
        path "${id}_best_hits_nt.xls", emit: formatted_blast_output // Emit only Excel files

    script:
    """
    

    # Run BLAST search
    blastn \\
        -query ${fasta_file} \\
        -db ${params.blastdb_nt} \\
        -out ${id}_nt.txt \\
        -num_alignments 5 \\
        -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send qcovs evalue bitscore qlen slen stitle staxids sstrand' \\
        -num_threads ${task.cpus}

    # Create output directory for processed results
    mkdir -p ${id}_processed_results

    # Run Python script to process the BLAST results
    python3 ${workflow.projectDir}/bin/process_blast_results.py \\
        -b ${id}_nt.txt \\
        -f ${fasta_file} \\
        -p ${id} \\
        -s nt
    """
}

