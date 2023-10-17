import os
import csv
import yaml
import numpy as np
from tabulate import tabulate

def find_max(csv_file, operation):
    data = {}
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row['operation'] == operation:
                node = row['node']
                total_time = float(row['total_time'])
                if (node) not in data:
                    data[node] = []
                data[node].append(total_time)
    max_average_node, max_average = find_max_average(data)
    return max_average_node
                
                
def find_max_average(data):
    max_average_node = None
    max_average = float('-inf')
    for node, times in data.items():
        average_time = sum(times) / len(times)
        if average_time > max_average:
            max_average = average_time
            max_average_node = node
    return max_average_node, max_average


def extract_csv_data(csv_file, operation):
    data = {}
    max_node = find_max(csv_file, operation)
    
    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row['operation'] == operation and row['node']==max_node:
                try:
                    nworker = int(row['nworker'])
                except:
                    nworker = int(row['nlistener'])
                operation = row['operation']
                total_time = float(row['total_time'])
                if (nworker, operation) not in data:
                    data[(nworker, operation)] = []
                data[(nworker, operation)].append(total_time)
    return data

def extract_yaml_data(yaml_file):
    with open(yaml_file, 'r') as file:
        content = yaml.safe_load(file)
        scaling_sites = content['expe_parameters']['nb_scaling_sites']
        max_deploy_time = content['global_results']['max_deploy_time']
        max_update_time = content['global_results']['max_update_time']
    return scaling_sites, max_deploy_time, max_update_time

def calculate_avg_std(data):
    avg = np.mean(data)
    std = np.std(data)
    return avg, std

def main(operation,case):
    planner_dir = f'./{case}/ballet/planner'
    concerto_d_dir = f'./{case}/ballet/executor'
    muse_dir = f'./{case}/muse'

    # Step 1: Extract data from CSV files in the planner directory
    planner_data = {}
    for filename in os.listdir(planner_dir):
        if filename.endswith('.csv'):
            csv_file = os.path.join(planner_dir, filename)
            data = extract_csv_data(csv_file, operation)
            planner_data.update(data)

    # Step 2: Extract data from YAML files in the results-execution-concerto_d directory
    concerto_d_data = {}
    for filename in os.listdir(concerto_d_dir):
        if filename.endswith('.yaml'):
            yaml_file = os.path.join(concerto_d_dir, filename)
            scaling_sites, max_deploy_time, max_update_time = extract_yaml_data(yaml_file)
            nworker = int(scaling_sites)
            if not (nworker, 'deploy') in concerto_d_data.keys():
                concerto_d_data[(nworker, 'deploy')] = list()
            if not (nworker, 'update') in concerto_d_data.keys():
                concerto_d_data[(nworker, 'update')] = list()
            concerto_d_data[(nworker, 'deploy')].append(max_deploy_time)
            concerto_d_data[(nworker, 'update')].append(max_update_time)

    # Step 3: Extract data from YAML files in the results-execution-muse directory
    muse_data = {}
    for filename in os.listdir(muse_dir):
        if filename.endswith('.yaml'):
            yaml_file = os.path.join(muse_dir, filename)
            scaling_sites, max_deploy_time, max_update_time = extract_yaml_data(yaml_file)
            nworker = int(scaling_sites)
            if not (nworker, 'deploy') in muse_data.keys():
                muse_data[(nworker, 'deploy')] = list()
            if not (nworker, 'update') in muse_data.keys():
                muse_data[(nworker, 'update')] = list()
            muse_data[(nworker, 'deploy')].append(max_deploy_time)
            muse_data[(nworker, 'update')].append(max_update_time)

    # Step 4: Generate the table
    table_data = []
    for (nworker, op) in sorted(set(list(planner_data.keys()) + list(concerto_d_data.keys()))):
        if operation == op:
            planner_times = planner_data.get((nworker, operation), [])
            concerto_d_times = concerto_d_data.get((nworker, operation), [])
            muse_times = muse_data.get((nworker, operation), [])
        else:
            continue
        
        
        if planner_times != []:
            avg_planner, std_planner = calculate_avg_std(planner_times)
        else:
            avg_planner, std_planner = 0,0
            
        
        if concerto_d_times != []:
            avg_executor, std_executor = calculate_avg_std(concerto_d_times)
        else:
            avg_executor, std_executor = 0,0
            
        
        if muse_times != []:
            avg_muse, std_muse = calculate_avg_std(muse_times)
        else:
            avg_muse, std_muse = 0,0
            
            
        total = avg_planner + avg_executor
        gain = 100 * (1 - total / avg_muse)
 
        table_data.append([case, nworker, operation, f"{avg_planner:.2f} ({std_planner:.2f})", f"{avg_executor:.2f} ({std_executor:.2f})",
                           f"{total:.2f}", f"{avg_muse:.2f}", f"{gain:.2f}"])

    headers = ["assembly","# site", "scenario", "avg planner (std)", "avg executor (std)", "total", "muse", "gain"]
    print(tabulate(table_data, headers=headers, tablefmt="fancy_grid"))

if __name__ == "__main__":
    main("deploy","openstack")
    main("update","openstack")
    main("deploy","cps")
    main("update","cps")
