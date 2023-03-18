#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/create_omnet_input-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/create_omnet_input-%j.err
#SBATCH --partition=naples
#SBATCH --mem=16G
#SBATCH --time=00:30:00

MPLS_KIT_DIR="${1}"
CONF="${2}"
TAKE_PERCENT="${3}"
ZERO_LATENCY="${4}"
SCALER="${5}"
PACKET_SIZE="${6}"
OMNET_INPUT_FILES_DIR="${7}"
TOPO_NAME="${8}"

echo $MPLS_KIT_DIR $CONF $TAKE_PERCENT $ZERO_LATENCY $SCALER $PACKET_SIZE $OMNET_INPUT_FILES_DIR $TOPO_NAME

echo "$MPLS_KIT_DIR"to_omnet.py --conf $CONF --take_percent $TAKE_PERCENT $ZERO_LATENCY --scaler $SCALER --packet_size $PACKET_SIZE --output_dir $OMNET_INPUT_FILES_DIR --generate_package --topo_name $TOPO_NAME

cd $MPLS_KIT_DIR

python3 -m pip install -r requirements.txt

python3 "$MPLS_KIT_DIR"to_omnet.py --conf $CONF --take_percent $TAKE_PERCENT $ZERO_LATENCY --scaler $SCALER --packet_size $PACKET_SIZE --output_dir $OMNET_INPUT_FILES_DIR --generate_package --topo_name $TOPO_NAME
