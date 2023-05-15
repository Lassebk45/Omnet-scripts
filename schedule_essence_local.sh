#!/bin/bash

RUN_SIMULATION="true"

PARSE_RESULTS="true"

MAKE_PLOTS="true"

ESSENCE_DIR="/home/lasse/projects/p10/"

TOPO_DIR="experiments/debug_topologies/"

OMNET_RESULTS_DIR="/home/lasse/omnet_results/"

DEMANDS_DIR="temporal_demands/"

PACKET_SIZE="64"

SCALER="10"

ZERO_LATENCY=""

UPDATE_INTERVAL="8"

TIME_SCALE="0.0002"

OMNET_INPUT_FILES_DIR="/home/lasse/projects/inet/zoo/"

INET_DIR="/home/lasse/projects/inet/"

SCRIPTS_DIR="/home/lasse/projects/Omnet-scripts/"

PLOT_DIR="/home/lasse/plots/"

DEMAND_SCALER="0.4"

WRITE_INTERVAL="4"

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
declare -a ALGS=("essence" "essence_precomputed" "essence_stateless")
if [ "$RUN_SIMULATION" = "true" ]; then
    for TOPO in "${TOPOS[@]}"; do
        topo_without_type="${TOPO::-5}"
        topo_without_type_and_zoo="${topo_without_type:4}"
        for ALG in "${ALGS[@]}"; do
            #./essence.sh $TOPO_DIR$TOPO "temporal_demands/"${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL
            #./parse.sh $topo_without_type_and_zoo $ALG $OMNET_INPUT_FILES_DIR$topo_without_type_and_zoo/$ALG/results/ $OMNET_RESULTS_DIR
            echo "placeholder"
        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    ./make_plots.sh $OMNET_RESULTS_DIR $PLOT_DIR
fi


