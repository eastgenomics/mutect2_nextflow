process TNHaplotyper2
{
    debug true
    publishDir params.outdir,mode:'copy'
    tag "${reads[0]},${reads[1]}"  
    //input ref files  
    input:
        tuple val(sample_id),path(reads)
        path fastaFile
        path fastaIndex
        path gatkResource    
    //output vcf and index files    
    output:
        path "*_markdup_recalibrated_tnhaplotyper2.vcf.gz",emit:tnhaplotyper2_vcf
        path "*_markdup_recalibrated_tnhaplotyper2.vcf.gz.tbi"  
    //running bash scripts from bin folder for sentieon tnhaplotyper2 
    script:
        """          
        echo "Running ${reads[0]} ${reads[1]}"
        bash nextflow-bin/code_tnhaplotyper2.sh $fastaFile $fastaIndex $gatkResource ${reads[0]} ${reads[1]}
        """
}
