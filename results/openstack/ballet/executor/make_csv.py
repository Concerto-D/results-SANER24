import os
import yaml
import csv

def extract_data_from_yaml(yaml_path):
    with open(yaml_path, 'r') as file:
        yaml_data = yaml.safe_load(file)
        
    nb_scaling_sites = yaml_data["expe_parameters"]["nb_scaling_sites"]
    deploy_time = yaml_data["global_results"]["max_deploy_time"]
    update_time = yaml_data["global_results"]["max_update_time"]

    return ("deploy", nb_scaling_sites, deploy_time, "update", nb_scaling_sites, update_time)

def process_yaml_files(directory_path):
    csv_data = []

    for filename in os.listdir(directory_path):
        if filename.endswith(".yml") or filename.endswith(".yaml"):
            yaml_path = os.path.join(directory_path, filename)
            (op1, nb1, t1, op2, nb2, t2) = extract_data_from_yaml(yaml_path)
            csv_data.append((op1, nb1, t1))
            csv_data.append((op2, nb2, t2))
            
    def get_n_value(triplet):
        return triplet[2]

    # Sort the list of triplets by the 'n' value
    csv_data = sorted(csv_data, key=lambda x: (x[0], x[1]))
    csv_data.insert(0, ("Operation", "Scaling Sites", "Time"))
    return csv_data

def write_to_csv(csv_data, output_file):
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(csv_data)

if __name__ == "__main__":
    input_directory = "."
    output_csv_file = "output.csv"

    data_for_csv = process_yaml_files(input_directory)
    write_to_csv(data_for_csv, output_csv_file)