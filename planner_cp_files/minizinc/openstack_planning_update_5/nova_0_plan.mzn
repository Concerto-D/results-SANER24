include "regular.mzn";
include "count.mzn";
enum STATE = {initiated, pulled, ready, deployed, interrupted};
enum BEHAVIOR = {deploy, interrupt, pause, update, uninstall, skip, dwait_keystone_0_uninstall, dwait_mariadb_worker_0_interrupt};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|deployed,<>,<>,<>,initiated,initiated,initiated,initiated
|deployed,<>,<>,pulled,<>,pulled,pulled,<>
|deployed,<>,ready,<>,<>,ready,<>,<>
|deployed,interrupted,<>,<>,<>,deployed,<>,<>
|<>,interrupted,ready,pulled,initiated,interrupted,<>,interrupted|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : service_status;
constraint forall (i in 1..10+1) (service_status[i] = enabled <->  states[i] = deployed);
array[1..10+1] of var STATUS : mariadb_service_status;
constraint forall (i in 1..10+1) (mariadb_service_status[i] = enabled <->  states[i] = pulled \/  states[i] = deployed \/  states[i] = ready);
array[1..10+1] of var STATUS : keystone_service_status;
constraint forall (i in 1..10+1) (keystone_service_status[i] = enabled <->  states[i] = deployed \/  states[i] = ready \/  states[i] = interrupted);
constraint states[1]=deployed;
constraint regular(sequence, transitions, deployed, {initiated,pulled,ready,deployed,interrupted});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);
constraint count (bhv in sequence) (bhv = dwait_keystone_0_uninstall) = 1;
constraint count (bhv in sequence) (bhv = dwait_mariadb_worker_0_interrupt) = 1;
constraint states[10 + 1] = deployed;
constraint count (v in states) (v = deployed) > 0;
constraint count (status in mariadb_service_status) (status = disabled) > 0;
constraint count (status in keystone_service_status) (status = disabled) > 0;


array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = initiated /\ behavior = deploy then
147
elseif state = pulled /\ behavior = deploy then
132
elseif state = ready /\ behavior = deploy then
52
elseif state = deployed /\ behavior = interrupt then
2
elseif state = interrupted /\ behavior = pause then
5
elseif state = interrupted /\ behavior = update then
5
elseif state = interrupted /\ behavior = uninstall then
10
elseif state = initiated /\ behavior = skip then
0
elseif state = pulled /\ behavior = skip then
0
elseif state = ready /\ behavior = skip then
0
elseif state = deployed /\ behavior = skip then
0
elseif state = interrupted /\ behavior = skip then
0
elseif state = initiated /\ behavior = dwait_keystone_0_uninstall then
0
elseif state = pulled /\ behavior = dwait_keystone_0_uninstall then
0
elseif state = ready /\ behavior = dwait_keystone_0_uninstall then
0
elseif state = deployed /\ behavior = dwait_keystone_0_uninstall then
0
elseif state = interrupted /\ behavior = dwait_keystone_0_uninstall then
0
elseif state = initiated /\ behavior = dwait_mariadb_worker_0_interrupt then
0
elseif state = pulled /\ behavior = dwait_mariadb_worker_0_interrupt then
0
elseif state = ready /\ behavior = dwait_mariadb_worker_0_interrupt then
0
elseif state = deployed /\ behavior = dwait_mariadb_worker_0_interrupt then
0
elseif state = interrupted /\ behavior = dwait_mariadb_worker_0_interrupt then
0
else 
2147483646
endif;

solve minimize sum(cost);