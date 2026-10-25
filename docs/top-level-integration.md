# Top-Level Integration: Prefix Adder Counter

## Module
`prefix_counter_top.v` connects:
- `run_hold_fsm`: samples `run` and exports the registered FSM state (`fsm_state`) and `run_enable` for status/debug visibility.
- `prefix_adder_8bit`: computes the zero-extended 4-bit count plus `8'b00000001`.
- `run_hold_mux_4bit`: selects the current count when `run=0`, or the low four adder sum bits when `run=1`.
- A 4-bit register: stores the selected value and clears synchronously when active-high reset is asserted.
- `seven_segment_hex_decoder`: decodes the registered count to common-cathode active-high outputs, `seg[6:0] = {a,b,c,d,e,f,g}`.

## Top-level ports
Inputs: `clk`, `reset` (synchronous, active-high), `run`.

Outputs: `count[3:0]`, `seg[6:0]`, plus debug/status outputs `run_enable` and `fsm_state`.

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

The integration testbench checks synchronous reset, immediate RUN/HOLD counter behavior, FSM state tracking, prefix-adder increments, display output for zero, modulo-16 wraparound, and reset priority.

## Timing choice
The FSM status outputs are registered on the rising clock edge. The mux uses the external `run` input directly, so `run=1` increments and `run=0` holds on the next counter edge without an extra increment while a registered enable catches up.

## Standalone tests
Continue running the dedicated prefix-adder and seven-segment decoder testbenches as well. The integration test complements but does not replace the standalone 8-bit adder test.

**Verification status:** The top-level testbench has been committed but has not yet been run in Icarus Verilog. Do not treat expected PASS output as a measured result until the simulation is executed.
