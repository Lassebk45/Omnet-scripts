#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/parse-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/parse-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=16G
#SBATCH --time=00:15:00

TOPO_NAME="${1}"
ALG="${2}"
RESULT_FOLDER="${3}"
OMNET_RESULTS_DIR="${4}"

python3 -m pip install -r requirements.txt

opp_scavetool export -F CSV-R -o - ${RESULT_FOLDER}General*.sca | python3 parse.py --name $TOPO_NAME --algorithm $ALG --output_dir $OMNET_RESULTS_DIR/omnet_$ALG