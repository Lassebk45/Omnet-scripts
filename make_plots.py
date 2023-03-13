import matplotlib.pyplot as plt
import argparse
import os
import json
import itertools

def main(args):
    data = {}

    for _dir, algorithm in [(os.path.join(args.input_dir, x), x) for x in os.listdir(args.input_dir) if os.path.isdir(os.path.join(args.input_dir, x))]:
        data[algorithm] = {}
        for run in [os.path.join(_dir, x) for x in os.listdir(_dir) if os.path.isfile(os.path.join(_dir, x))]:
            with open(run, "r") as f:
                d = json.load(f)
            topology = d["network"]
            data[algorithm][topology] = d

    # Iterater for using different markers on different plots

    marker = itertools.cycle((',', '+', '.', 'o', '*')) 

    # max utilization plot

    max_util = {}

    for algorithm, algorithm_data in data.items():
        max_util[algorithm] = []
        for topology_data in algorithm_data.values():
            max_util[algorithm].append(topology_data["max_util"])
        max_util[algorithm] = sorted(max_util[algorithm])
    
    fig = plt.figure()
    ax1 = fig.add_subplot(111)
    for algorithm, max_util_data in max_util.items():
        ax1.scatter(range(len(max_util_data)), max_util_data, label=algorithm, marker = next(marker))
    
    ax1.legend()
    output_path = os.path.join(args.output_dir, "max_util.pdf")
    plt.savefig(output_path, format="pdf")
    
    # connectivity plot

    connectivity = {}

    for algorithm, algorithm_data in data.items():
        connectivity[algorithm] = []
        for topology_data in algorithm_data.values():
            connectivity[algorithm].append(topology_data["connectivity"])
        connectivity[algorithm] = sorted(connectivity[algorithm])
    
    fig = plt.figure()
    ax1 = fig.add_subplot(111)
    for algorithm, connectivity_data in connectivity.items():
        ax1.scatter(range(len(connectivity_data)), connectivity_data, label=algorithm, marker = next(marker))
    
    ax1.legend()
    output_path = os.path.join(args.output_dir, "connectivity.pdf")
    plt.savefig(output_path, format="pdf")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_dir", type=str, required=True)
    parser.add_argument("--output_dir", type=str, required=True)

    args = parser.parse_args()
    main(args)
