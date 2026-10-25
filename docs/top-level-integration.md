# Top-Level Integration: Prefix Adder Counter

## Module
`prefix_counter_top.v` connects:
- `run_hold_fsm`: samples `run` and exports the registered FSM state (`fsm_state`) and state-derived `run_enable) for visibility.
- `prefix_adder_8bit`: computes the zero-extended 4-bit count plus `8'b00000001`.
- `run_hold_mux_4bit`: selects the current count when `run=0`, or the low four adder sum bits when `run=1`.
- The four-bit register: stores the selected value and clears synchronously when active-high reset is asserted.
- `seven_segment_hex_decoder`: decodes the registered count to common-cathode active-high outputs, `seg[6:0] = {a,b,c,d,e,f,g}`.

## Top-level ports
Inputs: `clk`, `reset` (synchronous, active-high), `run`.

Outputs: `count[3:0]`, `seg[6:0]`, plus debug outputs `run_enable` and `fsm_state`.

## Compile and run
Run in the directory containing all required Verilog files:

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

The testbench checks synchronous reset, immediate RUN/HOLD counter behavior, RUN/HOLD FSM state tracking, prefix-adder increments, display output for zero, modulo-16 wraparound, and reset priority.

## Timing choice
The FSM's status outputs are registered at the rising clock edge. The mux uses the external `run` input directly so the specified counter behavior is honored on the next rising counter edge: `run=1` increments and `run=0` holds without an extra increment while a registered enable catches up.

## Standalone tests
Continue running the dedicated prefix-adder and seven-segment decoder testbenches as well. The integration test complements but does not replace the standalone 8-bit adder test.

The testbench is committed but must still be run in Icarus Verilog; expected PASS output is not a measured result until simulation is executed.
