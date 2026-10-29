source ~/conda_config.sh
# conda create -n rrbs_env
conda activate rrbs_env
mamba install -c anaconda -c bioconda -c conda-forge -c r snakemake=7.* bismark r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots r-dbi fastqc trim-galore samtools multiqc ucsc-bedgraphtobigwig deeptools trimmomatic fastx_toolkit  libxcrypt libxcrypt1 bioconductor-dss bioconductor-bsseq r-openxlsx toolshed interlap bioconductor-genomeinfodb r-ggplot2 r-remotes  r-mclust bedtools bioconductor-epidish bioconductor-annotatr bioconductor-txdb.hsapiens.ucsc.hg38.knowngene bioconductor-org.hs.eg.db r-venndiagram macs3 "numpy<2" r-rspectra r-writexls r-foreach

devtools::install_github("bcm-uga/lfmm")

bioconductor-impute



source ~/conda_config.sh
# conda create -n epic_env
conda activate epic_env
mamba install -c anaconda -c bioconda -c conda-forge -c r snakemake=7.* bismark r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots r-dbi fastqc trim-galore samtools multiqc ucsc-bedgraphtobigwig deeptools trimmomatic fastx_toolkit  libxcrypt libxcrypt1 bioconductor-dss bioconductor-bsseq r-openxlsx toolshed interlap bioconductor-genomeinfodb r-ggplot2 r-remotes  r-mclust bedtools bioconductor-epidish bioconductor-annotatr bioconductor-txdb.hsapiens.ucsc.hg38.knowngene bioconductor-org.hs.eg.db r-venndiagram macs3 "numpy<2" r-rspectra r-writexls bioconductor-minfi bioconda::bioconductor-illuminahumanmethylationepicmanifest bioconductor-illuminahumanmethylationepicanno.ilm10b4.hg19 r-glmnetutils  r-glmnet

devtools::install_github("bcm-uga/lfmm")
devtools::install_github("fchuffar/epimedtools")
devtools::install_github("fchuffar/dnamaging")




# devtools::install_github("fchuffar/epimedtools")


conda list bismark
mamba search -c anaconda -c bioconda -c conda-forge -c r bismark

bismark=0.25.1