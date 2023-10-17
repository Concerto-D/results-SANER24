include "regular.mzn";
include "count.mzn";
enum STATE = {running, paused, off};
enum BEHAVIOR = {update, deploy, destroy, skip};
enum STATUS = {enabled, disabled};
array[STATE, BEHAVIOR] of opt STATE: transitions = 
[|paused,running,<>,running
|paused,running,off,paused
|<>,running,off,off|];
array[1..10] of var BEHAVIOR: sequence;
array[1..10+1] of var STATE: states;
constraint forall (i in 1..10) (states[i + 1] = transitions[states[i], sequence[i]]);
array[1..10+1] of var STATUS : rcv_status;
constraint forall (i in 1..10+1) (rcv_status[i] = enabled <->  states[i] = running);
array[1..10+1] of var STATUS : config_status;
constraint forall (i in 1..10+1) (config_status[i] = enabled <->  states[i] = running);
array[1..10+1] of var STATUS : sys_service_status;
constraint forall (i in 1..10+1) (sys_service_status[i] = enabled <->  states[i] = running);
constraint states[1]=running;
constraint regular(sequence, transitions, running, {running,paused,off});
constraint forall (i in 1..10 - 1) (sequence[i] = skip -> sequence[i+1] = skip);

constraint states[10 + 1] = running;
constraint count (v in states) (v = running) > 0;
constraint count (status in sys_service_status) (status = disabled) > 0;


array[1..10] of var int: cost;
constraint forall (i in 1..10) (cost[i] = fcost(states[i], sequence[i]));
function var int: fcost(var STATE: state, var BEHAVIOR: behavior) =
if state = running /\ behavior = update then
1
elseif state = paused /\ behavior = deploy then
2
elseif state = paused /\ behavior = destroy then
1
elseif state = off /\ behavior = deploy then
3
elseif state = running /\ behavior = skip then
0
elseif state = paused /\ behavior = skip then
0
elseif state = off /\ behavior = skip then
0
else 
2147483646
endif;

solve minimize sum(cost);