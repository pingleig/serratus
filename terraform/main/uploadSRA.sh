#!/bin/bash
# =====================================
# Serratus - uploadSRA.sh
# =====================================
#
# Usage: 
# uploadSRA.sh <sraRunInfo.csv>
#
# script for uploading sraRunInfo.csv
# files into Serratus in chunks and with
# randomization of input to normalize load.
# 
set -eu

# Config parameters -----------------------------
# Input SRA file
INPUT_SRA=$1

# Chunk size for uploading
SIZE=10000
# -----------------------------------------------

# Check that sraRunInfo was provided

if [ -z "$INPUT_SRA" ]; then
    echo "Usage:"
    echo "  uploadSRA.sh <sraRunInfo.csv>"
    exit 1
fi

# Sript ==============================================

# Descriptive parsing --------------------------------
# Scheduler DNS: 
echo "Loading SRARunInfo into scheduler "
echo "  File: $INPUT_SRA"
echo "  date: $(date)"
echo "  wc  : $(wc -l $INPUT_SRA)"
echo "  md5 : $(md5sum $INPUT_SRA)"
echo ""
echo ""

# Extract header from csv input
head -n1 $INPUT_SRA > sra.header.tmp

# Split the input csv file into $SIZE chunks
tail -n+2 $INPUT_SRA | gsplit -d -l $SIZE - tmp.chunk

# Re-header an sraRunInfo file for each chunk
# with randomization of the data order
# and upload to Serratus
for CHUNK in $(ls tmp.chunk*); do

  cat  sra.header.tmp > "$CHUNK"_sraRunInfo.csv
  shuf $CHUNK >> "$CHUNK"_sraRunInfo.csv

  echo '--------------------------'
  echo $CHUNK
  wc -l "$CHUNK"_sraRunInfo.csv
  gmd5sum "$CHUNK"_sraRunInfo.csv
      
  # Upload to Serratus
  # via curl (localhost:8000)
  curl -s -X POST -T "$CHUNK"_sraRunInfo.csv \
    localhost:8000/jobs/add_sra_run_info/
      
  # Clean-up
  rm $CHUNK "$CHUNK"_sraRunInfo.csv
done

rm sra.header.tmp

echo ""
echo ""
echo " uploadSRA complete."
