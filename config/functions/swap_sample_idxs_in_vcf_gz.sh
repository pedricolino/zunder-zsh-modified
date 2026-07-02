#!/bin/bash
# Script to swap sample positions in VCF file
# Swaps columns 10 and 11 (sample data columns)

# exit if any command fails
set -e

# usage message
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_vcf.gz>"
    exit 1
fi

# first argument: input VCF file
input_vcf=$1
tmp_vcf="swapped_tmp.vcf"

# does the input file exist?
if [ ! -f "$input_vcf" ]; then
    echo "Error: Input file $input_vcf does not exist."
    exit 1
fi

# is the input file a .vcf.gz file?
if [[ "$input_vcf" != *.vcf.gz ]]; then
    echo "Error: Input file $input_vcf is not a .vcf.gz file."
    exit 1
fi

echo "Swapping sample columns in VCF file..."
echo "Input: $input_vcf"
echo "Output: $tmp_vcf"

zcat "$input_vcf" | awk '
BEGIN {FS="\t"; OFS="\t"}
{
    if ($0 ~ /^##/) {
        # Pass through all header lines except the sample header
        print $0
    }
    else if ($0 ~ /^#CHROM/) {
        # Swap sample names in the header line
        # VCF format: CHROM POS ID REF ALT QUAL FILTER INFO FORMAT SAMPLE1 SAMPLE2
        # We need to swap columns 10 and 11
        temp = $10
        $10 = $11
        $11 = temp
        print $0
    }
    else {
        # Swap sample data columns for all variant lines
        temp = $10
        $10 = $11
        $11 = temp
        print $0
    }
}' > "$tmp_vcf"

echo "Sample swap completed!"
echo "New temporary file created: $tmp_vcf"
echo ""
echo "Verifying the header change:"
echo "Original header:"
zcat "$input_vcf" | grep "^#CHROM"
zcat "$input_vcf" | grep "^1" | head -n1
echo "New header:"
head -n 1000 "$tmp_vcf" | grep "^#CHROM"
cat "$tmp_vcf" | grep "^1" | head -n1


# ask if it is correct
read -p "Is the sample swap correct? (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "Sample swap confirmed. Proceeding with compression and indexing..."
    # Compress and index the new VCF file
    bgzip -c "$tmp_vcf" > "${tmp_vcf}.gz"
    tabix -p vcf "${tmp_vcf}.gz"
    echo "Compression and indexing completed."
    # Rename input file to backup and move new file to original name, delete uncompressed tmp
    mv "$input_vcf" "${input_vcf}.bak"
    mv "${tmp_vcf}.gz" "$input_vcf"
    mv "${tmp_vcf}.gz.tbi" "${input_vcf}.tbi"
    rm "$tmp_vcf"
    echo "Original file backed up as ${input_vcf}.bak"
    echo "New swapped VCF file is now at: ${input_vcf}"
else
    echo "Sample swap not confirmed. Deleting temporary file."
    rm "$tmp_vcf"
fi