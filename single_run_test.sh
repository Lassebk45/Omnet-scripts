#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/test.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/test.err
#SBATCH --partition=dhabi
#SBATCH --mem=16G
#SBATCH --time=168:00:00

source venv/bin/activate

python3 -m pip install -r requirements.txt

time python3 main.py --topology topologies/zoo_Aarnet.json --demands temporal_demands/Aarnet_0000.yml --algorithm essence --generate_package --output_dir ../inet/zoo --update_interval 20 --write_interval 10 --failure_scenarios 10 --time_scale 0.001 --scaler 10 --demand_scaler 0.2 --configuration scenario_2

