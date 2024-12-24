include { blastn } from "../modules/blastn"
include { blastn_viruses } from "../modules/blastn_viruses"
include { blastx } from "../modules/blastx"

workflow blast_annotation {
    take:
        fasta_file // Input FASTA file(s)

    main:
        // Create channels for blast results
        def blastn_viruses_channel = Channel.empty()
        def blastn_channel = Channel.empty()
        def blastx_channel = Channel.empty()

        // Conditionally run the relevant blast processes
        if ('viruses' in params.blast_options) {
            blastn_viruses_channel = blastn_viruses(fasta_file)
        }

        if ('nt' in params.blast_options) {
            blastn_channel = blastn(fasta_file)
        }

        if ('nr' in params.blast_options) {
            blastx_channel = blastx(fasta_file)
        }

        if ('all' in params.blast_options) {
            blastn_viruses_channel = blastn_viruses(fasta_file)
            blastn_channel = blastn(fasta_file)
            blastx_channel = blastx(fasta_file)
        }

    emit:
        // Emit results based on which channels were populated
        blastn_results_viruses = blastn_viruses_channel.formatted_blast_output
        // blastn_results_nt = blastn_channel.formatted_blast_output
        // blastx_results_nr = blastx_channel.formatted_blast_output

        // Optionally, merge all results into one channel if needed
        // blast_results = Channel.merge(blastn_results_viruses, blastn_results_nt, blastx_results_nr)
}
