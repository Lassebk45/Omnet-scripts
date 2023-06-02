#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=128G
#SBATCH --time=168:00:00

OMNET_RESULTS_DIR="${1}"
PLOT_DIR="${2}"



python3 -m pip install -r requirements.txt

python3 make_plots.py --omnet_input_dir $OMNET_RESULTS_DIR --output_dir $PLOT_DIR