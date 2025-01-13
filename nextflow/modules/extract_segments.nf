process extract_segments {
    tag "$id"

    input:
        tuple val(id), path(cds)

    output:
        tuple val(id), path("final_segments/${id}/${id}_L1_1.fa"),   emit: "L1"
        tuple val(id), path("final_segments/${id}/${id}_L2_1.fa"),   emit: "L2"
        tuple val(id), path("final_segments/${id}/${id}_L3_1.fa"),   emit: "L3"
        tuple val(id), path("final_segments/${id}/${id}_M1_1.fa"),   emit: "M1"
        tuple val(id), path("final_segments/${id}/${id}_M2_1.fa"),   emit: "M2"
        tuple val(id), path("final_segments/${id}/${id}_M3_1.fa"),   emit: "M3"
        tuple val(id), path("final_segments/${id}/${id}_S1_3.fa"), emit: "S1"
        tuple val(id), path("final_segments/${id}/${id}_S2_1.fa"),   emit: "S2"
        tuple val(id), path("final_segments/${id}/${id}_S3_1.fa"),   emit: "S3"
        tuple val(id), path("final_segments/${id}/${id}_S4_1.fa"),   emit: "S4"
        tuple val(id), path("final_segments/${id}/${id}_concatenated.fa"), emit: "concatenated"

    publishDir "results", mode: 'copy'

    script:
    """

    mkdir -p final_segments

    python3 ${projectDir}/bin/extract_segments.py -i ${cds} -o final_segments/${id} -p ${id}
    """
}