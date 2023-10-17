# Results for SANER24

## Plan inference
The repository "planner_cp_files/" contains the MiniZinc models and the associated generated plans for the various reconfiguration cases.
- In "minizinc/", directories "<case>_planning_<scenario>_<n>" contains the models for planning the <scenario> on a <case> assembly of <n> sites.
- In "plans/", directories "<case>_planning_<scenario>_<n>" contains the reconfiguration plan for <scenario> on a <case> assembly of <n> sites.

## Experiment results
The repository "results/" contains the results from experiments conducted on two different systems: 
 - Cyber Physical System (CPS) and 
 - OpenStack (cluster of databases with Galera).
The experiments focus on reconfigurations, including deployment and updates, for both systems. The results are organized into the following subdirectories:

In addition, this directory include several scripts that were used for producing the tables of the paper. 
- planner_metrics.py was used to produce Table 2. It shows the number of messages, constraints and instructions for each case and scenario;
- planner_summary.py was used to produce Table 4. It shows the decomposition in time of the planner phases for each case, scenario and number of sites.
- global_summary.py was used to produce Table 1 and Table 3. It shows the average execution time (and standard deviation) for Ballet (Planner and Executor) for each case, scenario and number of sites.
Use `python <script.py>` to run them. 

Note that the scripts use the `tabulate` library. You must install it first by executing `pip install tabulate`

### CPS
"cps/"contains the results of reconfigurations for the Cyber Physical System case. It includes two subdirectories:
- ballet: This subdirectory contains results related to the "Ballet" system. The experiments cover both the planner and the executor of Ballet.
- muse: The "muse/" subdirectory contains results specifically related to the "Muse" system. The experiments conducted on the Muse system have been recorded in this directory.

### OpenStack
"openstack/" contains the results of reconfigurations for the Galera cluster running on OpenStack. It also includes two subdirectories:
- ballet: This subdirectory contains results related to the "Ballet" system when used in conjunction with the Galera cluster. The experiments cover both the planner and the executor of Ballet in this context.
- muse: The "muse/" subdirectory contains results related to the "Muse" system as applied to the Galera cluster. The experiments and findings regarding the Muse system's behavior within the Galera context are documented here.
