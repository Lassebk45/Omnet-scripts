import matplotlib.pyplot as plt
import argparse
import os
import json
import itertools
from collections import defaultdict


def get_omnet_data_from_input(input_dir, args):
    data = {}
    topologies = [x for x in os.listdir(input_dir) if os.path.isdir(os.path.join(input_dir, x))]
    for topology in topologies:
        topology_path = os.path.join(input_dir, topology)

        # List for keeping track of scenarios that finished for all algorithms
        all_lists = []

        alg_dirs = [alg for alg in os.listdir(topology_path) if alg not in args.exclude_algorithms]

        if args.algorithms != []:
            found_algs = [x for x in args.algorithms if x in alg_dirs]
            if not set(found_algs) == set(args.algorithms):
                continue
            good_algs = args.algorithms
        else:
            good_algs = alg_dirs


        for algorithm in good_algs:
            algorithm_path = os.path.join(topology_path, algorithm)
            all_lists.append(os.listdir(algorithm_path))

        # Prune scenarios that didn't finish for some runs

        finished_for_all = set(all_lists[0])
        for s in all_lists[1:]:
            finished_for_all.intersection_update(s)

        if len(finished_for_all) == 0:
            continue
        
        #

        data[topology] = {}

        for algorithm in good_algs:
            algorithm_path = os.path.join(topology_path, algorithm)
            data[topology][algorithm] = {}


            for scenario in os.listdir(algorithm_path):
                if scenario in finished_for_all:
                    scenario_path = os.path.join(algorithm_path, scenario)
                    with open(scenario_path, "r") as f:
                        d = json.load(f)

                    data[topology][algorithm][scenario] = d
    
    return data
def main(args):

    # LOAD DATA
    data = {}

    if args.omnet_input_dir:
        data.update(get_omnet_data_from_input(args.omnet_input_dir, args))

    # Iterater for using different markers on different plots

    marker = itertools.cycle((',', '+', '.', 'o', '*'))

    def create_scalar_plot(scalar_name, plot_name):
        scalar_dict = {}
        data_points = defaultdict(list)
        for toplogy, algorithms in data.items():
            for algorithm, scenarios in algorithms.items():
                for scenario, d in scenarios.items():
                    data_points[algorithm].append(d[scalar_name])
        
        
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        for algorithm, scalar_data in data_points.items():
            #ax1.scatter(range(len(scalar_data)), sorted(scalar_data), label=algorithm, marker=next(marker), s=5)
            ax1.plot(range(len(scalar_data)), sorted(scalar_data), label=algorithm)
        ax1.legend(prop={"size": int(20 / len(data_points.items()))})
        output_path = os.path.join(args.output_dir, plot_name)
        plt.xlabel("Scenario")
        plt.ylabel(f"{scalar_name}")
        plt.title(f"All_scenarios-{scalar_name}")
        plt.savefig(output_path, format="pdf")
        plt.close()

    def create_util_vector_plot(outdir, topo_data):
        utilization_vector_data = topo_data["util_vectors"]
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        ax1.xaxis.set_major_locator(plt.MaxNLocator(12))
        for link, time_util_dict in utilization_vector_data.items():
            #ax1.scatter(time_util_dict.keys(), time_util_dict.values(), label=link, marker=next(marker), sizes=[len(time_util_dict.items())*5])
            ax1.plot(time_util_dict.keys(), time_util_dict.values(), label=link)
        ax1.legend()
        output_path = os.path.join(outdir, "util_vector.pdf")
        os.makedirs(outdir, exist_ok=True)
        plt.savefig(output_path, format="pdf")
        plt.close()

    def create_vector_plot(vector_name, topo_data, outdir, plot_file):
        vector_data = topo_data[vector_name]
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        ax1.xaxis.set_major_locator(plt.MaxNLocator(12))
        #ax1.scatter(vector_data.keys(), vector_data.values(), label=f'{topo_data["network"]}-{topo_data["alg"]}', marker=next(marker), sizes=[len(vector_data.items())*5])
        ax1.plot(vector_data.keys(), vector_data.values(), label=f'{topo_data["network"]}-{topo_data["alg"]}')
        ax1.legend()
        output_path = os.path.join(outdir, plot_file)
        os.makedirs(outdir, exist_ok=True)
        plt.savefig(output_path, format="pdf")
        plt.close()

    def create_topology_plot(scalar_name, plot_name, out_dir, topology, topology_data):
        os.makedirs(out_dir, exist_ok=True)
        scalar_dict = defaultdict(list)
        
        for algorithm, scenarios in topology_data.items():
            for d in scenarios.values():
                scalar_dict[algorithm].append(d[scalar_name])
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        for algorithm, scalar_data in scalar_dict.items():
            #ax1.scatter(range(len(scalar_data)), sorted(scalar_data), label=algorithm, marker=next(marker), s=5)
            ax1.plot(range(len(scalar_data)), sorted(scalar_data), label=algorithm)
        ax1.legend()
        output_path = os.path.join(out_dir, plot_name)
        plt.ylabel(f"{scalar_name}")
        plt.xlabel("Scenario")
        plt.title(f"{topology}-{scalar_name}")
        plt.savefig(output_path, format="pdf")
        plt.close()

    # Global scalar plots
    create_scalar_plot("max_util", "max_util_scalar.pdf")
    create_scalar_plot("avg_util", "avg_util_scalar.pdf")
    create_scalar_plot("connectivity", "connectivity_scalar.pdf")
    create_scalar_plot("packets_dropped_queue_overflow_percentage", "packets_dropped_queue_overflow_percentage_scalar.pdf")
    create_scalar_plot("packets_dropped_blackhole_percentage", "packets_dropped_blackhole_percentage_scalar.pdf")

    # Create per-topology plots
    #for topology, algorithms in data.items():
    #    topology_data = {}
    #    out_dir = os.path.join(args.output_dir, topology)
    #    create_topology_plot("max_util", f"{topology}_max_util_scalar.pdf", out_dir, topology, algorithms)
    #    create_topology_plot("avg_util", f"{topology}_avg_util_scalar.pdf", out_dir, topology, algorithms)
    #    create_topology_plot("connectivity", f"{topology}_connectivity_scalar.pdf", out_dir, topology, algorithms)
    #    create_topology_plot("packets_dropped_queue_overflow_percentage", f"{topology}_packets_dropped_queue_overflow_percentage_scalar.pdf", out_dir, topology, algorithms)
    #    create_topology_plot("packets_dropped_blackhole_percentage", f"{topology}_packets_dropped_blackhole_percentage_scalar.pdf", out_dir, topology, algorithms)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--omnet_input_dir", type=str, required=True)
    parser.add_argument("--output_dir", type=str, required=True)
    parser.add_argument("--exclude_algorithms", default="")
    parser.add_argument("--algorithms", default="")
    args = parser.parse_args()


    if args.exclude_algorithms != "":
        args.exclude_algorithms = args.exclude_algorithms.split(" ")
    else:
        args.exclude_algorithms = []
    
    if args.algorithms != "":
        args.algorithms = args.algorithms.split(" ")
    else:
        args.algorithms = []
    print(args.algorithms)
    main(args)
