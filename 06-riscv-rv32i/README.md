# 06 · Single-Cycle RISC-V CPU (RV32I subset)

A 32-bit single-cycle RISC-V processor written from scratch, running on the
Arty A7-35T at **100 MHz** (timing met with WNS +0.691 ns, Fmax ≈ 107 MHz).

```
        ┌────┐   ┌──────┐   ┌─────────┐   ┌─────────┐   ┌─────┐   ┌──────┐
 ┌─────►│ PC ├──►│ imem ├──►│ control │   │ regfile ├──►│ ALU ├──►│ dmem │
 │      └────┘   └──────┘   │ imm_gen │──►│         │   └─────┘   │ UART │
 │                          └─────────┘   └─────────┘             └──┬───┘
 └──────────── next_pc (branch / jump / pc+4) ◄──────── writeback ◄──┘
```

## Supported instructions

| Class | Instructions |
| --- | --- |
| R-type | `ADD` `SUB` `AND` `OR` `XOR` `SLT` |
| I-type ALU | `ADDI` `ANDI` `ORI` `XORI` `SLTI` |
| Memory | `LW` `SW` |
| Branch | `BEQ` `BNE` `BLT` `BGE` `BLTU` `BGEU` |
| Upper / jump | `LUI` `JAL` |

## Design notes

- **Dedicated branch comparator.** `br_eq`, `br_lt` and `br_ltu` are computed
  straight from `rs1`/`rs2` instead of going through the ALU. That takes the ALU
  off the next-PC critical path and improved slack from +0.125 ns to +0.691 ns.
- **4-input writeback mux.** It selects ALU result, load data, `PC + 4`
  (`JAL` link) or the immediate (`LUI`).
- **Memory-mapped UART.** A store with address bit 12 set goes to the UART
  transmitter from [04-uart](../04-uart) instead of data memory.
- **Debug LEDs.** The four LEDs show the low bits of register `x11`.

## Files

| File | Description |
| --- | --- |
| [`rtl/riscv_core.sv`](rtl/riscv_core.sv) | Datapath: wires everything together, branch compare, writeback mux |
| [`rtl/control.sv`](rtl/control.sv) | Main decoder (opcode/funct3/funct7 → control signals) |
| [`rtl/alu.sv`](rtl/alu.sv) | ALU |
| [`rtl/regfile.sv`](rtl/regfile.sv) | 32×32 register file, `x0` hardwired to 0 |
| [`rtl/imm_gen.sv`](rtl/imm_gen.sv) | Immediate generator (I/S/B/U/J formats) |
| [`rtl/pc.sv`](rtl/pc.sv), [`rtl/next_pc.sv`](rtl/next_pc.sv) | Program counter and next-PC selection |
| [`rtl/imem.sv`](rtl/imem.sv), [`rtl/dmem.sv`](rtl/dmem.sv) | 256-word instruction and data memories |
| [`rtl/uart_tx.sv`](rtl/uart_tx.sv) | UART transmitter (memory-mapped output) |
| [`rtl/top.sv`](rtl/top.sv) | Board top level |
| [`sim/`](sim) | Unit testbenches for the ALU, immediate generator and register file, plus a full-core testbench |
| [`sw/program.hex`](sw/program.hex) | Test program loaded into instruction memory |
| [`constraints/riscvled.xdc`](constraints/riscvled.xdc) | Pins and 100 MHz clock |

## Test program

[`sw/program.hex`](sw/program.hex) exercises `ADDI`, `LUI`, `JAL`, `ADD` and a
branch:

```
0x00  addi x31, x0, 7
0x04  lui  x5, 0xF8          # x5  = 0x000F8000
0x08  addi x11, x5, 1        # x11 = 0x000F8001
0x0C  nop
0x10  jal  x10, +8           # x10 = 0x14, skip the next instruction
0x14  addi x11, x11, 8       # (skipped)
0x18  add  x11, x11, x10     # x11 = 0x000F8015
0x1C  beq  x0, x0, 0         # halt (spin forever)
```

If `LUI` and `JAL` work correctly, the LEDs show `0101`.
