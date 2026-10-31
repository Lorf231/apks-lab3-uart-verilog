# UART simulation waveform figures

These plots were generated from the original Icarus Verilog VCD event traces, not invented or copied from a simulator screenshot.

- `uart_loopback_waveform.png`: four TX/RX frames (0x55, 0xA5, 0x00, 0xFF).
- `uart_byte_55_waveform.png`: first UART 8N1 frame for byte 0x55 with per-bit timing.
- `uart_error_waveform.png`: false start, framing error, and receiver recovery overview.
- `uart_error_pulse_zoom.png`: framing_error pulse at its real 20 ns width.

Source VCD files: uart_tx.vcd, uart_loopback.vcd, uart_rx_error.vcd.
All VCD timestamps use 1 ps time resolution; plots display microseconds.
At overview scale, 20 ns pulses are too narrow to represent faithfully, so markers/annotations denote exact events. See the separate zoom view for the real pulse width.
