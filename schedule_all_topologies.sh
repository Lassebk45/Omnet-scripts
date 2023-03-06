#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in INET_DIR as a relative path. In this case, add ../omnet_input

# Also make sure that OMNET_INPUT_FILES_DIR contains a file name package.ned with only the line "package inet.omnet_input"

# Afterwards run make makefiles in inet and make

CREATE_CONFS="false"

CREATE_OMNET_INPUT="false"

RUN_OMNET="true"

PARSE_RESULTS="true"

YOUR_NAME="lkar18"

MPLS_KIT_DIR="p9-main"

TOPO_DIR="topologies"

CONFS_DIR="confs"

RESULTS_DIR="results"

DEMANDS_DIR="demands"

THRESHOLD="3"

PACKET_SIZE="640"

SCALER="0.1"

ZERO_LATENCY="--zero_latency"

TAKE_PERCENT="0.9"

OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/$YOUR_NAME/omnet_input"

INET_DIR="/nfs/home/student.aau.dk/$YOUR_NAME/inet"

declare -a StringArray=("rsvp-fn")

for TOPO in $(ls $MPLS_KIT_DIR/$TOPO_DIR | head -n 1) ; do
    TOPO_RE='.*zoo_(.*).json'

    if [[ $TOPO =~ $TOPO_RE ]] ; then
        DEMAND=${BASH_REMATCH[1]}"_0000.yml"
    fi

    for ALG in ${StringArray[@]}; do
        sbatch Omnet-scripts/schedule_topology.sh $MPLS_KIT_DIR $TOPO_DIR $CONFS_DIR $RESULTS_DIR $DEMANDS_DIR $THRESHOLD $PACKET_SIZE $SCALER $ZERO_LATENCY $TAKE_PERCENT $OMNET_INPUT_FILES_DIR $TOPO $DEMAND $ALG $INET_DIR $CREATE_CONFS $CREATE_OMNET_INPUT $RUN_OMNET $PARSE_RESULTS

    done
done
