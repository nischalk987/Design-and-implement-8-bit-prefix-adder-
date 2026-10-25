# RUN/HOLD 4-bit Multiplexer

## Purpose
`run_hold_mux_4bit.v` is a combinational 2:1 multiplexer selecting the next counter value.

- Input 0: `count_current[3:0]` — current registered count, selected for HOLD.
- Input 1: `count_incremented[3:0]` — incremented count from the prefix-adder path, selected for RUN.
- Select: `run` — `0` selects current count; `1` selects incremented count.
- Output: `next_count[3:0]` — value to feed to the counter register.

The selection is equivalent to:
```verilog
assign next_count = run ? count_incremented : count_current;
```

## Simulation
The testbench checks both selections, response to input changes, and selection of the wrapped value 0 when RUN selects the incremented value for a current count of 15.

Run with Icarus Verilog:
```bash
iverilog -g2012 -o mux_test run_hold_mux_4bit.v tb_run_hold_mux_4bit.v
vvp mux_test
gtkwave run_hold_mux_4bit.vcd
```

A passing run prints `ALL RUN/HOLD MUX TESTS PASSED`. The simulation has not been executed in this repository environment yet.
