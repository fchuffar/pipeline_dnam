import os 
import re
import string
exec(open("config").read())
rwversion=version # patch for bug in target shell (reserved word)

def get_files(src_dir, src_suffix, dest_dir, dest_suffix):
  files = [f for f in os.listdir(os.path.expanduser(src_dir)) if re.match("^.*"+src_suffix+"$", f)]
  files = [x.replace(src_suffix, dest_suffix) for x in files ]
  return [os.path.expanduser(dest_dir+f) for f in files]

fastqcR1_files = get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1_fastqc.zip")
fastqcR2_files = get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R2.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/raw/", "R2_fastqc.zip")
trimR1_files = get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1_val_1.fq.gz")
trimR2_files = get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R2.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/raw/", "R2_val_2.fq.gz")
bam_files =         get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "R1_val_1_bismark_bt2_pe_sorted.bam")
bw_files =          get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "R1_val_1_bismark_bt2_pe_sorted_4_RPKM.bw")
bw_bedgraph_files = get_files("/home/chuffarf/projects/datashare/"+gse+"/raw/", "R1.fastq.gz", "/home/chuffarf/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw")

# print(trimR1_files)
# print(trimR2_files)

localrules: target
rule target:
    threads: 1
    message: "-- Rule target completed. --"
    input: 
      # "/home/chuffarf/projects/datashare/genomes/"+species+"/"+annotation+"/"+rwversion+"/Sequence/WholeGenomeFasta/Bisulfite_Genome",
      # fastqcR1_files,
      # fastqcR2_files,
      # trimR1_files,
      # trimR2_files,
      # bam_files,
      # bw_files,
      bw_bedgraph_files,
    shell:"""
set +u
source ~/conda_config.sh 
conda activate rrbs_env
set -u
OMP_NUM_THREADS=1

multiqc --force -o /home/chuffarf/projects/"""+project+"""/results/"""+gse+"""/ -n multiqc_rrbs \
  /home/chuffarf/projects/datashare/"""+gse+"""/raw/*_fastqc.zip \
#   /home/chuffarf/projects/datashare/"""+gse+"""/*.txt \

          """

rule extract_meth_info_PE:
    input:  
      bam="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sorted.bam",
      chrom_sizes="/home/chuffarf/projects/datashare/genomes/"+species+"/"+annotation+"/"+rwversion+"/"+rwversion+".chrom.sizes",
    output:
      # sortedbyname_bam="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bam",
      splitting_report="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname_splitting_report.txt",
      mbias_txt       ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.M-bias.txt",
      bedgraph_gz     ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.gz",
      bedgraph_bw     ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw",
      cov_gz          ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz",
    threads: 32
    shell:"""
set +u
source ~/conda_config.sh 
conda activate rrbs_env
set -u
OMP_NUM_THREADS=1

# PARAMS
USER=chuffarf
SCRATCHDIR=$(find /localscratch -maxdepth 1 -type d -name "$USER.*" | head -n 1)"/" 
BAM={wildcards.sample}_R1_val_1_bismark_bt2_pe_sorted.bam
SORTEDBYNAME_BAM={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bam
SPLITTING_REPORT={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname_splitting_report.txt
MBIAS_TXT={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.M-bias.txt
BEDGRAPH_GZ={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.gz
BEDGRAPH={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph
BEDGRAPH_BW={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw
COV_GZ={wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz

rsync -auvP {input.bam} $SCRATCHDIR
ls -lha $SCRATCHDIR
cd $SCRATCHDIR

samtools sort -n -@  {threads} -T $SCRATCHDIR -o $SORTEDBYNAME_BAM $BAM
bismark_methylation_extractor --bedGraph --counts --paired-end --no_overlap  --multicore {threads} $SORTEDBYNAME_BAM
rm $SORTEDBYNAME_BAM $BAM
gzip -d -k $BEDGRAPH_GZ
bedGraphToBigWig $BEDGRAPH {input.chrom_sizes} $BEDGRAPH_BW
rsync -auvP $SPLITTING_REPORT $MBIAS_TXT $BEDGRAPH_GZ $BEDGRAPH_BW $COV_GZ {wildcards.prefix}
rm -Rf $SCRATCHDIR/*
    """
# bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore 24 test.wgbs.sortedbyname.bam
              
# rule bigwig_coverage:
#     input:
#       bam_file="{prefix}.bam",
#     output: "{prefix}_{width}_{normalize}.bw"
#     threads: 4
#     shell:"""
# set +u
# source ~/conda_config.sh 
# conda activate rrbs_env
# set -u
# OMP_NUM_THREADS=1

# bamCoverage \
#   -b {input.bam_file} \
#   --numberOfProcessors `echo "$(({threads} * 2))"` \
#   --binSize {wildcards.width} \
#   --minMappingQuality 30 \
#   --normalizeUsing {wildcards.normalize} \
#   -o {output}
#     """

# # zcat datashare/mcc_sa/raw/SAP_455_R1.fastq.gz | head -40000 | gzip > tmp/raw/test_R1.fastq.gz
# # zcat datashare/mcc_sa/raw/SAP_455_R2.fastq.gz | head -40000 | gzip > tmp/raw/test_R2.fastq.gz

# rule align_PE_with_bismark:
#     input:
#       trimed_fq_gz_f="{prefix}/raw/{sample}_R1_val_1.fq.gz",
#       trimed_fq_gz_r="{prefix}/raw/{sample}_R2_val_2.fq.gz",
#       bisulfite_genome_dir="/home/chuffarf/projects/datashare/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/Bisulfite_Genome"
#     output:
#       report="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_PE_report.txt",
#       bam="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_pe_sorted.bam",
#       bai="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_pe_sorted.bam.bai"
#     threads: 32
#     shell:    """
# set +u
# source ~/conda_config.sh 
# conda activate rrbs_env
# set -u
# OMP_NUM_THREADS=1

