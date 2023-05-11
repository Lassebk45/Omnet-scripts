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

TOPO_DIR="experiments/first_essence_experiments/topologies/"

CONFS_DIR="confs/"

OMNET_RESULTS_DIR="/nfs/home/student.aau.dk/lkar18/omnet_results/"

DEMANDS_DIR="temporal_demands/"

#THRESHOLD="0"

PACKET_SIZE="64"

SCALER="10"

ZERO_LATENCY=""

#TAKE_PERCENT="1"

UPDATE_INTERVAL="180"

TIME_SCALE="0.5"

OMNET_INPUT_FILES_DIR="/nfs/home/student.aau.dk/lkar18/omnet_input/"

INET_DIR="/nfs/home/student.aau.dk/lkar18/inet/"

SCRIPTS_DIR="/nfs/home/student.aau.dk/lkar18/Omnet-scripts/"

PLOT_DIR="/nfs/home/student.aau.dk/lkar18/plots/"

DEMAND_SCALER="0.4"

WRITE_INTERVAL="30"

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

# Create confs
CREATE_CONFS_JOBS=":1"
#if [ "$CREATE_CONFS" = "true" ]; then
 #   for i in "${!TOPOS[@]}"; do
  #      for j in "${!ALGS[@]}"; do
   #         DEMAND=${DEMANDS[$i]}
    #        TOPO=${TOPOS[$i]}
     #       ALG=${ALGS[$j]}
      #      CREATE_CONFS_JOBS="$CREATE_CONFS_JOBS:$(sbatch --parsable create_confs.sh $MPLS_KIT_DIR $TOPO_DIR $TOPO $CONFS_DIR $DEMANDS_DIR $DEMAND $ALG $THRESHOLD $MPLS_KIT_RESULTS_DIR)"
       # done
   # done
#fi

# Create omnet input files
CREATE_OMNET_INPUT_JOBS=":1"
#if [ "$CREATE_OMNET_INPUT" = "true" ]; then
 #   for TOPO in "${TOPOS[@]}"; do
  #      for ALG in "${ALGS[@]}"; do
   #         TOPO_NAME="${TOPO::-5}"
    #        CREATE_OMNET_INPUT_JOBS="$CREATE_OMNET_INPUT_JOBS:$(sbatch --parsable --dependency=afterok$CREATE_CONFS_JOBS create_omnet_input.sh $MPLS_KIT_DIR ${CONFS_DIR}${TOPO_NAME}/${ALG}.yml $TAKE_PERCENT $ZERO_LATENCY $SCALER $PACKET_SIZE $OMNET_INPUT_FILES_DIR $TOPO_NAME $ALG)"
     #   done
 #   done
#fi

# RUN SIMULATIONS
declare -a ALGS=("essence" "essence_precomputed" "essence_stateless")
PARSE_RESULTS_JOBS=":1"
if [ "$RUN_SIMULATION" = "true" ]; then
    for TOPO in "${TOPOS[@]}"; do
        topo_without_type="${TOPO::-5}"
        topo_without_type_and_zoo="${topo_without_type:4}"
        for ALG in "${ALGS[@]}"; do
            RUN_ID=$(sbatch --parsable essence.sh $TOPO_DIR$TOPO "temporal_demands/"${topo_without_type_and_zoo}_0000.yml $ALG $OMNET_INPUT_FILES_DIR $UPDATE_INTERVAL $TIME_SCALE $ESSENCE_DIR $SCALER $DEMAND_SCALER $WRITE_INTERVAL)
            PARSE_ID=$(sbatch --parsable --dependency=afterok:$RUN_ID parse.sh $topo_without_type_and_zoo $ALG $OMNET_INPUT_FILES_DIR$topo_without_type_and_zoo/$ALG/results/ $OMNET_RESULTS_DIR)
            PARSE_RESULTS_JOBS="$PARSE_RESULTS_JOBS:$PARSE_ID"
        done
    done
fi

if [ "$MAKE_PLOTS" = "true" ]; then
    sbatch --dependency=afterok$PARSE_RESULTS_JOBS make_plots.sh $OMNET_RESULTS_DIR $PLOT_DIR
fi

#RUN_MPLS_KIT_JOBS=":1"
#if [ "$RUN_MPLS_KIT" = "true" ]; then
#    for TOPO in "${TOPOS[@]}"; do
#        for ALG in ${ALGS[@]}; do
#            TOPO_NAME="${TOPO::-5}"
#            RUN_MPLS_KIT_JOBS="$RUN_MPLS_KIT_JOBS:$(sbatch --parsable --dependency=afterok$CREATE_CONFS_JOBS run_mpls_kit.sh ${CONFS_DIR}${TOPO_NAME}/${ALG}.yml $TAKE_PERCENT $MPLS_KIT_DIR)"
#        done
#    done
#fi

# PARSE RESULTS
#PARSE_RESULTS_JOBS=":1"
#if [ "$PARSE_RESULTS" = "true" ]; then
#    for TOPO in "${TOPOS[@]}"; do
#        for ALG in ${ALGS[@]}; do
#            topo_without_type="${TOPO::-5}"
#            topo_without_type_and_zoo="${topo_without_type:4}"
#            PARSE_RESULTS_JOBS="$PARSE_RESULTS_JOBS:$(sbatch --parsable --dependency=afterok$ESSENCE_JOBS parse.sh $topo_without_type_and_zoo $ALG $OMNET_INPUT_FILES_DIR$topo_without_type_and_zoo/$ALG/results/ $OMNET_RESULTS_DIR)"
#        done
#    done
#fi


