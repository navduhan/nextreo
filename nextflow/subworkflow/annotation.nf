include {prodigal} from "../modules/prodigal"
include {extract_segments} from "../modules/extract_segments"

workflow annotation {
    take:
        fasta_file // Input FASTA file(s)

    main:
        // Run Prodigal to annotate the input FASTA file
        prodigal(fasta_file)

        extract_segments(prodigal.out.cds)

    emit:
        // Emit the Prodigal output files
        gff = prodigal.out.gff
        cds = prodigal.out.cds
        aa = prodigal.out.aa
        final_segments = extract_segments.out.final_segments

     
}