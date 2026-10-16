# 00. cp 00_preprocessing.sh to customize it
cp 01_preprocessing.sh 01_custom_preprocessing.sh
open 01_custom_preprocessing.sh

# 0. copy the correct config.XXX file
cp config.hg38 config

# 1. Set parameters there and in *config* file. 
## The two main setable parameters are *project* (the global project) *gse* (the batch/run of fastq files)
cd ~/projects/templeton/results/mcc_sa
source config
echo $gse
echo $project
source ~/conda_config.sh 
conda activate rrbs_env
## push to dahu
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/
## push to DRAC
expect -c "
spawn rsync -auvP /home/chuffarf/projects/${project}/results/${gse}/   drac:/home/chuffarf/projects/${project}/results/${gse}/ --exclude="macs3_output_merged"
expect \"Passcode or option (1-2):\"
send "${passcode}\\r"
interact
"
# pull fron DRAC
expect -c "
spawn rsync -auvzP drac:/home/chuffarf/projects/${project}/results/${gse}/   /home/chuffarf/projects/${project}/results/${gse}/ --exclude=".snakemake" --exclude="slurm*" --dry-run         
expect \"Passcode or option (1-2):\"
send "${passcode}\\r"
interact
"

# 2. Put raw fastq file in datashare/${gse}/raw
# For RRBS fastq files from NCBI/GEO,
#   go to https://github.com/fchuffar/gse2study
ln -s ~/projects/datashare
mkdir -p datashare/${gse}/raw
cd datashare/${gse}/raw
# done previously using https://github.com/fchuffar/gse2study/blob/master/01_preprocessing.sh ... 
# ... or edit and bash design.sh


# cd datashare/${gse}/raw
# ls -lha datashare_epistorage/epic_lfs_diagenode/raw/raw_data/205045*/*.idat | wc
# ln -s datashare_epistorage/epic_lfs_diagenode/raw/raw_data/2050*/*.idat .
# ls -lha
# # rsync -auvP --exclude="raw_data" cargo:datashare_epistorage/epic_lfs_diagenode/ datashare_epistorage/epic_lfs_diagenode/

