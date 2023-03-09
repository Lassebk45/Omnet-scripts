#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=16G
#SBATCH --time=00:10:00

SCRIPTS_DIR="${1}"
PARSED_RESULTS_DIR="${2}"
PLOT_DIR="${3}"
MPLS_KIT_DIR="${4}"

cd $MPLS_KIT_DIR

python3 -m pip install -r requirements.txt

python3 $SCRIPTS_DIR/make_plots.py --input_dir $PARSED_RESULTS_DIR --output_dir $PLOT_DIR