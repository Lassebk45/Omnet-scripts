import pandas as pd
import re
import json
import argparse
import sys
import os

def main(args):
    # load data
    df = pd.read_csv(sys.stdin)


    ### GET RESULTS
    results = {}
    results["network"] = args.name
    results["alg"] = args.algorithm


    # LAST RECORDINGS
    # Utilization
    last_utilization_rows = df[df['name'].astype(str).str.contains('utilization:last') & df['type'].astype(str).str.contains('scalar') & ~df['value'].isnull()]

    # Append rows with the name of the link
    links = [to_link(last_utilization_rows.iloc[i]["module"]) for i in range(len(last_utilization_rows))]
    last_utilization_rows['Link'] = links



    # Get max util and avg util
    max_util = 0
    avg_util = 0
    for row in last_utilization_rows.iterrows():
        val = float(row[1]["value"])
        if val > max_util:
            max_util = val
        avg_util += val
    avg_util /= len(last_utilization_rows)
    results["avg_util"] = round(avg_util,4)
    results["max_util"] = round(max_util,4)

    # Get packets entered into Network
    row = df[df['name'].astype(str).str.contains('packetsCreatedCount')].iloc[[0]]
    results["packets_created"] = int(row["value"])


    # Get packets delivered to their target
    row = df[df['name'].astype(str).str.contains('packetsDeliveredCount')].iloc[[0]]
    results["packets_delivered"] = int(row["value"])


    # Get dropped packages from queue overflow
    row = df[df['name'].astype(str).str.contains('packetDropReasonIsQueueOverflowCount')].iloc[[0]]
    results["packets_dropped_queue_overflow"] = int(row["value"])

    # Get Dropped packages from blackhole
    row = df[df['name'].astype(str).str.contains('packetDropReasonIsNoRouteFoundCount')].iloc[[0]]
    results["packets_dropped_blackhole"] = int(row["value"])


    # Get number of packets that were either dropped or delivered. I.e. all packets created subtracted by the packets that are still in the network at when sim ends
    results["packets_accounted_for"] = results["packets_delivered"] + results["packets_dropped_queue_overflow"] + results["packets_dropped_blackhole"]


    # Get connectivity
    results["connectivity"] = results["packets_delivered"] / results["packets_accounted_for"]


    # Get queue overflow percentage of packets
    results["packets_dropped_queue_overflow_percentage"] = results["packets_dropped_queue_overflow"] / results["packets_accounted_for"]


    # Get blackhole dropped percentage of packets
    results["packets_dropped_blackhole_percentage"] = results["packets_dropped_blackhole"] / results["packets_accounted_for"]


    # Get top 5 largest links and print their utilization over time
    datarate_rows = df[df['name'].astype(str).str.contains('datarate') & df['module'].astype(str).str.contains('___') & df['type'].astype(str).str.contains('param')]
    datarate_rows["value"] = datarate_rows["value"].apply(lambda x: x.split('bps')[0])
    datarate_rows["value"] = datarate_rows["value"].apply(lambda x: float(x))
    datarate_rows = datarate_rows.sort_values(["value"], ascending=False)
    top_5_links_modules = datarate_rows.head(5)["module"].tolist()
    results["util_vectors"] = {}
    for link in map(lambda x: str(to_link(x)), top_5_links_modules):
        results["util_vectors"][link] = {}
    utilization_vector_rows = df[
        df['name'].astype(str).str.contains('utilization:vector') & df['module'].isin(top_5_links_modules) & ~df[
            'vectime' or 'vecvalue'].isnull()]
    links = [to_link(utilization_vector_rows.iloc[i]["module"]) for i in range(len(utilization_vector_rows))]
    utilization_vector_rows['link'] = links
    for row in utilization_vector_rows.iterrows():
        link = str(row[1]["link"])
        vectimes = map(lambda x: float(x), row[1]["vectime"].split(" "))
        vecvalues = map(lambda x: float(x), row[1]["vecvalue"].split(" "))
        for time, val in zip(vectimes, vecvalues):
            results["util_vectors"][link][round(time, 1)] = round(val, 4)


    # PACKETS ENTERED OVER TIME
    packets_entered_vector = df[
        df['name'].astype(str).str.contains('packetsCreatedVector') & ~df[
            'vectime' or 'vecvalue'].isnull()]
    results["packets_entered_vector"] = {}
    if not packets_entered_vector.empty:
        vectimes = map(lambda x: float(x), packets_entered_vector.head(1)["vectime"].tolist()[0].split(" "))
        vecvalues = map(lambda x: float(x), packets_entered_vector.head(1)["vecvalue"].tolist()[0].split(" "))
        for time, val in zip(vectimes, vecvalues):
            results["packets_entered_vector"][round(time, 1)] = int(val)


    # PACKETS DELIVERED OVER TIME
    packets_delivered_vector = df[
        df['name'].astype(str).str.contains('packetsDeliveredVector') & ~df[
            'vectime' or 'vecvalue'].isnull()]
    results["packets_delivered_vector"] = {}
    if not packets_entered_vector.empty:
        vectimes = map(lambda x: float(x), packets_delivered_vector.head(1)["vectime"].tolist()[0].split(" "))
        vecvalues = map(lambda x: float(x), packets_delivered_vector.head(1)["vecvalue"].tolist()[0].split(" "))
        for time, val in zip(vectimes, vecvalues):
            results["packets_delivered_vector"][round(time, 1)] = int(val)


    # PACKETS DROPPED FROM QUEUE OVERFLOW OVER TIME
    queue_overflow_vector = df[
        df['name'].astype(str).str.contains('packetDropReasonIsQueueOverflowVector') & ~df[
            'vectime' or 'vecvalue'].isnull()]
    results["queue_overflow_vector"] = {}
    if not queue_overflow_vector.empty:
        vectimes = map(lambda x: float(x), queue_overflow_vector.head(1)["vectime"].tolist()[0].split(" "))
        vecvalues = map(lambda x: float(x), queue_overflow_vector.head(1)["vecvalue"].tolist()[0].split(" "))
        for time, val in zip(vectimes, vecvalues):
            results["queue_overflow_vector"][round(time, 1)] = int(val)


    # BLACKHOLE DROPS OVER TIME
    blackhole_vector = df[
        df['name'].astype(str).str.contains('packetDropReasonIsNoRouteFoundVector') & ~df[
            'vectime' or 'vecvalue'].isnull()]
    results["blackhole_vector"] = {}
    if not blackhole_vector.empty:
        vectimes = map(lambda x: float(x), blackhole_vector.head(1)["vectime"].tolist()[0].split(" "))
        vecvalues = map(lambda x: float(x), blackhole_vector.head(1)["vecvalue"].tolist()[0].split(" "))
        for time, val in zip(vectimes, vecvalues):
            results["blackhole_vector"][round(time, 1)] = int(val)


    # PERCENTAGE PACKETS DROPPED FROM QUEUE OVERFLOW OVER TIME
    results["percentage_queue_overflow_vector"] = {}
    for time, overflowed_packets in results["queue_overflow_vector"].items():
        try:
            results["percentage_queue_overflow_vector"][time] = round(overflowed_packets / (
                        overflowed_packets + results["blackhole_vector"].get(time, 0) + results[
                    "packets_delivered_vector"].get(time, 0)), 3)
        except:
            results["percentage_queue_overflow_vector"][time] = 0

    # PERCENTAGE PACKETS DROPPED FROM BLACKHOLES OVER TIME
    results["percentage_blackhole_vector"] = {}
    for time, blackholed_packets in results["blackhole_vector"].items():
        try:
            results["percentage_blackhole_vector"][time] = round(blackholed_packets / (blackholed_packets + results["queue_overflow_vector"].get(time, 0) + results["packets_delivered_vector"].get(time, 0)), 3)
        except:
            results["percentage_blackhole_vector"][time] = 0

    # CONNECTIVITY OVER TIME
    # Connectivity is computed as <packets delivered> / (<packets delivered> + <packets dropped>)
    results["connectivity_vector"] = {}
    for time, packets_delivered in results["packets_delivered_vector"].items():
        results["connectivity_vector"][time] = round(packets_delivered / (packets_delivered + results["blackhole_vector"].get(time, 0) + results["queue_overflow_vector"].get(time, 0)), 3)


    # WRITE RESULTS TO FILE
    _dir = args.output_dir
    if not os.path.exists(_dir):
        os.makedirs(_dir)
    with open(os.path.join(_dir, args.name + ".json"), "w") as f:
        json.dump(results, f, indent=2)

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