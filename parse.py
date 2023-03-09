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

    # Get max util and avg util
    max_util = 0
    avg_util = 0
    for row in utilization_rows.iterrows():
        val = float(row[1]["value"])
        if val > max_util:
            max_util = val
        avg_util += val
    avg_util /= len(utilization_rows)

    results = {}
    results["network"] = args.name
    results["alg"] = args.algorithm
    results["avg_util"] = avg_util
    results["max_util"] = max_util
    with open(args.output_file, "w") as f:
        json.dump(results, f)

    # DROPPED PACKETS FROM CONGESTION
    # TODO: Implement
    # DROPPED PACKETS FROM NO NEXT HOP
    # TODO: Implement
    # CONNECTIVITY
    # TODO: Implement

def to_link(module: str) -> tuple[str,str]:
    source: str = re.search("[^\.]*\.([^\.]*)\..*", module)[1]
    target = next(x for x in re.search(f".*\.([^\.]*)___{source}|.*{source}___(.*)", module).groups() if x is not None)
    return (source, target)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--output_file", type=str, required=True)
    parser.add_argument("--name", type=str, required=True)
    parser.add_argument("--algorithm", type=str, required=True)

    args = parser.parse_args()
    main(args)