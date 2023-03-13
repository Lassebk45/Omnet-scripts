#!/bin/bash

# Make sure that OMNET_INPUT_FILES_DIR is included in .nedfolders in your INET_DIR as a relative path from .nedfolders. In this case, add ../omnet_input.

# Also make sure that OMNET_INPUT_FILES_DIR contains a file named package.ned with only the line "package inet.zoo"

# Go to INET_DIR and run "make makefiles" and "make"

CREATE_CONFS="true"

CREATE_OMNET_INPUT="true"

RUN_OMNET="true"

PARSE_RESULTS="true"

MAKE_PLOTS="true"

MPLS_KIT_DIR="/nfs/home/student.aau.dk/lkar18/p9-main/"

TOPO_DIR="cluster_topologies/"

CONFS_DIR="confs/"

PARSED_RESULTS_DIR="/nfs/home/student.aau.dk/lkar18/omnet_results/"

DEMANDS_DIR="demands/"

THRESHOLD="0"

PACKET_SIZE="640"

SCALER="0.1"

ZERO_LATENCY="--zero_latency"

TAKE_PERCENT="0.9"

OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/lkar18/omnet_input/"

INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"

SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts/"

PLOT_DIR="/nfs/home/student.aau.dk/lkar18/plots/"

declare -a ALGS=("rsvp-fn" "inout_disjoint_old" "rmpls")

declare -a ALGS_SHORT=("rsvp" "inout_disjoint_old" "rmpls")

declare -a ALG_CONFS=("conf_rsvp-fn.yml" "conf_inout_disjoint_old_max-mem=3.yml" "conf_rmpls.yml")

cd $MPLS_KIT_DIR/$TOPO_DIR

TOPOS=(*)

cd $SCRIPTS_DIR

DEMANDS=()

TOPO_RE='.*zoo_(.*).json'
for i in "${!TOPOS[@]}"; do
    if [[ ${TOPOS[$i]} =~ $TOPO_RE ]] ; then
        DEMANDS+=(${BASH_REMATCH[1]}"_0000.yml")
    fi
done

# Create confs
CREATE_CONFS_JOBS=":1"
if [ "$CREATE_CONFS" = "true" ]; then
    for i in "${!TOPOS[@]}"; do
        for j in "${!ALGS[@]}"; do
            DEMAND=${DEMANDS[$i]}
            TOPO=${TOPOS[$i]}
            ALG=${ALGS[$j]}
            CREATE_CONFS_JOBS="$CREATE_CONFS_JOBS:$(sbatch --parsable create_confs.sh $MPLS_KIT_DIR $TOPO_DIR $TOPO $CONFS_DIR $DEMANDS_DIR $DEMAND $ALG $THRESHOLD)"
        done
    done
fi

echo $CREATE_CONFS_JOBS

# Create omnet input files
CREATE_OMNET_INPUT_JOBS=":1"
if [ "$CREATE_OMNET_INPUT" = "true" ]; then
    for i in "${!TOPOS[@]}"; do
        for j in "${!ALGS[@]}"; do
            TOPO=${TOPOS[$i]}
            ALG=${ALGS[$j]}
            CONF=${ALG_CONFS[$j]}
            TOPO_NAME="${TOPOS[$i]}"
            TOPO_NAME="${TOPO_NAME::-5}"
            CREATE_OMNET_INPUT_JOBS="$CREATE_OMNET_INPUT_JOBS:$(sbatch --parsable --dependency=afterok$CREATE_CONFS_JOBS create_omnet_input.sh $MPLS_KIT_DIR "$CONFS_DIR""$TOPO_NAME/""$CONF" $TAKE_PERCENT $ZERO_LATENCY $SCALER $PACKET_SIZE $OMNET_INPUT_FILES_DIR $TOPO_NAME)"
        done
    done
fi

echo $CREATE_OMNET_INPUT_JOBS

# RUN SIMULATIONS
RUN_OMNET_JOBS=":1"
if [ "$RUN_OMNET" = "true" ]; then
    for i in "${!TOPOS[@]}"; do
        for ALG in ${ALGS_SHORT[@]}; do
            TOPO_NAME="${TOPOS[$i]}"
            TOPO_NAME="${TOPO_NAME::-5}"
            RUN_OMNET_JOBS="$RUN_OMNET_JOBS:$(sbatch --parsable --dependency=afterok$CREATE_OMNET_INPUT_JOBS run_omnet.sh $OMNET_INPUT_FILES_DIR/$TOPO_NAME/$ALG)"
        done
    done
fi

echo $RUN_OMNET_JOBS

# PARSE RESULTS
PARSE_RESULTS_JOBS=":1"
if [ "$PARSE_RESULTS" = "true" ]; then
    for i in "${!TOPOS[@]}"; do
        for j in ${!ALGS_SHORT[@]}; do
            ALG_SHORT="${ALGS_SHORT[$j]}"
            ALG="${ALGS[$j]}"
            TOPO_NAME="${TOPOS[$i]}"
            TOPO_NAME="${TOPO_NAME::-5}"
            PARSE_RESULTS_JOBS="$PARSE_RESULTS_JOBS:$(sbatch --parsable --dependency=afterok$RUN_OMNET_JOBS parse.sh $TOPO_NAME $ALG $ALG_SHORT $OMNET_INPUT_FILES_DIR$TOPO_NAME/$ALG_SHORT/results/ $PARSED_RESULTS_DIR)"

        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    sbatch --dependency=afterok$PARSE_RESULTS_JOBS make_plots.sh $PARSED_RESULTS_DIR $PLOT_DIR
fi
