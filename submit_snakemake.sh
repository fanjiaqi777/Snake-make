#!/bin/bash
#SBATCH -p v6_384           # 分区名
#SBATCH -N 1                # 使用1个节点
#SBATCH -n 90               
#SBATCH --mem=340000        # 每个节点分配380GB内存
#SBATCH -o snakemake_output-MAB-P1.txt
#SBATCH -e snakemake_error-MAB-P1.txt

# 加载环境变量
source /public1/soft/modules/module.sh

source /public1/home/sch10755/02.data/Fan-data/work/setup_env.sh

module load singularity/3.9.9

# 运行 Snakemake 工作流
snakemake --snakefile ./snakefile_to_allcounts-MAB_P1 --cores 90 --jobs 5

