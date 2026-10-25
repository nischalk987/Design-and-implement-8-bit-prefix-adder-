# GTKWave Waveform Verification (Issue #10)

## What is available
The repository includes testbenches for the full integrated design, standalone prefix adder, and seven-segment decoder. The workflow `.github/workflows/verilog-simulation.yml` installs Icarus Verilog, runs the full-system, top-level, and decoder tests, and uploads generated VCD files as a GitHub Actions artifact.

**Simulation result (verified):** The GitHub Actions run [Verilog Simulation #4](https://github.com/nischalk987/Design-and-implement-8-bit-prefix-adder-/actions/runs/40185976272) completed successfully. Its logs show all 131,072 prefix-adder cases passed, the full-system RUN/HOLD/reset/wrap/display checks passed, the top-level integration checks passed, and all 16 seven-segment patterns passed. The run uploaded a `verilog-waveforms` artifact containing the generated VCD traces. The waveform artifact is available from the Actions run.

A waveform plot generated from the actual `prefix_counter_top.vcd` is also available in the task output. It is a visualization of the simulator's VCD data, not a screenshot of the GTKWave application. The actual GTKWave GUI inspection/screenshot step still needs to be performed locally if the course specifically requires a GTKWave-window screenshot.

## Run simulations locally (Ubuntu)

From the repository root, install the tools:

```bash
sudo apt-get update
sudo apt-get install -y iverilog gtkwave
```

Run the full-system testbench (RUN/HOLD, wraparound, display, and directed adder checks):

```bash
iverilog -g2012 -s tb_full_system -o full_system_test \
  prefix_adder_8bit.v \
  run_hold_fsm.v \
  run_hold_mux_4bit.v \
  seven_segment_hex_decoder.v \
  prefix_counter_top.v \
  tb_full_system.v

vvp full_system_test
```

The testbench writes `full_system.vcd` and should report:

```text
ALL FULL-SYSTEM AND DIRECTED PREFIX-ADDER TESTS PASSED
```

Run the standalone testbench separately to exhaustively check all 131,072 combinations:

```bash
iverilog -g2012 -s tb_prefix_adder_8bit -o prefix_adder_test \
  prefix_adder_8bit.v tb_prefix_adder_8bit.v
vvp prefix_adder_test
```

Separating this long sweep keeps the full-system counter and display waveform readable. Also run the more focused integration test:

```bash
iverilog -g2012 -s tb_prefix_counter_top -o top_test \
  prefix_adder_8bit.v \
  run_hold_fsm.v \
  run_hold_mux_4bit.v \
  seven_segment_hex_decoder.v \
  prefix_counter_top.v \
  tb_prefix_counter_top.v
vvp top_test
```

This produces `prefix_counter_top.vcd`.

## Inspect in GTKWave

Open each VCD:

```bash
gtkwave full_system.vcd
gtkwave prefix_counter_top.vcd
```

In GTKWave, add the signals below from the hierarchy panel using **Append** (signal names may be nested under `tb_full_system.dut` or `tb_prefix_counter_top.dut`):

- `clk`: regular clock transitions.
- `reset`: active-high reset; count should become 0 on a rising edge when reset is asserted.
- `run`: high during counting and low during hold.
- `count[3:0]`: increments 0, 1, 2 … F, then wraps to 0.
- `incremented_sum[7:0]`: adder result should be current count + 1.
- `next_count[3:0]`: selects low four sum bits in RUN, current count in HOLD.
- `seg[6:0]`: follows the decoder pattern for the registered count; for zero it should be `1111110` with `seg[6:0]={a,b,c,d,e,f,g}`.
- `run_enable` and `fsm_state`: FSM state/status outputs.
- `expected_count[3:0]`: reference value checked by the testbench.
- `adder_a[7:0]`, `adder_b[7:0]`, `adder_cin`, `adder_sum[7:0]`, `adder_cout`, and `expected_add[8:0]`: directed standalone-adder examples.

The current full-system trace is approximately 286 ns. Display 0–286 ns for the complete sequence; 0–120 ns shows initial reset, RUN, HOLD, resume, and the reset before wraparound, while approximately 110–286 ns shows the complete 0-to-F sequence, wraparound, and reset priority. At 0 ns the synchronous-reset count, FSM, and decoded segment output can be X until the first rising edge at 5 ns; check that they become known after that reset edge.

## Screenshot evidence

Capture the actual GTKWave application window—not a mockup—with the time ruler and the signals above visible. Save the screenshot as `docs/waveforms/full-system-waveform.png` (and optionally `docs/waveforms/wraparound-waveform.png`). Include the matching simulation log or Actions run URL beside it.

Suggested screenshot checklist:
1. Clock/reset and reset-to-zero behavior.
2. RUN increments and HOLD preserving the count.
3. Transition from `1111` to `0000`.
4. Count-to-seven-segment decode correspondence.

Keep the real simulator log and VCD artifact with the evidence. Do not present a plot generated from VCD data as a screenshot of GTKWave itself.
