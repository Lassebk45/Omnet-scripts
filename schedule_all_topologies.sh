#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in your INET_DIR as a relative path from .nedfolders. In this case, add ../omnet_input.

# Also make sure that OMNET_INPUT_FILES_DIR contains a file named package.ned with only the line "package inet.omnet_input"

# Go to INET_DIR and run "make makefiles" and "make"

CREATE_CONFS="false"

CREATE_OMNET_INPUT="false"

RUN_OMNET="false"

PARSE_RESULTS="false"

GENERATE_PLOTS="true"

MPLS_KIT_DIR="/nfs/home/student.aau.dk/lkar18/p9-main"

TOPO_DIR="topologies"

CONFS_DIR="confs"

PARSED_RESULTS_DIR="/nfs/home/student.aau.dk/lkar18/omnet_results"

DEMANDS_DIR="demands"

THRESHOLD="3"

PACKET_SIZE="640"

SCALER="0.1"

ZERO_LATENCY="--zero_latency"

TAKE_PERCENT="0.9"

OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/lkar18/omnet_input"

INET_DIR="/nfs/home/student.aau.dk/lkar18/inet"

NUM_TOPOLOGIES=50

SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts"

PLOT_DIR="/nfs/home/student.aau.dk/lkar18/plots"

declare -a StringArray=("rsvp-fn")

for TOPO in $(ls $MPLS_KIT_DIR/$TOPO_DIR | head -n $NUM_TOPOLOGIES) ; do
    TOPO_RE='.*zoo_(.*).json'

    if [[ $TOPO =~ $TOPO_RE ]] ; then
        DEMAND=${BASH_REMATCH[1]}"_0000.yml"
    fi

    for ALG in ${StringArray[@]}; do
        sbatch $SCRIPTS_DIR/schedule_topology.sh $MPLS_KIT_DIR $TOPO_DIR $CONFS_DIR $PARSED_RESULTS_DIR $DEMANDS_DIR $THRESHOLD $PACKET_SIZE $SCALER $ZERO_LATENCY $TAKE_PERCENT $OMNET_INPUT_FILES_DIR $TOPO $DEMAND $ALG $INET_DIR $CREATE_CONFS $CREATE_OMNET_INPUT $RUN_OMNET $PARSE_RESULTS $SCRIPTS_DIR $GENERATE_PLOTS
    done
done


# Generate plots
#
if [ "$GENERATE_PLOTS" = "true" ]; then
    sbatch $SCRIPTS_DIR/make_plots.sh $SCRIPTS_DIR $PARSED_RESULTS_DIR $PLOT_DIR $MPLS_KIT_DIR
fi