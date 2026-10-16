source ~/conda_config.sh
# conda create -n rrbs_env
conda activate rrbs_env
mamba install -c anaconda -c bioconda -c conda-forge -c r bismark r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots r-dbi snakemake=7.* fastqc trim-galore samtools multiqc ucsc-bedgraphtobigwig deeptools trimmomatic fastx_toolkit  libxcrypt libxcrypt1


# devtools::install_github("fchuffar/epimedtools")


conda list bismark
mamba search -c anaconda -c bioconda -c conda-forge -c r bismark

bismark=0.25.1