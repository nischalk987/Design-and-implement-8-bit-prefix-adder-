# Issue #2 — 8-bit Prefix Adder Testbench

The testbench verifies `prefix_adder_8bit` independently before integration with the counter.

## Coverage

- Zero and small operand values
- Alternating patterns (`AA`, `55`)
- Multi-bit carry propagation (`7F + 01`, `FF + 01`)
- Maximum values and carry-out
- Both values of carry-in
- Exhaustive test of all 256 × 256 operand pairs for both carry-in values (131,072 combinations), checking the 9-bit result `{cout, sum}` against a widened reference addition

Directed test cases print PASS or FAIL. A summary prints `ALL TESTS PASSED` when no mismatches occur. The testbench also writes `prefix_adder_8bit.vcd` for GTKWave.

## Run with Icarus Verilog

```bash
iverilog -g2012 -o adder_test prefix_adder_8bit.v tb_prefix_adder_8bit.v
vvp adder_test
gtkwave prefix_adder_8bit.vcd
```

The bench expects module `prefix_adder_8bit` with inputs `A[7:0]`, `B[7:0]`, `cin` and outputs `sum[7:0]`, `cout`.
