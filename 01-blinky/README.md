# 01 · Blinky

The "hello world" of FPGAs: divide the 100 MHz board clock down to something
the eye can see.

A free-running 26-bit counter increments every clock cycle, and its MSB drives
an LED. Bit 25 toggles every 2^25 cycles, so the LED blinks at about 1.5 Hz.

| File | Description |
| --- | --- |
| [`rtl/blinky.sv`](rtl/blinky.sv) | Counter and LED output |
| [`constraints/blinky.xdc`](constraints/blinky.xdc) | Clock pin, 100 MHz clock constraint, LED pin |

**What it taught me:** the Vivado flow end to end (RTL → synthesis →
implementation → bitstream → board), and how a clock constraint ties the
design to a real oscillator.
