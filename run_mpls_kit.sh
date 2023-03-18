#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/run_mpls_kit-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/run_mpls_kit-%j.err
#SBATCH --partition=naples
#SBATCH --mem=16G
#SBATCH --time=02:00:00

CONFIG="${1}"
TAKE_PERCENT="${2}"
MPLS_KIT_DIR="${3}"

echo $CONFIG $TAKE_PERCENT $MPLS_KIT_DIR

cd $MPLS_KIT_DIR

source venv/bin/activate

python3 -m pip install -r requirements.txt

python3 tool_simulate.py --conf ${CONFIG} --take_percent ${TAKE_PERCENT}