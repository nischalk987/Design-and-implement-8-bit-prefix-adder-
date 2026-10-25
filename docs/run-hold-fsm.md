# RUN/HOLD FSM

## Purpose
`run_hold_fsm.v` implements the two-state controller for the counter mini-project.

## State diagram

```text
                 run = 1
            +----------------+
            |                v
         +-------+       +-------+
         | HOLD  |       |  RUN  |
         | state=0|      | state=1|
         +-------+       +-------+
            ^                |
            |                |
            +----------------+
                 run = 0

Synchronous reset = 1: next state is HOLD (takes priority over run).
```

## Interface
- `clk`: controller updates at the rising edge.
- `reset`: synchronous, active-high; sets state to HOLD on a rising edge.
- `run`: 1 selects RUN; 0 selects HOLD.
- `state`: encoded state output (0=HOLD, 1=RUN).
- `run_enable`: high when state is RUN; connect this to the counter's increment enable.

## Important timing note
Because this is a registered FSM, `state` reflects the sampled `run` value after a rising clock edge. A downstream counter using `run_enable` therefore uses the FSM's registered state. If the design specification instead requires the counter to respond directly to `run` at the same edge, use `run` as the counter enable or change the FSM output to a combinational next-state decode. Keep this timing choice consistent throughout integration.

## Simulation with Icarus Verilog
Run from the directory containing both files:

```bash
iverilog -g2012 -o fsm_test run_hold_fsm.v tb_run_hold_fsm.v
vvp fsm_test
gtkwave run_hold_fsm.vcd
```

The testbench checks synchronous reset, RUN and HOLD transitions, and reset priority. It prints `ALL RUN/HOLD FSM TESTS PASSED` only if the checks pass. Simulation has not been run in this repository environment yet.
