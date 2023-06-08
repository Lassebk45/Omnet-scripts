#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in your INET_DIR as a relative path from .nedfolders. In this case, add ../omnet_input.

# Also make sure that OMNET_INPUT_FILES_DIR contains a file named package.ned with only the line "package inet.zoo"

# Go to INET_DIR and run "make makefiles" and "make"

experiment_name="the_big_test"

rm -rf $HOME/$experiment_name

mkdir -p $HOME/$experiment_name

mkdir -p $HOME/$experiment_name/input/
mkdir -p $HOME/$experiment_name/results/
mkdir -p $HOME/$experiment_name/plots/
mkdir -p $HOME/$experiment_name/slurm-output/

INPUT_DIR_FROM_INET="../$experiment_name/input/"
SLURM_OUTPUT="$HOME/$experiment_name/slurm-output/"
RUN_SIMULATION="true"
MAKE_PLOTS="true"
ESSENCE_DIR="/nfs/home/student.aau.dk/lkar18/p10/"
TOPO_DIR="filtered_interesting_scaled_topologies/"
OMNET_RESULTS_DIR="$HOME/$experiment_name/results/"
DEMANDS_DIR="scaled_temporal_demands/"
PACKET_SIZE="64"
SCALER="10"
ZERO_LATENCY=""
UPDATE_INTERVAL="180"
TIME_SCALE="0.25"
OMNET_INPUT_FILES_DIR="$HOME/$experiment_name/input/"
INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"
SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts/"
PLOT_DIR="$HOME/$experiment_name/plots/"
DEMAND_SCALER="0.8"
WRITE_INTERVAL="30"
FAILURE_SCENARIOS=1
SYNC_DIR="/scratch/lkar18/$experiment_name/"
#SYNC_DIR="/nfs/home/student.aau.dk/lkar18/sync_dir"

# Prepare everything
#rm -r $HOME/slurm-output/*

PACKAGE_PATH="$OMNET_INPUT_FILES_DIR/package.ned"

rm $PACKAGE_PATH

touch $PACKAGE_PATH

echo "package $experiment_name;" >> $PACKAGE_PATH

#echo "${INPUT_DIR_FROM_INET}" >> ${INET_DIR}/.nedfolders

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
#declare -a ALGS=("essence" "shortest_path" "essence_split" "split_shortest_path" "essence_big_flows" "essence_stateless" "essence_weight_setting" "essence_split_multiple_labels")
declare -a ALGS=("shortest_path" "split_shortest_path" "essence" "essence_split" "essence_big_flows" "essence_stateless" "essence_weight_setting" "essence_split_multiple_labels")
RUN_OMNET_JOBS=":1"
if [ "$RUN_SIMULATION" = "true" ]; then
    for TOPO in "${TOPOS[@]}"; do
        topo_without_type="${TOPO::-5}"
        topo_without_type_and_zoo="${topo_without_type:4}"
        for ALG in "${ALGS[@]}"; do
            # First create all the necessary files$SYNC_DIR/${topo_without_type_and_zoo})
            FILE_GENERATE_ID=$(sbatch --parsable essence_generate.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL $OMNET_RESULTS_DIR $FAILURE_SCENARIOS $SYNC_DIR${topo_without_type_and_zoo}/$ALG $experiment_name)
            #for ((i=0;i<FAILURE_SCENARIOS;i++)); do
                #RUN_ID=$(sbatch --parsable --dependency=afterok:$FILE_GENERATE_ID essence_execute.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL $OMNET_RESULTS_DIR "scenario_"$i $SYNC_DIR${topo_without_type_and_zoo}/$ALG)
                #RUN_OMNET_JOBS="$RUN_OMNET_JOBS:$RUN_ID"
            #done
            RUN_ID=$(sbatch --parsable --dependency=afterok:$FILE_GENERATE_ID essence_execute.sh $TOPO_DIR$TOPO $DEMANDS_DIR${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL $OMNET_RESULTS_DIR General $SYNC_DIR${topo_without_type_and_zoo}/$ALG)
            RUN_OMNET_JOBS="$RUN_OMNET_JOBS:$RUN_ID"
        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    sbatch --dependency=afterok$RUN_OMNET_JOBS make_plots.sh $OMNET_RESULTS_DIR $PLOT_DIR
fi
