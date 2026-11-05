# FPGA / RTL Projects

A portfolio of digital design projects I've built from scratch in SystemVerilog,
targeting the Digilent Arty A7-35T (Xilinx Artix-7). They start with basic
clocking and I/O and build up through clock domain crossing to a RISC-V CPU, a
market-data parser and a systolic-array matrix multiply accelerator.

## Projects

| # | Project | Highlights | Status |
| --- | --- | --- | --- |
| 01 | [Blinky](01-blinky) | Clock division, first full Vivado flow | Done, on hardware |
| 02 | [Button Debounce](02-button-debounce) | Two-flop synchronizer, 10 ms debounce counter, edge detection | Done, on hardware |
| 03 | [PWM Breathing LED](03-pwm-breathing-led) | PWM carrier plus a slow duty-cycle sweep | Done, on hardware |
| 04 | [UART Transceiver](04-uart) | 115200 8N1 TX/RX, mid-bit sampling, loopback echo | Done, on hardware |
| 05 | [Asynchronous FIFO](05-async-fifo) | Dual-clock CDC FIFO, Gray-coded pointers, self-checking testbench | Done |
| 06 | [RISC-V CPU](06-riscv-rv32i) | Single-cycle RV32I subset, all 6 branches, LUI/JAL, memory-mapped UART, 100 MHz timing closed | Done, on hardware |
| 07 | [NASDAQ ITCH Parser](07-itch-parser) | ITCH 5.0 message framing and field extraction, order book with best bid/ask | In progress |
| 08 | [INT8 Matrix Multiply Accelerator](08-ai-accelerator) | MAC → PE → 4×4 systolic array → GEMM controller, verified on random 8×8 matrices | In progress |

## Up next

- Board bring-up and a host interface for the GEMM accelerator
- End-to-end ITCH parser testbench and hardware bring-up
- Ethernet MAC / UDP receive path to feed the ITCH parser

## Repository layout

Each project is self-contained:

```
NN-project-name/
├── README.md       what it does, how it works, how it's tested
├── rtl/            synthesizable SystemVerilog
├── sim/            testbenches (simulation only)
└── constraints/    XDC pin and timing constraints
```

## Toolchain

- **Language:** SystemVerilog
- **Synthesis and implementation:** Vivado 2026.1
- **Simulation:** Vivado XSim
- **Board:** Digilent Arty A7-35T (Xilinx Artix-7 XC7A35T)

## Conventions

- **Synchronous reset** throughout.
- **Two-process FSMs:** a registered state block plus a separate combinational next-state block.
- **Assignment discipline:** non-blocking (`<=`) in `always_ff`, blocking (`=`) in `always_comb`.
- **Self-checking testbenches** where possible: the testbench computes expected
  values and reports mismatches, so results don't depend on reading waveforms by eye.

Vivado project files (`.xpr`) and generated directories aren't committed. The
RTL and constraints are the source of truth: create a new Vivado project, add
a project's `rtl/`, `sim/` and `constraints/` files, and it rebuilds on any machine.
