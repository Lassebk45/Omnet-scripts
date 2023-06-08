#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/make_plots-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=16G
#SBATCH --time=168:00:00

experiment_name="$1"
INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"

mkdir -p $HOME/$experiment_name

mkdir -p $HOME/$experiment_name/input/
mkdir -p $HOME/$experiment_name/results/
mkdir -p $HOME/$experiment_name/plots/
mkdir -p $HOME/$experiment_name/slurm-output/

cd $INET_DIR

make -j $(nproc)