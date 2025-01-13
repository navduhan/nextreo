#!/usr/bin/env nextflow
nextflow.enable.dsl=2


/*
* Nextflow -- Avian Orthoreovirus Analysis Pipeline
* Author: naveen.duhan@outlook.com
*/

if (params.help) { exit 0, helpMSG() }

include {input_parser} from "./nextflow/subworkflow/input_parser"

include {fastqc} from "./nextflow/modules/fastqc"
include {trimming} from "./nextflow/subworkflow/trimming"
include {taxonomic_classification} from "./nextflow/subworkflow/taxonomic_classification"
include {assembly} from "./nextflow/subworkflow/assembly"
include {blast_annotation} from "./nextflow/subworkflow/blast_annotation.nf"
include {consensus} from "./nextflow/subworkflow/consensus"
include {annotation} from "./nextflow/subworkflow/annotation"
// Validate input parameters
// WorkflowNextreo.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.adapters ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }




workflow Nextreo {                                                                   

    // Input parsing from the previous process
    input_parser(ch_input)

    // Capture the output channels from input_parser
    ch_reads1 = input_parser.out.reads1     
    ch_reads2 = input_parser.out.reads2

    // Call the fastqc process with the combined channel
    fastqc(ch_reads1.join(ch_reads2))
    trimming(ch_reads1, ch_reads2)
    taxonomic_classification(ch_reads1, ch_reads2)
    assembly(trimming.out.clean_reads1, trimming.out.clean_reads2)
   
    blast_annotation(assembly.out.contigs)
    consensus(ch_reads1, ch_reads2, blast_annotation.out.blastn_results_viruses)
    annotation(consensus.out.consensus_genomes)


}


workflow {
    // Define the entry point workflow
    Nextreo()
}



/*************  
* --help
*************/

def helpMSG(){
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________

                                nextreo: Avian orthoreovirus Analysis Pipeline

                                Author : Naveen Duhan (naveen.duhan@outlook.com)
    ____________________________________________________________________________________________

    ${c_yellow}Usage example:${c_reset}

    nextflow run nextreo.nf [options] --input <sample file /samplesheet> --outdir <output_directory> 

    """.stripIndent()
}