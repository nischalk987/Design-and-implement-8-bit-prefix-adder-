# Top-Level Integration: Prefix Adder Counter

## Module
`prefix_counter_top.v` connects:
- `run_hold_fsm`: samples `run` at the rising clock edge and generates the registered RUN/HOLD enable.
- `prefix_adder_8bit`: computes the zero-extended 4-bit count plus `8'b00000001`.
- `run_hold_mux_4bit`: selects current count in HOLD and the low four adder sum bits in RUN.
- The four-bit register: stores the selected next count and clears synchronously when reset is high.
- `seven_segment_hex_decoder`: decodes the registered count to common-cathode active-high outputs, `seg[6:0] = {a,b,c,d,e,f,g}`.

## Top-level ports
Inputs: `clk`, `reset` (synchronous, active-high), `run`.

Outputs: `count[3:0]`, `seg[6:0]`, and debug outputs `run_enable`, `fsm_state`.

## Compile and run
Run in the directory containing all the files:

```bash
iverilog -g2012 -s tb_prefix_counter_top -o top_test \
  prefix_adder_8bit.v \
  run_hold_fsm.v \
  run_hold_mux_4bit.v \
  seven_segment_hex_decoder.v \
  prefix_counter_top.v \
  tb_prefix_counter_top.v
vvp top_test
gtkwave prefix_counter_top.vcd
```

The testbench checks synchronous reset, the registered RUN/HOLD transition, increments through the prefix-adder, hold behavior, display output for zero, modulo-16 wraparound, and reset priority.

## Timing note
The FSM registers `run_enable`. When `run` changes, the control state changes at the next rising edge; because the counter register and FSM update on the same edge using nonblocking assignments, the counter sees the previous registered enable for that edge. The testbench accounts for this one-cycle control latency.

## Standalone tests
Continue running the dedicated 8-bit prefix-adder and seven-segment decoder testbenches as well. The integration test complements but does not replace the exhaustive standalone adder test.

The testbench has been committed but must still be run in Icarus Verilog; do not treat its expected PASS output as a measured result until the simulation is executed.
