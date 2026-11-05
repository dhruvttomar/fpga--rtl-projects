# 05 · Asynchronous FIFO

A dual-clock FIFO for safely moving data between two unrelated clock domains.
This is the standard clock domain crossing (CDC) building block.

**Design** (parameterized width, 16 entries):

- Write and read pointers are one bit wider than the address. The extra bit
  distinguishes *full* (same address, different wrap) from *empty* (identical).
- Each pointer is converted to **Gray code** before it crosses domains. Only one
  bit changes per increment, so a synchronizer can never capture a wildly wrong
  value mid-transition.
- Each Gray pointer passes through a **two-flop synchronizer** into the other
  domain.
- `empty` is computed in the read domain and `full` in the write domain. Full
  compares against the synchronized read pointer with its top two bits inverted.

| File | Description |
| --- | --- |
| [`rtl/async_fifo.sv`](rtl/async_fifo.sv) | FIFO with Gray-coded, synchronized pointers |
| [`sim/async_fifo_tb.sv`](sim/async_fifo_tb.sv) | Self-checking testbench |

**Testbench:** the write and read clocks run at different, unrelated
frequencies. Three tests: fill to full and drain, back-to-back bursts, and slow
sparse writes. The reader checks every value in order and ends with
`ALL TESTS PASSED` or an error count.
