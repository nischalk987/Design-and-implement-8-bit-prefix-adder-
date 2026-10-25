# Full-System Testbench

## Testbench files

- `tb_full_system.v` tests the `prefix_counter_top` integration and runs directed 8-bit adder cases for a useful, compact full-system waveform.
- `tb_prefix_adder_8bit.v` independently checks all 256 x 256 operand pairs with both carry-in values (131,072 cases).

The exhaustive adder test runs separately so it does not make the full-system VCD excessively long. The full-system testbench asserts synchronous reset before checking the counter or FSM outputs.

## Full-system checks

- Synchronous active-high reset initializes the count and FSM.
- RUN increments the 4-bit counter; HOLD retains it; RUN resumes from the held count.
- The count cycles through 0–F and wraps from F to 0.
- Reset takes priority while RUN is asserted.
- The seven-segment output is checked against all sixteen common-cathode patterns for `seg[6:0] = {a,b,c,d,e,f,g}`.
- The testbench rejects X/Z values and checks the FSM state and enable against the sampled controls.
- Directed standalone-adder cases appear in the full-system VCD; exhaustive testing is performed by the separate adder testbench.

## Compile and run with Icarus Verilog (PowerShell)

Run these commands from the repository directory:

```powershell
iverilog -g2012 -s tb_full_system -o .\full_system_test.exe .\prefix_adder_8bit.v .\run_hold_fsm.v .\run_hold_mux_4bit.v .\seven_segment_hex_decoder.v .\prefix_counter_top.v .\tb_full_system.v
if ($?) { vvp .\full_system_test.exe }

iverilog -g2012 -s tb_prefix_adder_8bit -o .\prefix_adder_test.exe .\prefix_adder_8bit.v .\tb_prefix_adder_8bit.v
if ($?) { vvp .\prefix_adder_test.exe }

gtkwave .\full_system.vcd
```

The full-system run should report `ALL FULL-SYSTEM AND DIRECTED PREFIX-ADDER TESTS PASSED`; the separate exhaustive run should report `ALL TESTS PASSED`.

## GTKWave signals and time

Add the testbench signals `clk`, `reset`, `run`, `count[3:0]`, `expected_count[3:0]`, `fsm_state`, `run_enable`, and `seg[6:0]`. Add `adder_a[7:0]`, `adder_b[7:0]`, `adder_cin`, `adder_sum[7:0]`, `adder_cout`, and `expected_add[8:0]` to show the directed standalone-adder examples. Under `dut.increment_adder`, add `A[7:0]`, `B[7:0]`, `sum[7:0]`, `cin`, and `cout` to see the adder increment path used by the integrated counter.

The complete full-system trace is approximately 286 ns. Display 0–286 ns for the full sequence; use 0–120 ns for initial reset, RUN, HOLD, resume, and the reset before wraparound, and approximately 110–286 ns for the complete 0-to-F sequence, wraparound, and reset priority. At 0 ns the synchronous-reset outputs can be X until the first rising edge at 5 ns; they must become known after that edge.
