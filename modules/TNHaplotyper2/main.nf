process TNHaplotyper2
{
    debug true
    publishDir params.outdir, mode:'copy'
    tag "${reads[0]}, ${reads[1]}"
    
    input:
        tuple val(sample_id), path(reads)
        path fastaFile
        path fastaIndex
        path gatkResource
        
    output:

        path "*_markdup_recalibrated_tnhaplotyper2.vcf.gz", emit:tnhaplotyper2_vcf
        path "*_markdup_recalibrated_tnhaplotyper2.vcf.gz.tbi"

    
    script:

        """          
        echo "running ${reads[0]} ${reads[1]}"
        bash nextflow-bin/code_tnhaplotype2.sh $fastaFile $fastaIndex $gatkResource ${reads[0]} ${reads[1]}
        """
}
