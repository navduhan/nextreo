#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- Avian Orthoreovirus Analysis Pipeline
* Author: naveen.duhan@outlook.com
*/

include {input_parser} from './nextflow/subworkflow/input_parser.nf'
include { fastqc } from './nextflow/modules/fastqc.nf'
include { trimming } from './nextflow/subworkflow/trimming.nf'
include { taxonomic_classification } from './nextflow/subworkflow/taxonomic_classification.nf'
include { assembly } from './nextflow/subworkflow/assembly.nf'
include { blast_annotation } from './nextflow/subworkflow/blast_annotation.nf'
include { consensus } from './nextflow/subworkflow/consensus.nf'
include { annotation } from './nextflow/subworkflow/annotation.nf'



// Validate parameters before running workflows
workflow {

    // Display help message if requested
    if (params.help) {
        helpMSG()
        exit 0
    }

    // Validate mandatory input parameters
    if (!params.input) {
        error 'Error: Input samplesheet not specified! Use --input <samplesheet> to provide input.'
    }

        // Check if input files exist
    def checkPathParamList = [ params.input, params.adapters ]
    checkPathParamList.each { param -> 
        if (param) { 
            file(param, checkIfExists: true) 
        } 
    }

    // Check mandatory parameters
    if (params.input) { 
        ch_input = file(params.input) 
    } else { 
        exit 1, 'Input samplesheet not specified!' 
    }

    // Run the Nextreo sub-workflow
    Nextreo(ch_input)
}

// Sub-workflow: Nextreo
workflow Nextreo {
    take:
        ch_input

    main:
        // Parse input samplesheet
        input_parser(ch_input)

        // Capture output channels
        ch_reads1 = input_parser.out.reads1
        ch_reads2 = input_parser.out.reads2

        // Run pipeline steps
        fastqc(ch_reads1.join(ch_reads2))
        trimming(ch_reads1, ch_reads2)
        taxonomic_classification(ch_reads1, ch_reads2)
        assembly(trimming.out.clean_reads1, trimming.out.clean_reads2)
        blast_annotation(assembly.out.contigs)
        consensus(ch_reads1, ch_reads2, blast_annotation.out.blastn_results_viruses)
        annotation(consensus.out.consensus_genomes)
}


// Helper functions
def helpMSG() {
    println """
    ____________________________________________________________________________________________

                                nextreo: Avian Orthoreovirus Analysis Pipeline

                                Author : Naveen Duhan (naveen.duhan@outlook.com)
    ____________________________________________________________________________________________

    Usage example:

    nextflow run nextreo.nf [options] --input <sample file /samplesheet> --outdir <output_directory>

    Options:
    --input      Path to the input samplesheet (mandatory)
    --adapters   Path to the adapters file (optional)
    --outdir     Directory for output files (default: './results')
    --help       Show this help message and exit
    """.stripIndent()
}
