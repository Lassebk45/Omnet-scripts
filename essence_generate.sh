#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/ess_generate-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/ess_generate-%j.err
#SBATCH --partition=naples,dhabi
#SBATCH --mem=32G
#SBATCH --time=168:00:00
#SBATCH -n 2

TOPOLOGY="${1}"
DEMANDS="${2}"
ALGORITHM="${3}"
OUTPUT_DIR="${4}"
UPDATE_INTERVAL="${5}"
TIME_SCALE="${6}"
ESSENCE_DIR="${7}"
SCALER="${8}"
DEMAND_SCALER="${9}"
WRITE_INTERVAL="${10}"
RESULTS_FOLDER="${11}"
FAILURE_SCENARIOS="${12}"
cd $ESSENCE_DIR

source venv/bin/activate

python3 -m pip install -r requirements.txt
python3 main.py --utilization_recording_interval 10000 --topology ${TOPOLOGY} --demands ${DEMANDS} --algorithm ${ALGORITHM} --output_dir ${OUTPUT_DIR} --update_interval ${UPDATE_INTERVAL} --time_scale ${TIME_SCALE} --scaler ${SCALER} --demand_scaler ${DEMAND_SCALER} --write_interval ${WRITE_INTERVAL} --results_folder ${RESULTS_FOLDER} --failure_scenarios ${FAILURE_SCENARIOS} --no_execution