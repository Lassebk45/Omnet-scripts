#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/create_confs-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/create_confs-%j.err
#SBATCH --partition=naples
#SBATCH --mem=16G
#SBATCH --time=00:15:00

MPLS_KIT_DIR="${1}"
TOPO_DIR="${2}"
TOPO="${3}"
CONFS_DIR="${4}"
DEMANDS_DIR="${5}"
DEMAND="${6}"
ALG="${7}"
THRESHOLD="${8}"
MPLS_KIT_RESULTS_DIR="${9}"

cd $MPLS_KIT_DIR

python3 -m pip install -r requirements.txt

python3 create_confs.py --conf_name $ALG.yml --topology "$TOPO_DIR""$TOPO" --conf $CONFS_DIR --result_folder $MPLS_KIT_RESULTS_DIR --demand_file "$DEMANDS_DIR""$DEMAND" --algorithm $ALG --threshold $THRESHOLD --keep_failure_chunks