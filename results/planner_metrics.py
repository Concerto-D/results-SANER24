import os
import pandas as pd
from tabulate import tabulate

# Function to calculate the required averages and sums
def calculate_averages_and_sums(file_path):
    # Read the CSV data into a pandas DataFrame
    df = pd.read_csv(file_path)
    try:
        grouped_data = df.groupby(['node', 'operation', 'nworker'])[['out_local_msgs', 'out_remote_msgs', 'inf_constraints', 'gen_instructions']].mean().reset_index()
        result = grouped_data.groupby(['operation', 'nworker'])[['out_local_msgs', 'out_remote_msgs', 'inf_constraints', 'gen_instructions']].sum()
    except:
        grouped_data = df.groupby(['node', 'operation', 'nlistener'])[['out_local_msgs', 'out_remote_msgs', 'inf_constraints', 'gen_instructions']].mean().reset_index()
        result = grouped_data.groupby(['operation', 'nlistener'])[['out_local_msgs', 'out_remote_msgs', 'inf_constraints', 'gen_instructions']].sum()
    return result

def main(case, myscenario):
    # Directory path containing your CSV files
    directory_path = f'./{case}/ballet/planner'

    # List all the CSV files in the directory
    csv_files = [file for file in os.listdir(directory_path) if file.endswith('.csv')]

    # Initialize dictionaries to store aggregated data
    data_by_scenario = {}

    # Loop through each CSV file and collect the aggregated data
    for file in csv_files:
        file_path = os.path.join(directory_path, file)
        filename = file.replace(".csv", "_csv")
        scenario, case, sites_str = filename.split('_')[1:4]
        sites = int(sites_str)
        if scenario == myscenario:
            result = calculate_averages_and_sums(file_path)
            result.insert(0, '#site', sites)
            result['total_messages'] = result['out_local_msgs'] + result['out_remote_msgs']
            result.drop(columns=['out_local_msgs', 'out_remote_msgs'], inplace=True)
            data_by_scenario.setdefault((case, scenario), []).append(result)
    
    def merge_dataframes(dataframes):
        if not dataframes:
            return pd.DataFrame()
        try:
            return pd.concat(dataframes).groupby(['operation', 'nworker']).sum()
        except:
            return pd.concat(dataframes).groupby(['operation', 'nlistener']).sum()

    # Merge data for each case, scenario, and number of sites
    final_data = merge_dataframes([df for lst in data_by_scenario.values() for df in lst])
    final_data.insert(0, 'case', case)
    final_data.insert(1, 'scenario', myscenario)

    # Print the final tables
    print(tabulate(final_data, headers='keys', tablefmt='fancy_grid', showindex=False))
    print("\n")

if __name__ == "__main__":
    main("openstack","deploy")
    main("openstack","update")
    main("cps","deploy")
    main("cps","update")
