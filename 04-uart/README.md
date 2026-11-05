# 04 · UART Transceiver

A 115200 baud, 8N1 UART receiver and transmitter, tested as a loopback echo
over the Arty's USB-UART bridge. Type a character in a serial terminal and the
board sends it straight back.

```
PC ──rx──► uart_rx ──byte + valid──► uart_tx ──tx──► PC
              │
              └──► LEDs (low 4 bits of the last byte)
```

- **Receiver**: waits for the start bit, moves to the middle of the bit period,
  then samples each data bit at its center. Mid-bit sampling gives the most
  margin against clock mismatch between the two ends.
- **Transmitter**: an FSM that shifts out start bit, 8 data bits (LSB first)
  and stop bit, holding each one for `CLK_FREQ / BAUD_RATE` = 868 cycles.
  `busy` is high while a frame is going out.

| File | Description |
| --- | --- |
| [`rtl/uart_rx.sv`](rtl/uart_rx.sv) | Receiver FSM with mid-bit sampling |
| [`rtl/uart_tx.sv`](rtl/uart_tx.sv) | Transmitter FSM |
| [`rtl/top.sv`](rtl/top.sv) | Loopback: RX output feeds TX input |
| [`constraints/uart.xdc`](constraints/uart.xdc) | Clock, reset, UART RX/TX, LEDs |

The transmitter is reused in [06-riscv-rv32i](../06-riscv-rv32i) as a
memory-mapped output port.
