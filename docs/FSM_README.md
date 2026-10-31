# UART 8N1 FSM diagrams — Variant 28

These diagrams are derived from the `rtl/uart_tx.v` and `rtl/uart_rx.v` code in branch `feature/lab3-uart`, commit `da18363`.

- `UART_TX_FSM.png` / `.svg` — transmit FSM (IDLE, START, DATA, STOP).
- `UART_RX_FSM.png` / `.svg` — receive FSM (IDLE, START, DATA, STOP) with false-start and framing-error branches.
- `.dot` — Graphviz editable sources.

Clock: 50 MHz. Baud rate: 115200. `CLKS_PER_BIT` = 434, `HALF_BIT` = 217. Intermediate states hold while their baud counters have not expired. Reset is synchronous and takes precedence over all FSM transitions.

Figures document the RTL behavior. They do not themselves constitute physical FPGA hardware testing.
