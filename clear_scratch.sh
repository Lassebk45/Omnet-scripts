#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/clear_scratch-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/clear_scratch-%j.err
#SBATCH --mem=16G
#SBATCH --time=168:00:00

rm -rf /scratch/lkar18