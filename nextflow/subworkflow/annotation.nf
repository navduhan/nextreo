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

        // Emit the extracted segments
        L1 = extract_segments.out.L1
        L2 = extract_segments.out.L2
        L3 = extract_segments.out.L3
        M1 = extract_segments.out.M1
        M2 = extract_segments.out.M2
        M3 = extract_segments.out.M3
        S1 = extract_segments.out.S1
        S2 = extract_segments.out.S2
        S3 = extract_segments.out.S3
        S4 = extract_segments.out.S4
        concatenated = extract_segments.out.concatenated
}