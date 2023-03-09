import matplotlib.pyplot as plt
import argparse
import os
import json
def main(args):
    data = []

    for file in [os.path.join(args.input_dir, x) for x in os.listdir(args.input_dir) if os.path.isfile(os.path.join(args.input_dir, x))]:
        with open(file, "r") as f:
            d = json.load(f)
        data.append(d)

    
    #max utilization plot

    data_points = list(map(lambda x: x["max_util"], sorted(data, key=lambda x: x["max_util"])))
    print("1")
    plt.scatter(range(len(data)), data_points)
    print("2")
    output_path = os.path.join(args.output_dir, "max_util.pdf")
    print("3")
    plt.savefig(output_path, format="pdf")
    print(output_path)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_dir", type=str, required=True)
    parser.add_argument("--output_dir", type=str, required=True)

    args = parser.parse_args()
    main(args)
