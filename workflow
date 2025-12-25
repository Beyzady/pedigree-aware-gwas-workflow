#!/bin/bash
#$ -S /bin/bash
#$ -N preprocess
#$ -cwd
#$ -o logs/all_repeats_preprocess_log.$JOB_ID.$TASK_ID.out
#$ -j y
#$ -m n
#$ -l h_data=24G,h_rt=24:00:00,highp
#$ -t 1-22:1

# Load modules
. /path/to/modules/init.sh
module load plink/1.90b624

# -----------------------------
# User-defined variables
# -----------------------------
input_chr=chr.$SGE_TASK_ID              # Chromosome identifier
chr_num=$SGE_TASK_ID                    # Chromosome number
gene=GENE_OF_INTEREST                   # Placeholder for gene
repeats=REPEATS_OF_INTEREST             # Placeholder for repeat type

# Paths (replace with your local paths)
INPUT_DIR=/path/to/input_data
OUTPUT_DIR=/path/to/output_data
TWO_COL_DIR=/path/to/two_col_files
MENDEL_EXECUTABLE=/path/to/mendel

# -----------------------------
# Step 1: Copy input files
# -----------------------------
cp ${INPUT_DIR}/${input_chr}.* ${OUTPUT_DIR}/${gene}_${repeats}_final/
echo "Copying completed."

# -----------------------------
# Step 2: Update BIM file
# -----------------------------
awk '{ $2 = $1":"$4; print }' ${OUTPUT_DIR}/${gene}_${repeats}_final/${input_chr}.bim \
> ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}.${input_chr}.temp \
&& mv ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}.${input_chr}.temp \
${OUTPUT_DIR}/${gene}_${repeats}_final/${input_chr}.bim
echo "BIM file updated."

# -----------------------------
# Step 3: Filter SNPs using PLINK
# -----------------------------
plink2 --bfile ${OUTPUT_DIR}/${gene}_${repeats}_final/${input_chr} \
--snps-only --rm-dup exclude-all --make-bed \
--out ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_snp_ma
echo "Step 3 completed."

# -----------------------------
# Step 4: Keep selected individuals and sort
# -----------------------------
plink --bfile ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_snp_ma \
--keep ${TWO_COL_DIR}/two_col_${gene}_${repeats}.txt \
--indiv-sort f ${TWO_COL_DIR}/two_col_${gene}_${repeats}.txt \
--make-bed \
--out ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_keep_sort
echo "Step 4 completed."

# -----------------------------
# Step 5: Filter on genotype, MAF, HWE
# -----------------------------
plink --bfile ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_keep_sort \
--geno 0.1 --maf 0.01 --hwe 1e-6 include-nonctrl --nonfounders --make-bed \
--out ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_final
echo "Step 5 completed."

# -----------------------------
# Step 6: Cleanup intermediate files
# -----------------------------
rm ${OUTPUT_DIR}/${gene}_${repeats}_final/${input_chr}.*
rm ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_snp_ma.*
rm ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_keep_sort.*
echo "Intermediate files removed."

# -----------------------------
# Step 7: Frequency calculation
# -----------------------------
plink --bfile ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_final \
--freq --out ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}
echo "Frequency files created."

# -----------------------------
# Step 8: Run ClassicMendel GWAS
# -----------------------------
CONFIG_FILE=$(mktemp)
cat <<EOF > "$CONFIG_FILE"
! Input Files
DEFINITION_FILE = /path/to/def_file.in
PEDIGREE_FILE = ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_final.fam
SNP_DATA_FILE = ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_final.bed
SNP_DEFINITION_FILE = ${OUTPUT_DIR}/${gene}_${repeats}_final/${gene}_${repeats}_chr${chr_num}_final.bim
INPUT_FORMAT = PLINK

! Output Files
OUTPUT_FILE = ${OUTPUT_DIR}/mendel_output/${gene}_${repeats}_Mendel_chr_${chr_num}.out
SUMMARY_FILE = ${OUTPUT_DIR}/mendel_output/${gene}_${repeats}_Summary_chr_${chr_num}.out
PLOT_FILE = ${OUTPUT_DIR}/mendel_output/${gene}_${repeats}_Plot_chr_${chr_num}.out

! Analysis Parameters
ANALYSIS_OPTION = ped_GWAS
QUANTITATIVE_TRAIT = simTrait
PREDICTOR = SEX :: simTrait
COVARIANCE_CLASS = ADDITIVE
COVARIANCE_CLASS = ENVIRONMENTAL
DESIRED_PREDICTORS = 10000 :: LRT
SNP_SAMPLING_INCREMENT = 5
KINSHIP_SOURCE = pedigree_structure
OUTLIERS = True
EOF

$MENDEL_EXECUTABLE -c "$CONFIG_FILE"
rm "$CONFIG_FILE"
echo "ClassicMendel analysis completed."
