include "regular.mzn";
include "count.mzn";
enum STATE = {initiated, configured, deployed};
enum BEHAVIOR = {deploy, stop, uninstall, skip};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|deployed,<>,initiated,initiated
|deployed,configured,<>,configured
|deployed,configured,initiated,deployed|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : service_status;
constraint forall (i in 1..10+1) (service_status[i] = enabled <->  states[i] = deployed);
array[1..10+1] of var STATUS : facts_service_status;
constraint forall (i in 1..10+1) (facts_service_status[i] = enabled <->  states[i] = deployed \/  states[i] = configured);
constraint states[1]=initiated;
constraint regular(sequence, transitions, initiated, {initiated,configured,deployed});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);

constraint states[10 + 1] = deployed;
constraint count (v in states) (v = deployed) > 0;



array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = initiated /\ behavior = deploy then
2
elseif state = configured /\ behavior = deploy then
1
elseif state = deployed /\ behavior = stop then
1
elseif state = deployed /\ behavior = uninstall then
1
elseif state = initiated /\ behavior = skip then
0
elseif state = configured /\ behavior = skip then
0
elseif state = deployed /\ behavior = skip then
0
else 
2147483646
endif;

solve minimize sum(cost);