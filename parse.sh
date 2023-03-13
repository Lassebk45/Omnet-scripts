#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/parse-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/parse-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=16G
#SBATCH --time=00:15:00

TOPO_NAME="${1}"
ALG="${2}"
ALG_SHORT="${3}"
RESULT_FOLDER="${4}"
PARSED_RESULTS_DIR="${5}"

python3 -m pip install -r requirements.txt

opp_scavetool export -F CSV-R -o - ${RESULT_FOLDER}General*.sca | python3 parse.py --name $TOPO_NAME --algorithm $ALG --output_dir $PARSED_RESULTS_DIR/omnet_${ALG_SHORT}