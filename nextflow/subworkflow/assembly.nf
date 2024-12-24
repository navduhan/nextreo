include { megahit } from "../modules/megahit"
include { metaspades } from "../modules/metaspades"

workflow assembly {
    take:
        raw_reads1
        raw_reads2

    main:
        if (params.assembler == "megahit") {
            megahit(raw_reads1.join(raw_reads2))
        } else if (params.assembler == "metaspades") {
            metaspades(raw_reads1.join(raw_reads2))
        } else {
            error "Invalid assembler specified in params.assembler: '${params.assembler}'. Please use 'megahit' or 'metaspades'."
        }

    emit:
        contigs = params.assembler == "megahit" ? megahit.out.contigs : metaspades.out.contigs
}
