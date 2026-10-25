# 4-bit Counter and Register

## Behavior
`counter_4bit.v` implements a 4-bit register using a rising-edge clocked process.

- `reset=1`: synchronously clears count to `0000` at the next rising edge.
- `increment_enable=1`: increments count at each rising edge.
- `increment_enable=0`: retains the previous count.
- The 4-bit result wraps naturally from `1111` (15) to `0000` (0).

The 4-bit register is implemented as four synthesizable register bits. No asynchronous reset is used.

## Interface
- `clk`: clock
- `reset`: synchronous active-high reset
- `increment_enable`: assert when the design should increment; this can be driven by the integrated RUN control
- `count[3:0]`: current count

## Testbench
`tb_counter_4bit.v` checks:
1. Synchronous reset.
2. Consecutive increments.
3. Hold behavior when increment is disabled.
4. Incrementing through 15 and wraparound to 0.
5. Reset priority when enable is high.

## Run with Icarus Verilog

```bash
iverilog -g2012 -o counter_test counter_4bit.v tb_counter_4bit.v
vvp counter_test
gtkwave counter_4bit.vcd
```

A successful run prints `ALL 4-BIT COUNTER TESTS PASSED`. The simulation has not been executed in the repository environment yet.
