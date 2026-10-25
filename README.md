# Design and Implement 8-Bit Prefix Adder

## DLCD Level 2 Mini Project

This project focuses on designing and implementing an **8-bit prefix adder** using Verilog HDL and combining it with the Level 2 Problem 2 counter system: a **4-bit counter FSM with RUN/HOLD control and a common-cathode 7-segment output**.

## Project Overview

The 8-bit prefix adder performs binary addition using a prefix carry network. It will be tested independently with 8-bit operands and carry cases.

The integrated counter system has two control modes:

- **RUN:** increment the 4-bit counter on each active clock edge.
- **HOLD:** preserve the current counter value.

The counter counts from 0 to 15 and wraps to 0. A combinational 7-segment decoder displays the counter value in hexadecimal (0–F). The prefix adder is used in the increment path; the full 8-bit adder is also verified independently.

## Main Features

- 8-bit prefix adder with sum and carry-out
- RUN/HOLD control FSM
- 4-bit counter with synchronous active-high reset
- RUN/HOLD next-count selection
- Common-cathode, active-high 7-segment decoder
- Verilog testbenches for adder and integrated system
- Simulation and waveform inspection using Icarus Verilog and GTKWave

## Planned Modules

| Module | Responsibility |
|---|---|
| `prefix_adder_8bit` | Add two 8-bit operands using prefix carry logic |
| `run_hold_fsm` | Control RUN/HOLD operation |
| `counter_4bit` | Store and update the 4-bit count |
| `mux_4bit` | Select incremented count or held count |
| `seven_segment_decoder` | Decode hexadecimal count to segments |
| `top_module` | Connect the complete design |

Exact module names and segment bit ordering will be documented as implementation proceeds.

## Tools

- Verilog HDL
- Icarus Verilog
- GTKWave

## Verification Results

The full-system testbench completed successfully.

- **Prefix-adder exhaustive verification:** all **131,072** tested cases matched the expected result.
- **Reset:** count cleared to 0 and the display decoded 0.
- **RUN:** counter incremented correctly.
- **HOLD:** counter retained its current value (5 in the directed test).
- **RUN resume:** counter continued from the held value (6).
- **Hexadecimal sequence:** counter/display checks passed from 0 through F and wrapped back to 0.
- **Reset priority:** reset correctly took priority over RUN.
- **Final testbench status:** `ALL FULL-SYSTEM AND PREFIX-ADDER TESTS PASSED`.

## GTKWave Waveform Evidence

The following screenshots are from the GTKWave simulation and show the counter integration and complete system behavior.

### Counter Waveform

![Counter waveform](images/Counter-waveform.png)

The counter waveform demonstrates reset, RUN incrementing, HOLD retaining the current count, and the counter continuing after RUN resumes.

### Full-System Waveform

![Full-system waveform](images/Full_system.png)

The full-system waveform includes the 8-bit prefix-adder inputs and output, clock, counter, expected values, FSM state, reset, RUN control, run enable, and seven-segment output. The displayed trace shows the count sequence and corresponding display changes.

## Verification Plan

1. Test the 8-bit prefix adder independently with representative inputs, carry propagation, and overflow.
2. Verify synchronous reset.
3. Verify RUN increments the counter.
4. Verify HOLD retains the count.
5. Verify RUN resumes from the held count.
6. Verify wraparound from 15 to 0.
7. Verify all hexadecimal decoder inputs (0–F).
8. Inspect actual VCD waveforms in GTKWave.

## Repository Progress

✅ **Implementation and verification completed** — the full-system testbench and exhaustive prefix-adder checks passed. GTKWave waveform screenshots are included above as project demonstration evidence.

## Project Issues

See the [Issues](../../issues) tab for module-level tasks and acceptance criteria.

## System Architecture

The 4-bit counter value is zero-extended to 8 bits and added to the 8-bit constant 1 by the prefix adder. The lower 4 bits of the incremented result are selected by the RUN/HOLD MUX and stored in the counter register. The register output is sent to the 7-segment decoder.

```mermaid
flowchart TD
    A["4-bit Counter"] --> B["Extend to 8 bits"]
    B --> C["8-bit Prefix Adder"]
    D["Constant 1"] --> C
    C --> E["Incremented Result"]
    A --> F["MUX"]
    E --> F
    G["RUN / HOLD"] --> F
    F --> H["4-bit Counter Register"]
    H --> I["7-Segment Decoder"]
    I --> J["Display 0-F"]
```

**Data path:** Current count → zero extension → prefix adder (+1) → RUN/HOLD MUX → counter register → 7-segment decoder → display.

## Simulation and Waveform Verification

Run the repeatable Icarus Verilog simulation workflow in [GTKWave Waveform Verification](docs/gtkwave-waveform-verification.md). The GitHub Actions workflow uploads generated VCDs as an artifact named `verilog-waveforms`. Download the artifact from the completed Actions run and open `full_system.vcd` or `prefix_counter_top.vcd` in GTKWave.

**Simulation evidence:** [GitHub Actions run #4](https://github.com/nischalk987/Design-and-implement-8-bit-prefix-adder-/actions/runs/40185976272) completed successfully: the full-system suite passed, the prefix adder matched all 131,072 arithmetic combinations, the top-level testbench passed, and all 16 decoder patterns passed. The run uploaded the `verilog-waveforms` VCD artifact. See [GTKWave Waveform Verification](docs/gtkwave-waveform-verification.md) for signals and screenshot guidance. The generated VCD plot is a visualization of real simulator data, not a GTKWave GUI screenshot.
