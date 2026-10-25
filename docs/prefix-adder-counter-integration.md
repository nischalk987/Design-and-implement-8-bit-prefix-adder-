# Prefix Adder + 4-Bit Counter Integration

## What is integrated
`counter_prefix_integrated.v` connects the 8-bit `prefix_adder_8bit` to the 4-bit counter's increment path.

1. `count[3:0]` is zero-extended to `{4'b0000, count}`.
2. The adder computes `count_extended + 8'b00000001`, with `cin=0`.
3. The RUN/HOLD selection chooses `incremented_sum[3:0]` when `run=1`, otherwise the current `count`.
4. On the rising clock edge, synchronous active-high reset clears the count; otherwise the selected value is registered.

Only the lower four sum bits are stored, so the counter wraps from 15 to 0. The adder's standalone tests remain separate.

## Interface
- `clk`: clock
- `reset`: synchronous active-high reset
- `run`: 1 increments; 0 holds the count
- `count[3:0]`: registered counter output

## Simulation using Icarus Verilog
Ensure `prefix_adder_8bit.v`, `counter_prefix_integrated.v`, and `tb_counter_prefix_integrated.v` are in the same directory.

```bash
iverilog -g2012 -o counter_prefix_test prefix_adder_8bit.v counter_prefix_integrated.v tb_counter_prefix_integrated.v
vvp counter_prefix_test
gtkwave counter_prefix_integrated.vcd
```

The testbench verifies synchronous reset, RUN increments, HOLD behavior, wraparound from 15 to 0, and reset priority. A passing simulation prints `ALL PREFIX-ADDER COUNTER INTEGRATION TESTS PASSED`.

Note: The integrated increment path uses the actual prefix adder RTL interface (`A`, `B`, `cin`, `sum`, `cout`). The 8-bit adder's own testbench should continue to be run independently to test all 8-bit operand combinations.