# snakemake for RRBS pipeline 
source ~/conda_config.sh
conda activate rrbs_env 
cd ~/projects/${project}/results/${gse}/
ls -lha datashare/${gse}/raw/*.fastq.gz
# on a compute node
snakemake -k -s ~/projects/${project}/results/${gse}/wf_test.py --cores 8  -pn # 3G per node
# on GRICAD
snakemake -s ~/projects/${project}/results/${gse}/wf_rrbs.py --jobs 50 --cluster "oarsub --project epimed -l nodes=1/core={threads},walltime=6:00:00 " --latency-wait 60 -pn
# on DRAC
snakemake -k -s wf_rrbs.py --jobs 50 --core 32 --cluster-cancel "scancel" --cluster "sbatch --account=def-trasler --time=6:0:0 \
  --mem-per-cpu=12G --nodes=1 --ntasks=1 --cpus-per-task={threads} " \
  --latency-wait 60 -pn

snakemake -k -s wf_rrbs.py --jobs 50 --core 32 --cluster-cancel "scancel" --cluster "sbatch --account=def-trasler --time=6:0:0 \
  --mem-per-cpu=3G --nodes=1 --ntasks=1 --cpus-per-task={threads} " \
  --latency-wait 60 -pn



ssh cargo ls projects/datashare/${gse}
mkdir -p datashare/${gse}/
rsync -auvP cargo:projects/datashare/${gse}/multiqc_rrbs* datashare/${gse}/.
rsync -auvP cargo:projects/datashare/${gse}/*sorted.bam* datashare/${gse}/.
rsync -auvP cargo:projects/datashare/${gse}/*bismark.cov.gz datashare/${gse}/.
open datashare/${gse}/multiqc_rrbs.html

# export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
# cd /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/
# bismark --multicore `echo "$((16 / 2))"` -n 1 datashare/genomes/Rattus_norvegicus/UCSC/rn6/Sequence/WholeGenomeFasta/   -1 /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1.fq.gz     -2 /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R2_001_val_2.fq.gz
# samtools sort -@ 16 -T /dev/shm/F3C7_S19 -o /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe_sorted.bam /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe.bam
# # rm /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe.bam
# samtools index /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe_sorted.bam

# set design using design_rrbs.sh
source ~/conda_config.sh
# conda create -n rnbeadsrrbs_env
conda activate rnbeadsrrbs_env
# mamba install -c anaconda -c bioconda -c conda-forge -c r r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots bioconductor-rnbeads r-doparallel bioconductor-rnbeads.hg19 ghostscript bioconductor-watermelon bioconductor-illuminahumanmethylation450kanno.ilmn12.hg19 bioconductor-illuminahumanmethylationepicanno.ilm10b4.hg19 bioconductor-illuminahumanmethylation27kanno.ilmn12.hg19 snakemake=7.32.4 bioconductor-gostats r-hexbin r-wordcloud bioconductor-lola r-simplecache bioconductor-qvalue
# devtools::install_github("fchuffar/epimedtools")
# launch RnBeads
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 02_rnbeads_go.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
echo ${project}/results/${gse}/rnbead_vignettes
mkdir -p ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/ 
rsync -auvP cargo:~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/*.bigWig ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/.

# run ewas
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
rsync -auvP cargo:projects/${project}/results/${gse}/ewas_vignettes/ ~/projects/${project}/results/${gse}/ewas_vignettes/

# run combp
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
rsync -auvP cargo:projects/${project}/results/${gse}/combp_vignettes/*.regions-p.bed.gz ~/projects/${project}/results/${gse}/combp_vignettes/




/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -jar /Applications/IGV_2.4.16.app/Contents/Java/igv.jar \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_01.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_02.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_03.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_04.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_05.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_06.bigWig \
  /Users/florent/projects/datashare/${gse}/SRR3467835_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467836_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467837_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467839_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467840_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467841_1_trimmed_bismark_bt2_sorted.bam \











Shell command: 
set +u
source ~/conda_config.sh 
conda activate rrbs_env
set -u

# PARAMS
USER=chuffarf
# GO
PREFIXGENOME=Homo_sapiens_UCSC_hg38
SCRATCHDIR=$(find /localscratch -maxdepth 1 -type d -name "$USER.*" | head -n 1)"/"
echo $SCRATCHDIR
rm -Rf $SCRATCHDIR 
TRIMR1=test_R1_val_1.fq.gz
TRIMR2=test_R2_val_2.fq.gz
# TRIMR1=test_R1.fastq.gz 
rsync -auvP  /home/chuffarf/projects/templeton/results/mcc_sa/tmp/raw/$TRIMR1 /home/chuffarf/projects/templeton/results/mcc_sa/tmp/raw/$TRIMR2  $SCRATCHDIR
cd $SCRATCHDIR
bismark --multicore 4  --non_directional   --prefix $PREFIXGENOME   ~/projects/datashare/genomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta   $SCRATCHDIR$TRIMR1  $SCRATCHDIR$TRIMR2
cat Homo_sapiens_UCSC_hg38.test_R1_val_1_bismark_bt2_SE_report.txt  | grep eff


#   --bowtie2 -N 0 -L 20 -X 1000 -p 3 

samtools sort -@ 16 -T $SCRATCHDIR/test   -o $SCRATCHDIR/$PREFIXGENOME.test_R1_val_1_bismark_bt2_sorted.bam   $SCRATCHDIR/$PREFIXGENOME.test_R1_val_1_bismark_bt2.bam
samtools index $SCRATCHDIR/$PREFIXGENOME.test_R1_val_1_bismark_bt2_sorted.bam
rsync -auvP $SCRATCHDIR/$PREFIXGENOME.test_R1_val_1_bismark_bt2_*.* /home/chuffarf/projects/templeton/results/mcc_sa/tmp





rm -Rf tmp/Homo_sapiens_UCSC_hg38.test_R1_val_1_bismark_bt2_* /localscratch/chuffarf.*/*


cd ~/projects/templeton/results/mcc_sa
rm -Rf tmp/Homo_sapiens_UCSC_hg38.test_R1_val_1_bismark_bt2_*
snakemake -s ~/projects/${project}/results/${gse}/wf_test.py --cores 2  -p

cat tmp/Homo_sapiens_UCSC_hg38.test_R1_val_1_bismark_bt2_SE_report.txt  | grep eff


cd /localscratch/chuffarf.23124222.0/





rm -Rf /localscratch/chuffarf.*/Hom* 

set +u
source ~/conda_config.sh 
conda activate rrbs_env
set -u

# PARAMS
USER=chuffarf
# GO
PREFIXGENOME=Homo_sapiens_UCSC_hg38
SCRATCHDIR=$(find /localscratch -maxdepth 1 -type d -name "$USER.*" | head -n 1)"/"
echo $SCRATCHDIR
TRIMR1=test_R1_val_1.fq.gz
TRIMR2=test_R2_val_2.fq.gz
rsync -auvP  /home/chuffarf/projects/templeton/results/mcc_sa/tmp/raw/$TRIMR1 /home/chuffarf/projects/templeton/results/mcc_sa/tmp/raw/$TRIMR2  $SCRATCHDIR
cd $SCRATCHDIR
echo "TMPDIR=$TMPDIR"
which bismark bowtie2 samtools
bismark --version; samtools --version | head -1
ls -la $SCRATCHDIR
df -h $SCRATCHDIR
(bismark --multicore `echo "$((2 / 2))"`   --non_directional   --prefix $PREFIXGENOME   ~/projects/datashare/genomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta   $SCRATCHDIR$TRIMR1 2>&1) > log2.snk.txt


/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/bash -euo pipefail -c 'PREFIXGENOME=Homo_sapiens_UCSC_hg38 ; bismark --multicore 1   --non_directional   --prefix Homo_sapiens_UCSC_hg38   ~/projects/datashare/genomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta test_R1_val_1.fq.gz' < /dev/null
/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/bash -euo pipefail -c '...' < /dev/null