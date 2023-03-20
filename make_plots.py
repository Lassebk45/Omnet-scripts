import matplotlib.pyplot as plt
import argparse
import os
import json
import itertools


def get_omnet_data_from_input(input_dir):
    data = {}
    for _dir, algorithm in [(os.path.join(input_dir, x), x) for x in os.listdir(input_dir) if os.path.isdir(os.path.join(input_dir, x))]:
            data[algorithm] = {}
            for runs in [os.path.join(_dir, x) for x in os.listdir(_dir) if ".json" in os.path.join(_dir, x)]:
                with open(runs, "r") as f:
                    d = json.load(f)
                topology = d["network"]
                data[algorithm][topology] = d
    return data

def main(args):

    # LOAD DATA
    data = {}

    if args.omnet_input_dir:
        data.update(get_omnet_data_from_input(args.omnet_input_dir))

    # Iterater for using different markers on different plots

    marker = itertools.cycle((',', '+', '.', 'o', '*'))

    def create_scalar_plot(scalar_name, plot_name):
        scalar_dict = {}
        for algorithm, algorithm_data in data.items():
            scalar_dict[algorithm] = []
            for topology_data in algorithm_data.values():
                scalar_dict[algorithm].append(topology_data[scalar_name])
            scalar_dict[algorithm] = sorted(scalar_dict[algorithm])
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        for algorithm, scalar_data in scalar_dict.items():
            ax1.scatter(range(len(scalar_data)), scalar_data, label=algorithm, marker=next(marker))
        ax1.legend()
        output_path = os.path.join(args.output_dir, plot_name)
        plt.savefig(output_path, format="pdf")
        plt.close()

    def create_util_vector_plot(outdir, topo_data):
        utilization_vector_data = topo_data["util_vectors"]
        fig = plt.figure()
        ax1 = fig.add_subplot(111)
        ax1.xaxis.set_major_locator(plt.MaxNLocator(12))
        for link, time_util_dict in utilization_vector_data.items():
            ax1.scatter(time_util_dict.keys(), time_util_dict.values(), label=link, marker=next(marker))
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
        ax1.scatter(vector_data.keys(), vector_data.values(), label=f'{topo_data["network"]}-{topo_data["alg"]}', marker=next(marker))
        ax1.legend()
        output_path = os.path.join(outdir, plot_file)
        os.makedirs(outdir, exist_ok=True)
        plt.savefig(output_path, format="pdf")
        plt.close()

    # PLOTS USING LAST RECORDINGS
    create_scalar_plot("max_util", "max_util_scalar.pdf")
    create_scalar_plot("avg_util", "avg_util_scalar.pdf")
    create_scalar_plot("connectivity", "connectivity_scalar.pdf")
    create_scalar_plot("packets_dropped_queue_overflow_percentage", "packets_dropped_queue_overflow_percentage_scalar.pdf")
    create_scalar_plot("packets_dropped_blackhole_percentage", "packets_dropped_blackhole_percentage_scalar.pdf")


    #PLOTS USING VECTORS OVER TIME
    for algorithm, topologies in data.items():
        for topology, topo_data in topologies.items():
            _dir = os.path.join(args.output_dir, algorithm, topology)
            create_util_vector_plot(_dir, topo_data)
            create_vector_plot("percentage_queue_overflow_vector", topo_data, _dir, "percentage_queue_overflow_vector.pdf")
            create_vector_plot("percentage_blackhole_vector", topo_data, _dir, "percentage_blackhole_vector.pdf")
            create_vector_plot("connectivity_vector", topo_data, _dir, "connectivity.pdf")
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--omnet_input_dir", type=str, required=True)
    parser.add_argument("--output_dir", type=str, required=True)

    args = parser.parse_args()
    main(args)
