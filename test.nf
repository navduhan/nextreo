#!/usr/bin/env nextflow

process test_slurm {
    executor = 'slurm'
    cpus = 2
    memory = '4GB'
    time = '1h'
    
    script:
    """
    echo "Testing SLURM executor"
    sleep 60
    """
}
workflow {
    test_slurm()
}
