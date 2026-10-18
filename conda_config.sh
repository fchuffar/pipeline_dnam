source ~/conda_config.sh
# conda create -n rrbs_env
conda activate rrbs_env
mamba install -c anaconda -c bioconda -c conda-forge -c r snakemake=7.* bismark r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots r-dbi fastqc trim-galore samtools multiqc ucsc-bedgraphtobigwig deeptools trimmomatic fastx_toolkit  libxcrypt libxcrypt1 bioconductor-dss bioconductor-bsseq r-openxlsx toolshed interlap 


# devtools::install_github("fchuffar/epimedtools")


conda list bismark
mamba search -c anaconda -c bioconda -c conda-forge -c r bismark

bismark=0.25.1