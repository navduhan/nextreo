include { flexbar } from "../modules/flexbar"
include { trim_galore } from "../modules/trim_galore"
include { trimmomatic } from "../modules/trimmomatic"

workflow trimming {

    take:
        raw_reads1
        raw_reads2

    main:
        if (params.trimming_tool == "flexbar") {
            // Call the flexbar process
            flexbar(raw_reads1.join(raw_reads2))
        } else if (params.trimming_tool == "trim_galore") {
            // Call the trim_galore process
            trim_galore(raw_reads1.join(raw_reads2))
        } else if (params.trimming_tool == "trimmomatic") {
            // Call the trimmomatic process
            trimmomatic(raw_reads1.join(raw_reads2))
        } else {
            error "Invalid trimming tool specified in params.trimming_tool: '${params.trimming_tool}'. Please use 'flexbar', 'trim_galore', or 'trimmomatic'."
        }

    emit:
        clean_reads1 = params.trimming_tool == "flexbar" ? flexbar.out.clean_reads1 :
                       params.trimming_tool == "trim_galore" ? trim_galore.out.clean_reads1 :
                       trimmomatic.out.clean_reads1

        clean_reads2 = params.trimming_tool == "flexbar" ? flexbar.out.clean_reads2 :
                       params.trimming_tool == "trim_galore" ? trim_galore.out.clean_reads2 :
                       trimmomatic.out.clean_reads2
}
