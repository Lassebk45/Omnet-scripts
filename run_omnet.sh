#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/run_omnet-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/run_omnet-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=16G
#SBATCH --time=02:00:00

INILOC="${1}"

cd $INILOC
inet