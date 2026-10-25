# Seven-Segment Hex Decoder

## Purpose
`seven_segment_hex_decoder.v` converts a 4-bit hexadecimal value (0 through F) into common-cathode, active-high seven-segment outputs.

## Segment ordering
The output bus is `seg[6:0] = {a,b,c,d,e,f,g}`:
- `seg[6]` = a (top)
- `seg[5]` = b (upper-right)
- `seg[4]` = c (lower-right)
- `seg[3]` = d (bottom)
- `seg[2]` = e (lower-left)
- `seg[1]` = f (upper-left)
- `seg[0]` = g (middle)

For a common-cathode display, logic 1 turns a segment on. Hex digits B and D are rendered in the usual seven-segment lowercase-like forms (`b` and `d`) because uppercase B and D are not clearly represented on a seven-segment display.

## Pattern table

| Hex | `seg[6:0]` (abcdefg) |
|---:|:---:|
| 0 | 1111110 |
| 1 | 0110000 |
| 2 | 1101101 |
| 3 | 1111001 |
| 4 | 0110011 |
| 5 | 1011011 |
| 6 | 1011111 |
| 7 | 1110000 |
| 8 | 1111111 |
| 9 | 1111011 |
| A | 1110111 |
| B (b) | 0011111 |
| C | 1001110 |
| D (d) | 0111101 |
| E | 1001111 |
| F | 1000111 |

## Simulation with Icarus Verilog
Run:
```bash
iverilog -g2012 -o decoder_test seven_segment_hex_decoder.v tb_seven_segment_hex_decoder.v
vvp decoder_test
gtkwave seven_segment_hex_decoder.vcd
```

The testbench loops through all 16 values and compares each decoder output against the expected pattern. A successful run prints `ALL 16 HEX DECODER TESTS PASSED`. The simulation has not yet been executed in this repository environment.
