# Top-Level Integration: Prefix Adder Counter

## Module
`prefix_counter_top.v` connects the following modules:
- `run_hold_fsm`: samples `run` at the rising clock edge and creates the registered RUN/HOLD enable.
- `prefix_adder_8bit`: computes the zero-extended 4-bit count plus `8'b00000001`.
- `run_hold_mux_4bit`: selects current count in HOLD and the low four adder sum bits in RUN.
- A 4-bit register: stores the selected next count and synchronously clears to zero when reset is high.
- `seven_segment_hex_decoder`: decodes the registered count to active-high common-cathode output `seg[6:0] = {a,b,c,d,e,f,g}`.

## Top-level ports
- Inputs: `clk`, `reset` (synchronous, active-high), `run`
- Outputs: `count[3:0]`, `seg[6:0]`
- Debug outputs: `run_enable`, `fsm_state`

## Compile and run
Run the following from the directory containing all listed Verilog files:

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

The top-level testbench exercises reset, RUN increments, HOLD, display decoding, and operation across the 4-bit counter range. Since the FSM output is registered, a change in `run` takes effect in `run_enable` after a clock edge; the counter uses that registered enable on subsequent edges.

## Standalone module tests
Continue running the individual prefix adder and decoder testbenches as well. Full integration testing complements but does not replace the exhaustive adder test.
