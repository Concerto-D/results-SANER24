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
    data_solving = {}
    data_comms = {}
    data_total = {}
    
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
                solving_time = float(row['solving_time'])
                send_time = float(row['sending_time']) 
                get_time = float(row['get_msg_time'])
                comms_time = send_time + get_time
                if (nworker, operation) not in data_solving:
                    data_solving[(nworker, operation)] = []
                if (nworker, operation) not in data_comms:
                    data_comms[(nworker, operation)] = []
                if (nworker, operation) not in data_total:
                    data_total[(nworker, operation)] = []
                    
                data_total[(nworker, operation)].append(total_time)
                data_solving[(nworker, operation)].append(solving_time)
                data_comms[(nworker, operation)].append(comms_time)
    return data_solving, data_comms, data_total

def calculate_avg_std(data):
    avg = np.mean(data)
    std = np.std(data)
    return avg, std

def main(operation, case):
    planner_dir = f'./{case}/ballet/planner'

    # Step 1: Extract data from CSV files in the planner directory
    planner_data_solving = {}
    planner_data_comms = {}
    planner_data_total = {}
    for filename in os.listdir(planner_dir):
        if filename.endswith('.csv'):
            csv_file = os.path.join(planner_dir, filename)
            data_solving, data_comms, data_total = extract_csv_data(csv_file, operation)
            planner_data_solving.update(data_solving)
            planner_data_comms.update(data_comms)
            planner_data_total.update(data_total)
    # Step 2: Generate the table
    table_data = []
    for (nworker, op) in sorted(set(list(planner_data_solving.keys()) + list(planner_data_comms.keys()) + list(planner_data_total.keys()))):
        if operation == op:
            planner_total = planner_data_total.get((nworker, operation), [])
            planner_solving = planner_data_solving.get((nworker, operation), [])
            planner_comms = planner_data_comms.get((nworker, operation), [])
        else:
            continue
        
        if planner_solving != []:
            avg_solving, std_solving = calculate_avg_std(planner_solving)
        else:
            avg_solving, std_solving = 0,0
            
        if planner_comms != []:
            avg_comms, std_comms = calculate_avg_std(planner_comms)
        else:
            avg_comms, std_comms = 0,0
            
        if planner_total != []:
            avg_total, std_total = calculate_avg_std(planner_total)
        else:
            avg_total, std_total = 0,0
            
        table_data.append([case, nworker, operation, f"{avg_solving:.2f} ({std_solving:.2f})", f"{avg_comms:.2f} ({std_comms:.2f})", f"{avg_total:.2f} ({std_total:.2f})"])

    headers = ["assembly","# site", "scenario", "avg solving (std)", "avg communications (std)", "total"]
    print(tabulate(table_data, headers=headers, tablefmt="fancy_grid"))

if __name__ == "__main__":
    main("deploy","openstack")
    main("update","openstack")
    main("deploy","cps")
    main("update","cps")
