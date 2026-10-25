# 8-bit Prefix Adder

## Architecture

This module implements an 8-bit parallel-prefix adder using a Kogge–Stone-style carry network. Bit propagate is `p = A ^ B` and bit generate is `g = A & B`. Three prefix stages combine groups at distances 1, 2, and 4.

## Interface

- Inputs: `A[7:0]`, `B[7:0]`, `cin`
- Outputs: `sum[7:0]`, `cout`
- Arithmetic result: `{cout, sum} = A + B + cin`

## Files

- `prefix_adder_8bit.v` — synthesizable RTL.
- `tb_prefix_adder_8bit.v` — directed checks and exhaustive testing of all 256 × 256 operand pairs with both carry-in values; writes `prefix_adder_8bit.vcd`.

## Run with Icarus Verilog

```bash
iverilog -g2012 -o adder_test prefix_adder_8bit.v tb_prefix_adder_8bit.v
vvp adder_test
gtkwave prefix_adder_8bit.vcd
```

Expected final test message: `ALL TESTS PASSED`.
