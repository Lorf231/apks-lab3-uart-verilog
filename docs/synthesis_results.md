# UART FPGA Synthesis and Timing Results

## Configuration
- FPGA: Lattice iCE40 HX8K (CT256)
- Clock target: 50 MHz
- UART: 115200 baud, 8N1
- Synthesis: Yosys 0.70
- Place and route: nextpnr-ice40

## Post-route Results

| Metric | UART TX | UART RX |
|---|---:|---:|
| LUT4 | 43 | 65 |
| Flip-Flops | 27 | 37 |
| Logic Cells used | 56 | 84 |
| Fmax (MHz) | 167.76 | 115.15 |
| Timing at 50 MHz | PASS | PASS |

## Notes
- Both modules were synthesized and routed separately.
- No place-and-route errors were reported.
- IO pins were automatically placed without PCF constraints.
- The target FPGA is provisional, pending instructor confirmation.
- Reported Fmax values are post-route timing estimates.
- No physical FPGA hardware test has been performed.
