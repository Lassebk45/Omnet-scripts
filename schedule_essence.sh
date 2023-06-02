#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in your INET_DIR as a relative path from .nedfolders. In this case, add ../omnet_input.

# Also make sure that OMNET_INPUT_FILES_DIR contains a file named package.ned with only the line "package inet.zoo"

# Go to INET_DIR and run "make makefiles" and "make"

SLURM_OUTPUT="/nfs/home/student.aau.dk/lkar18/slurm-output/essence"
RUN_SIMULATION="true"
MAKE_PLOTS="true"
ESSENCE_DIR="/nfs/home/student.aau.dk/lkar18/p10/"
TOPO_DIR="experiments/frr/"
OMNET_RESULTS_DIR="/nfs/home/student.aau.dk/lkar18/omnet_results/"
DEMANDS_DIR="temporal_demands/"
PACKET_SIZE="64"
SCALER="10"
ZERO_LATENCY=""
UPDATE_INTERVAL="120"
TIME_SCALE="0.15"
OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/lkar18/omnet_input/"
INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"
SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts/"
PLOT_DIR="/nfs/home/student.aau.dk/lkar18/plots/"
DEMAND_SCALER="0.2"
WRITE_INTERVAL="30"
FAILURE_SCENARIOS=20

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
declare -a ALGS=("essence" "essence_split" "fbr" "essence_precomputed" "essence_big_flows" "shortest_path") 
#declare -a ALGS=("essence" "essence_stateless")
RUN_OMNET_JOBS=":1"
if [ "$RUN_SIMULATION" = "true" ]; then
    for TOPO in "${TOPOS[@]}"; do
        topo_without_type="${TOPO::-5}"
        topo_without_type_and_zoo="${topo_without_type:4}"
        for ALG in "${ALGS[@]}"; do
            # First create all the necessary files
            FILE_GENERATE_ID=$(sbatch --parsable essence_generate.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL $OMNET_RESULTS_DIR $FAILURE_SCENARIOS)
            for ((i=0;i<FAILURE_SCENARIOS;i++)); do
                RUN_ID=$(sbatch --parsable --dependency=afterok:$FILE_GENERATE_ID essence_execute.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL $OMNET_RESULTS_DIR "scenario_"$i)
                RUN_OMNET_JOBS="$RUN_OMNET_JOBS:$RUN_ID"
            done
        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    sbatch --dependency=afterok$RUN_OMNET_JOBS make_plots.sh $OMNET_RESULTS_DIR $PLOT_DIR
fi
