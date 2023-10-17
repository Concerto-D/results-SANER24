include "regular.mzn";
include "count.mzn";
enum STATE = {initiated, configured, bootstrapped, deployed, interrupted};
enum BEHAVIOR = {deploy, interrupt, pause, update, uninstall, skip, dwait_mariadb_master_interrupt};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|deployed,<>,<>,<>,initiated,initiated,initiated
|deployed,<>,<>,configured,<>,configured,configured
|deployed,<>,bootstrapped,<>,<>,bootstrapped,<>
|deployed,interrupted,<>,<>,<>,deployed,<>
|<>,interrupted,bootstrapped,configured,initiated,interrupted,<>|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : service_status;
constraint forall (i in 1..10+1) (service_status[i] = enabled <->  states[i] = deployed);
array[1..10+1] of var STATUS : haproxy_service_status;
constraint forall (i in 1..10+1) (haproxy_service_status[i] = enabled <->  states[i] = bootstrapped);
array[1..10+1] of var STATUS : common_service_status;
constraint forall (i in 1..10+1) (common_service_status[i] = enabled <->  states[i] = interrupted \/  states[i] = deployed);
array[1..10+1] of var STATUS : master_service_status;
constraint forall (i in 1..10+1) (master_service_status[i] = enabled <->  states[i] = deployed \/  states[i] = interrupted \/  states[i] = bootstrapped);
constraint states[1]=deployed;
constraint regular(sequence, transitions, deployed, {initiated,configured,bootstrapped,deployed,interrupted});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);
constraint count (bhv in sequence) (bhv = dwait_mariadb_master_interrupt) = 1;
constraint states[10 + 1] = deployed;
constraint count (v in states) (v = deployed) > 0;
constraint count (status in master_service_status) (status = disabled) > 0;


array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = initiated /\ behavior = deploy then
60
elseif state = configured /\ behavior = deploy then
55
elseif state = bootstrapped /\ behavior = deploy then
29
elseif state = deployed /\ behavior = interrupt then
1
elseif state = interrupted /\ behavior = pause then
1
elseif state = interrupted /\ behavior = update then
2
elseif state = interrupted /\ behavior = uninstall then
5
elseif state = initiated /\ behavior = skip then
0
elseif state = configured /\ behavior = skip then
0
elseif state = bootstrapped /\ behavior = skip then
0
elseif state = deployed /\ behavior = skip then
0
elseif state = interrupted /\ behavior = skip then
0
elseif state = initiated /\ behavior = dwait_mariadb_master_interrupt then
0
elseif state = configured /\ behavior = dwait_mariadb_master_interrupt then
0
elseif state = bootstrapped /\ behavior = dwait_mariadb_master_interrupt then
0
elseif state = deployed /\ behavior = dwait_mariadb_master_interrupt then
0
elseif state = interrupted /\ behavior = dwait_mariadb_master_interrupt then
0
else 
2147483646
endif;

solve minimize sum(cost);