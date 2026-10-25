# Full-System Testbench

## Testbench file
`tb_full_system.v` exercises the integrated module `prefix_counter_top` and also tests `prefix_adder_8bit` independently.

## Integrated system checks
- Synchronous active-high reset initializes the count to zero.
- RUN increments the count on each rising clock edge.
- HOLD preserves the count for multiple edges.
- RUN resumes from the held count.
- The counter wraps from 15 to 0.
- The seven-segment output is checked against all sixteen common-cathode patterns for `seg[6:0] = {a,b,c,d,e,f,g}`.
- Unknown (X) or high-impedance (Z) outputs on the checked signals are reported as failures.
- Reset priority is checked while RUN is asserted.

## Independent 8-bit prefix-adder tests
The testbench begins with directed arithmetic cases, then checks all 256 x 256 operand pairs with both values of carry-in: 131,072 combinations. Each result is compared against Verilog's 9-bit reference addition, including carry-out.

This exhaustive test is intentionally part of a separate combinational check in the same testbench, so the counter integration tests do not replace verification of general 8-bit adder arithmetic.

## Compile and run with Icarus Verilog
From the directory containing the RTL files:

```bash
iverilog -g2012 -s tb_full_system -o full_system_test \
  prefix_adder_8bit.v \
  run_hold_fsm.v \
  run_hold_mux_4bit.v \
  seven_segment_hex_decoder.v \
  prefix_counter_top.v \
  tb_full_system.v

vvp full_system_test
gtkwave full_system.vcd
```

Expected final message on success:

```text
ALL FULL-SYSTEM AND PREFIX-ADDER TESTS PASSED
```

The testbench is committed but has not yet been executed in this environment. Confirm the result locally with Icarus Verilog before treating the acceptance criteria as verified.
