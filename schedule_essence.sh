#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in your INET_DIR as a relative path from .nedfolders. In this case, add ../omnet_input.

# Also make sure that OMNET_INPUT_FILES_DIR contains a file named package.ned with only the line "package inet.zoo"

# Go to INET_DIR and run "make makefiles" and "make"

SLURM_OUTPUT="/nfs/home/student.aau.dk/lkar18/slurm-output/essence"

#CREATE_CONFS="true"

#CREATE_OMNET_INPUT="true"

RUN_SIMULATION="true"

#RUN_MPLS_KIT="false"

PARSE_RESULTS="true"

MAKE_PLOTS="true"

ESSENCE_DIR="/nfs/home/student.aau.dk/lkar18/p10/"

#MPLS_KIT_RESULTS_DIR="results/"

TOPO_DIR="DT/topology/"

CONFS_DIR="confs/"

OMNET_RESULTS_DIR="/nfs/home/student.aau.dk/lkar18/deutsche/output_files/"

DEMANDS_DIR="DT/demands/"

PACKET_SIZE="64"

SCALER="1"

ZERO_LATENCY=""

UPDATE_INTERVAL="180"

TIME_SCALE="1"

OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/lkar18/omnet_input/"

INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"

SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts/"

PLOT_DIR="/nfs/home/student.aau.dk/lkar18/deutsche/plots/"

DEMAND_SCALER="1"

WRITE_INTERVAL="60"

cd $ESSENCE_DIR$TOPO_DIR

TOPOS=(*)

cd $SCRIPTS_DIR

DEMANDS=()

TOPO_RE='.*zoo_(.*).json'
for i in "${!TOPOS[@]}"; do
    if [[ ${TOPOS[$i]} =~ $TOPO_RE ]] ; then
        DEMANDS+=(${BASH_REMATCH[1]}"_0000.yml")
    fi
done

# RUN SIMULATIONS
#declare -a ALGS=("essence" "essence_precomputed" "essence_stateless" "shortest_path")
declare -a ALGS=("shortest_path")
PARSE_RESULTS_JOBS=":1"
if [ "$RUN_SIMULATION" = "true" ]; then
    for TOPO in "${TOPOS[@]}"; do
        topo_without_type="${TOPO::-5}"
        topo_without_type_and_zoo="${topo_without_type:4}"
        for ALG in "${ALGS[@]}"; do
            RUN_ID=$(sbatch --parsable essence.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL)
            PARSE_ID=$(sbatch --parsable --dependency=afterok:$RUN_ID parse.sh $topo_without_type_and_zoo $ALG $OMNET_INPUT_FILES_DIR$topo_without_type_and_zoo/$ALG/results/ $OMNET_RESULTS_DIR)
            PARSE_RESULTS_JOBS="$PARSE_RESULTS_JOBS:$PARSE_ID"
        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    sbatch --dependency=afterok$PARSE_RESULTS_JOBS make_plots.sh $OMNET_RESULTS_DIR $PLOT_DIR
fi
