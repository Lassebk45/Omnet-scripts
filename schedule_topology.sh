#!/bin/bash
#SBATCH --output=/nfs/home/student.aau.dk/lkar18/slurm-output/schedule_topology-%j.out
#SBATCH --error=/nfs/home/student.aau.dk/lkar18/slurm-output/schedule_topology-%j.err
#SBATCH --partition=naples
#SBATCH --mem=16G
#SBATCH --time=03:00:00

echo $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14

MPLS_KIT_DIR="$1"

TOPO_DIR="$2"

CONFS_DIR="$3"

RESULTS_DIR="$4"

DEMANDS_DIR="$5"

THRESHOLD="$6"

PACKET_SIZE="$7"

SCALER="$8"

ZERO_LATENCY="$9"

TAKE_PERCENT="${10}"

OMNET_INPUT_FILES_DIR="${11}"

TOPO="${12}"

DEMAND="${13}"

ALG="${14}"

INET_DIR="${15}"

CREATE_CONFS="${16}"

CREATE_OMNET_INPUT="${17}"

RUN_OMNET="${18}"

PARSE_RESULTS="${19}"

cd $MPLS_KIT_DIR

python3 -m pip install -r requirements.txt

if [ "$ALG" = "rsvp-fn" ]; then
    CONF="conf_rsvp-fn.yml"
    METHOD="rsvp"
fi  
if [ "$ALG" = "rmpls" ]; then
    CONF="conf_rmpls.yml"
fi

if [ "$CREATE_CONFS" = "true" ]; then
    python3 create_confs.py --topology $TOPO_DIR/$TOPO --conf $CONFS_DIR --result_folder $RESULTS_DIR --demand_file $DEMANDS_DIR/$DEMAND --algorithm $ALG --threshold $THRESHOLD
fi

if [ "$CREATE_OMNET_INPUT" = "true" ]; then
    python3 to_omnet.py --conf $CONFS_DIR/${TOPO::-5}/$CONF --take_percent $TAKE_PERCENT $ZERO_LATENCY --scaler $SCALER --packet_size $PACKET_SIZE --output_dir $OMNET_INPUT_FILES_DIR --generate_package
fi

if [ "$RUN_OMNET" = "true" ]; then
    cd $INET_DIR

    source setenv

    LOWERCASE_SHORT_TOPO="${TOPO::-5}"
    LOWERCASE_SHORT_TOPO="${LOWERCASE_SHORT_TOPO:4}"
    LOWERCASE_SHORT_TOPO="${LOWERCASE_SHORT_TOPO,,}"

    cd $OMNET_INPUT_FILES_DIR/$LOWERCASE_SHORT_TOPO/$METHOD

    inet
fi


# Parse results







