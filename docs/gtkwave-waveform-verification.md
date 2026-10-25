# GTKWave Waveform Verification (Issue #10)

## What is available
The repository includes testbenches for the full integrated design, standalone prefix adder, and seven-segment decoder. The workflow `.github/workflows/verilog-simulation.yml` installs Icarus Verilog, runs the full-system, top-level, and decoder tests, and uploads generated VCD files as a GitHub Actions artifact.

**Evidence status:** I have added the reproducible workflow and instructions, but I have not executed Icarus Verilog or opened GTKWave in this environment. No real waveform screenshot or measured pass result is claimed by this document. After the workflow runs, inspect the Actions run and download its `verilog-waveforms` artifact.

## Run simulations locally (Ubuntu)

From the repository root, install the tools:

```bash
sudo apt-get update
sudo apt-get install -y iverilog gtkwave
```

Run the full-system testbench (includes independent exhaustive adder checks):

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

Successful output should end with:

```text
ALL FULL-SYSTEM AND PREFIX-ADDER TESTS PASSED
```

The command produces `full_system.vcd`. Also run the more focused integration test:

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

Use zoom-to-fit to see the full trace. Place a marker at the reset edge, a RUN increment, a HOLD interval, and the F-to-0 transition. Confirm the count and segments agree at each point.

## Screenshot evidence to add after local/CI execution

Capture the actual GTKWave application window—not a mockup—with the time ruler and the signals above visible. Save the screenshot as `docs/waveforms/full-system-waveform.png` (and optionally `docs/waveforms/wraparound-waveform.png`). Include the matching simulation log or Actions run URL beside it.

Suggested screenshot checklist:
1. Clock/reset and reset-to-zero behavior.
2. RUN increments and HOLD preserving the count.
3. Transition from `1111` to `0000`.
4. Count-to-seven-segment decode correspondence.

Do not add screenshots or claim successful results until the simulator and GTKWave have actually produced them.
