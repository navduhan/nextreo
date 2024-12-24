include { kraken2 } from "../modules/kraken2.nf"
include { krona } from "../modules/krona.nf"

workflow taxonomic_classification {

    take:
        raw_reads1
        raw_reads2

    main:
        // Run Kraken2 for taxonomic classification
        kraken2(raw_reads1.join(raw_reads2))

        // Generate Krona visualization using Kraken2 output
        krona(
            kraken2.out.report
        )

    emit:
        classified_reports = kraken2.out.report
        classified_reads = kraken2.out.classified_reads
        krona_html = krona.out.krona_html
}