# # PARAMS
# USER=chuffarf
# # GO
# PREFIXGENOME={wildcards.species}_{wildcards.annotation}_{wildcards.version}
# SCRATCHDIR=$(find /localscratch -maxdepth 1 -type d -name "$USER.*" | head -n 1)"/"
# echo $SCRATCHDIR
# ls -lha $SCRATCHDIR
# TRIMR1={wildcards.sample}_R1_val_1.fq.gz
# TRIMR2={wildcards.sample}_R2_val_2.fq.gz
# rsync -auvP  {wildcards.prefix}/raw/$TRIMR1 {wildcards.prefix}/raw/$TRIMR2  $SCRATCHDIR
# ls -lha $SCRATCHDIR
# cd $SCRATCHDIR
# bismark --multicore `echo "$(({threads} / 2))"` \
#   --non_directional \
#   --prefix $PREFIXGENOME \
#   ~/projects/datashare/genomes/{wildcards.species}/{wildcards.annotation}/{wildcards.version}/Sequence/WholeGenomeFasta/ \
#   -1 $SCRATCHDIR$TRIMR1 \
#   -2 $SCRATCHDIR$TRIMR2
# samtools sort -@ {threads} -T $SCRATCHDIR/{wildcards.sample} \
#   -o $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_pe_sorted.bam \
#   $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_pe.bam
# samtools index $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_pe_sorted.bam
# rsync -auvP $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_*_*.* {wildcards.prefix}
#               """

# # rule align_SE_with_bismark:
# #     input:
# #       trimed_fq_gz_f="{prefix}/raw/{sample}_R1_val_1.fq.gz",
# #       trimed_fq_gz_r="{prefix}/raw/{sample}_R2_val_2.fq.gz",
# #       bisulfite_genome_dir="/home/chuffarf/projects/datashare/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/Bisulfite_Genome"
# #     output:
# #       report="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_SE_report.txt",
# #       bam="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_sorted.bam",
# #       bai="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_sorted.bam.bai"
# #     threads: 32
# #     shell:    """
# # set +u
# # source ~/conda_config.sh 
# # conda activate rrbs_env
# # set -u
# # OMP_NUM_THREADS=1

# # # PARAMS
# # USER=chuffarf
# # # GO
# # PREFIXGENOME={wildcards.species}_{wildcards.annotation}_{wildcards.version}
# # SCRATCHDIR=$(find /localscratch -maxdepth 1 -type d -name "$USER.*" | head -n 1)"/"
# # echo $SCRATCHDIR
# # TRIMR1={wildcards.sample}_R1_val_1.fq.gz
# # TRIMR2={wildcards.sample}_R2_val_2.fq.gz
# # rsync -auvP  {wildcards.prefix}/raw/$TRIMR1 {wildcards.prefix}/raw/$TRIMR2  $SCRATCHDIR
# # cd $SCRATCHDIR
# # bismark --multicore `echo "$(({threads} / 2))"` \
# #   --non_directional \
# #   --prefix $PREFIXGENOME \
# #   ~/projects/datashare/genomes/{wildcards.species}/{wildcards.annotation}/{wildcards.version}/Sequence/WholeGenomeFasta \
# #   $SCRATCHDIR$TRIMR1
# # samtools sort -@ {threads} -T $SCRATCHDIR/{wildcards.sample} \
# #   -o $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_sorted.bam \
# #   $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2.bam
# # samtools index $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_sorted.bam
# # rsync -auvP $SCRATCHDIR/$PREFIXGENOME.{wildcards.sample}_R1_val_1_bismark_bt2_*.* {wildcards.prefix}
# #               """

# rule trim_with_trim_galore_PE:
#     input:
#         fq_gz_f="{prefix}/{sample}_R1.fastq.gz",
#         fq_gz_r="{prefix}/{sample}_R2.fastq.gz",
#     output:
#         trimed_fq_gz_f="{prefix}/{sample}_R1_val_1.fq.gz",
#         trimed_fq_gz_r="{prefix}/{sample}_R2_val_2.fq.gz"
#     threads: 4
#     shell:"""
# set +u
# source ~/conda_config.sh 
# conda activate rrbs_env
# set -u
# OMP_NUM_THREADS=1

# trim_galore --cores {threads} --fastqc --paired {input.fq_gz_f} {input.fq_gz_r} -o {wildcards.prefix}/
#     """

# rule fastqc:
#     input:  fastqgz="{prefix}.fastq.gz"
#     output: zip="{prefix}_fastqc.zip",
#             html="{prefix}_fastqc.html"
#     threads: 1
#     shell:"""
# set +u
# source ~/conda_config.sh 
# conda activate rrbs_env
# set -u
# OMP_NUM_THREADS=1

# fastqc {input.fastqgz}
#     """

# rule bismark_genome_preparation:
#     input:
#         genome_fasta_dir="{prefix}/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/",
#     output:
#         bisulfite_genome_dir=directory("{prefix}/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/Bisulfite_Genome"),
#     threads: 32
#     shell:"""
# set +u
# source ~/conda_config.sh 
# conda activate rrbs_env
# set -u
# OMP_NUM_THREADS=1

# bismark_genome_preparation --parallel `echo "$(({threads} / 2))"` --bowtie2 {input.genome_fasta_dir}
# ls -lha {output.bisulfite_genome_dir}
#     """
