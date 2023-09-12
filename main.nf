nextflow.enable.dsl=2
//include TNHaplotyper2 module
include { TNHaplotyper2 } from './modules/TNHaplotyper2'
//run workflow
workflow{
    //create bam and bam.bai file pairs into nextflow channel
    read_pairs_ch = Channel
                .fromFilePairs(params.bam_files,size: 2)
    //run TNHaplotyper2 process from TNHaplotyper2 module
    TNHaplotyper2(read_pairs_ch, params.fastaFile, params.fastaIndex, params.gatkResource)
   }
