SAMPLES = [
    "KD_1704_103_HQ"
]

# 定义所有规则的最终目标，确保所有步骤的输出文件都已生成
rule all:
    input:
        expand("aligned/{sample}.sort.markdup.bam", sample=SAMPLES),  # 标记重复的 BAM 文件
        expand("aligned/{sample}.sort.bam.flagstat", sample=SAMPLES),  # 对齐统计报告
        expand("aligned/{sample}.sort.bam.coverage", sample=SAMPLES)  # 覆盖率报告

# 规则：比对和排序
rule align_and_sort:
    input:
        r1=lambda wildcards: f"/public1/home/sch10755/02.data/Fan-data/KD-data/submit/{wildcards.sample}_R1.fq.gz",  # 配对的 R1 读段文件
        r2=lambda wildcards: f"/public1/home/sch10755/02.data/Fan-data/KD-data/submit/{wildcards.sample}_R2.fq.gz",  # 配对的 R2 读段文件
        ref="ref/Prunus_persica_v2.0.a1.scaffolds.fasta"  # 参考基因组
    output:
        bam="aligned/{sample}.sort.bam",  # 排序后的 BAM 文件
        log="aligned/{sample}.bwa.log"  # 比对日志文件
    threads: 10
    shell:
        """
        echo "Aligning and sorting {wildcards.sample}"
        singularity exec /public1/home/sch10755/02.data/Fan-data/Software/Reseq_genek.sif bwa mem -t {threads} -R '@RG\tID:{wildcards.sample}\tSM:{wildcards.sample}\tPL:illumina' {input.ref} {input.r1} {input.r2} 2>{output.log} | \
        singularity exec /public1/home/sch10755/02.data/Fan-data/Software/Reseq_genek.sif samtools sort -@ {threads} -m 10G -o {output.bam} -
        echo "Finished aligning and sorting {wildcards.sample}, generated {output.bam}"
        """

# 规则：标记重复
rule mark_duplicates:
    input:
        bam="aligned/{sample}.sort.bam"  # 排序后的 BAM 文件
    output:
        bam="aligned/{sample}.sort.markdup.bam",  # 标记重复的 BAM 文件
        metrics="aligned/{sample}.marked_dup_metrics.txt"  # 重复标记的指标文件
    threads: 10
    shell:
        """
        echo "Marking duplicates for {input.bam}"
        singularity exec /public1/home/sch10755/02.data/Fan-data/Software/Reseq_genek.sif java -Xmx4g -XX:ParallelGCThreads={threads} -jar /opt/picard.jar MarkDuplicates \
        I={input.bam} O={output.bam} CREATE_INDEX=true REMOVE_DUPLICATES=true M={output.metrics}
        echo "Finished marking duplicates for {input.bam}, generated {output.bam}"
        """

# 规则：生成对齐统计
rule flagstat:
    input:
        bam="aligned/{sample}.sort.bam"  # 排序后的 BAM 文件
    output:
        flagstat="aligned/{sample}.sort.bam.flagstat"  # 对齐统计报告
    shell:
        """
        echo "Generating flagstat for {input.bam}"
        singularity exec /public1/home/sch10755/02.data/Fan-data/Software/Reseq_genek.sif samtools flagstat {input.bam} > {output.flagstat}
        echo "Finished generating flagstat for {input.bam}, generated {output.flagstat}"
        """

# 规则：计算覆盖率
rule coverage:
    input:
        bam="aligned/{sample}.sort.bam"  # 排序后的 BAM 文件
    output:
        coverage="aligned/{sample}.sort.bam.coverage"  # 覆盖率报告
    shell:
        """
        echo "Calculating coverage for {input.bam}"
        singularity exec /public1/home/sch10755/02.data/Fan-data/Software/Reseq_genek.sif samtools coverage {input.bam} > {output.coverage}
        echo "Finished calculating coverage for {input.bam}, generated {output.coverage}"
        """
