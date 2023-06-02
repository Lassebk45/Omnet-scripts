#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/ess_execute-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/ess_execute-%j.err
#SBATCH --partition=dhabi,naples
#SBATCH --mem=16G
#SBATCH --time=168:00:00

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
CONFIGURATION="${12}"
SYNC_DIR="${13}"
cd $ESSENCE_DIR

source venv/bin/activate

python3 -m pip install -r requirements.txt
rm -rf ${SYNC_DIR}
mkdir -p ${SYNC_DIR}
python3 main.py --topology ${TOPOLOGY} --demands ${DEMANDS} --algorithm ${ALGORITHM} --output_dir ${OUTPUT_DIR} --update_interval ${UPDATE_INTERVAL} --time_scale ${TIME_SCALE} --scaler ${SCALER} --demand_scaler ${DEMAND_SCALER} --write_interval ${WRITE_INTERVAL} --configuration ${CONFIGURATION} --results_folder ${RESULTS_FOLDER} --only_execute --sync_dir ${SYNC_DIR}

rm -r ${SYNC_DIR}