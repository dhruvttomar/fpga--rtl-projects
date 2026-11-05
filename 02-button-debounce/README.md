# 02 · Button Synchronizer and Debouncer

Push buttons are asynchronous to the FPGA clock and mechanically bounce for
several milliseconds. This design turns a raw button press into one clean event.

Pipeline for `btn[0]`:

1. **Two-flop synchronizer**: brings the asynchronous input into the clock
   domain and keeps metastability from propagating.
2. **Debounce counter**: the synchronized signal has to stay stable for
   1,000,000 cycles (10 ms at 100 MHz) before it's accepted.
3. **Edge detection**: compares the debounced value to its previous value and
   toggles an LED once per press.

| File | Description |
| --- | --- |
| [`rtl/swbd.sv`](rtl/swbd.sv) | Synchronizer, debounce counter, edge detector |
| [`constraints/swbd.xdc`](constraints/swbd.xdc) | Clock, 4 buttons, 4 LEDs |
