nextflow.enable.dsl=2

// -------------------------------------
// INCLUDE MODULES
// -------------------------------------

include { TNHaplotyper2 } from './modules/TNHaplotyper2'

workflow{
    read_pairs_ch = Channel
                .fromFilePairs(params.bam_files,size: 2)
    TNHaplotyper2(read_pairs_ch, params.fastaFile, params.fastaIndex,params.gatkResource)
        
}
