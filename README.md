# FPGA Projects

A portfolio of FPGA projects built from scratch in SystemVerilog, targeting the Digilent Arty A7-35T (Xilinx Artix-7). Each project is written, simulated with a self-checking testbench, and verified on hardware. The projects start with basic clocking and I/O and build up to clock domain crossing, with processor and accelerator designs planned next.

## Completed Projects

| Project | Description |
| --- | --- |
| Blinky | Divides the 100 MHz system clock with a counter to blink an LED |
| Switch/Button Interface | Two-flop metastability synchronizers, debouncing, and edge detection for switch and button inputs |
| PWM Breathing LED | Composes two counters on different timescales: a fast one for the PWM carrier and a slow one that ramps the duty cycle |
| UART Transceiver | 115200 8N1 transmitter and receiver with mid-bit sampling, tested with a loopback echo |
| Synchronous FIFO | Single-clock FIFO that uses an extra pointer bit to tell full from empty |
| Asynchronous FIFO | Dual-clock FIFO for clock domain crossing, with Gray-coded pointers passed through two-stage synchronizers |

## Planned

- **RV32I single-cycle RISC-V CPU**
- **INT8 matrix multiplication accelerator**
- **Ethernet MAC / UDP parser / NASDAQ ITCH market data parser**

## Repository Layout

```
rtl/            synthesizable SystemVerilog modules
tb/             testbenches (simulation only, never synthesized)
constraints/    XDC pin constraint files
docs/           architecture diagrams, notes, screenshots
results/        timing and utilization reports
```

## Toolchain

- **Language:** SystemVerilog
- **Synthesis and implementation:** Vivado 2026.1
- **Simulation:** Vivado XSim
- **Board:** Digilent Arty A7-35T (Xilinx Artix-7 XC7A35T)

## Conventions

- **Synchronous reset** throughout.
- **Two-process FSMs:** a registered state block plus a separate combinational next-state block.
- **Assignment discipline:** non-blocking (`<=`) in sequential `always_ff` blocks, blocking (`=`) in combinational `always_comb` blocks.
- **Self-checking testbenches:** each testbench compares outputs against expected values and reports pass/fail, so results don't depend on reading waveforms by eye.

Vivado project files (`.xpr`) and generated directories are not committed. The RTL and constraints are the real source, and a project can be rebuilt from them on any machine.
