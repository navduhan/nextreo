include { snippy } from "../modules/snippy"
include { download_references } from "../modules/download_references"




workflow consensus {

    take:
    reads_1
    reads_2
    blast_results

    main:
    // Step 1: Download reference genomes
    reference_genomes = download_references(blast_results)// Wait for download_reo_ref to finish

    // Step 5: Run Snippy for each genome-reference pair directly
    snippy(reads_1.join(reads_2), reference_genomes)

    emit:
    consensus_genomes = snippy.out.all_segments
}
