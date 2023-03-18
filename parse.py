import pandas as pd
import re
import json
import argparse
import sys
import os

def main(args):

    # load data
    df = pd.read_csv(sys.stdin)

    # UTILIZATION
    utilization_rows = df[df['name'].astype(str).str.contains('utilization:last') & df['type'].astype(str).str.contains('scalar') & ~df['value'].isnull()]

    # Append rows with the name of the link
    links = [to_link(utilization_rows.iloc[i]["module"]) for i in range(len(utilization_rows))]
    utilization_rows['Link'] = links

    ### GET RESULTS

    results = {}
    results["network"] = args.name
    results["alg"] = args.algorithm

    # Get max util and avg util
    max_util = 0
    avg_util = 0
    for row in utilization_rows.iterrows():
        val = float(row[1]["value"])
        if val > max_util:
            max_util = val
        avg_util += val
    avg_util /= len(utilization_rows)

    results["avg_util"] = avg_util
    results["max_util"] = max_util

    # Get packets entered into Network

    row = df[df['name'].astype(str).str.contains('packetsCreated:count')].iloc[[0]]

    results["packets_created"] = int(row["value"])

    # Get packets delivered to their target

    row = df[df['name'].astype(str).str.contains('packetsDelivered:count')].iloc[[0]]

    results["packets_delivered"] = int(row["value"])
    
    # Get dropped packages from queue overflow

    row = df[df['name'].astype(str).str.contains('packetDropReasonIsQueueOverflow:count')].iloc[[0]]

    results["packets_dropped_queue_overflow"] = int(row["value"])

    # Get Dropped packages from blackhole

    row = df[df['name'].astype(str).str.contains('packetDropReasonIsNoRouteFound:count')].iloc[[0]]

    results["packets_dropped_blackhole"] = int(row["value"])

    # Get number of packets that were either dropped or delivered. I.e. all packets created subtracted by the packets that are still in the network at when sim ends

    results["packets_accounted_for"] = results["packets_delivered"] + results["packets_dropped_queue_overflow"] + results["packets_dropped_blackhole"]

    # Get connectivity

    results["connectivity"] = results["packets_delivered"] / results["packets_accounted_for"]

    # WRITE RESULTS TO FILE
    _dir = args.output_dir
    if not os.path.exists(_dir):
        os.makedirs(_dir)
    with open(os.path.join(_dir, args.name + ".json"), "w") as f:
        json.dump(results, f)

def to_link(module: str) -> tuple[str,str]:
    source: str = re.search("[^\.]*\.([^\.]*)\..*", module)[1]
    target = next(x for x in re.search(f".*\.([^\.]*)___{source}|.*{source}___(.*)", module).groups() if x is not None)
    return (source, target)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--output_dir", type=str, required=True)
    parser.add_argument("--name", type=str, required=True)
    parser.add_argument("--algorithm", type=str, required=True)

    args = parser.parse_args()
    main(args)