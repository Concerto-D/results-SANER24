include "regular.mzn";
include "count.mzn";
enum STATE = {initiated, configured, bootstrapped, deployed, registered};
enum BEHAVIOR = {deploy, interrupt, pause, update, uninstall, skip};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|deployed,<>,<>,<>,initiated,initiated
|deployed,<>,<>,configured,<>,configured
|deployed,<>,bootstrapped,<>,<>,bootstrapped
|deployed,registered,<>,<>,<>,deployed
|<>,registered,bootstrapped,configured,initiated,registered|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : service_status;
constraint forall (i in 1..10+1) (service_status[i] = enabled <->  states[i] = deployed);
constraint states[1]=deployed;
constraint regular(sequence, transitions, deployed, {initiated,configured,bootstrapped,deployed,registered});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);

constraint states[10 + 1] = deployed;
constraint count (v in states) (v = deployed) > 0;

constraint count (v in sequence) (v = update)  > 0;

array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = initiated /\ behavior = deploy then
3
elseif state = configured /\ behavior = deploy then
2
elseif state = bootstrapped /\ behavior = deploy then
1
elseif state = deployed /\ behavior = interrupt then
1
elseif state = registered /\ behavior = pause then
1
elseif state = registered /\ behavior = update then
1
elseif state = registered /\ behavior = uninstall then
1
elseif state = initiated /\ behavior = skip then
0
elseif state = configured /\ behavior = skip then
0
elseif state = bootstrapped /\ behavior = skip then
0
elseif state = deployed /\ behavior = skip then
0
elseif state = registered /\ behavior = skip then
0
else 
2147483646
endif;

solve minimize sum(cost);