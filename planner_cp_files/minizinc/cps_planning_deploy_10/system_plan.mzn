include "regular.mzn";
include "count.mzn";
enum STATE = {deployed, configured, initiated};
enum BEHAVIOR = {interrupt, stop, deploy, skip};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|configured,initiated,deployed,deployed
|configured,<>,deployed,configured
|<>,initiated,deployed,initiated|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : service_status;
constraint forall (i in 1..10+1) (service_status[i] = enabled <->  states[i] = deployed);
array[1..10+1] of var STATUS : db_service_status;
constraint forall (i in 1..10+1) (db_service_status[i] = enabled <->  states[i] = deployed \/  states[i] = configured);
constraint states[1]=initiated;
constraint regular(sequence, transitions, initiated, {deployed,configured,initiated});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);

constraint states[10 + 1] = deployed;
constraint count (v in states) (v = deployed) > 0;



array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = deployed /\ behavior = interrupt then
1
elseif state = deployed /\ behavior = stop then
1
elseif state = configured /\ behavior = deploy then
1
elseif state = initiated /\ behavior = deploy then
2
elseif state = deployed /\ behavior = skip then
0
elseif state = configured /\ behavior = skip then
0
elseif state = initiated /\ behavior = skip then
0
else 
2147483646
endif;

solve minimize sum(cost);