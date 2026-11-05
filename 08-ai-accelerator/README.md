# 08 · INT8 Matrix Multiply Accelerator

A systolic-array GEMM engine built bottom-up: a single multiply-accumulate unit,
then a dot-product engine, then a 4×4 grid of processing elements, then a
controller with on-chip operand buffers.

> **Status: in progress.** Everything below simulates. Board bring-up and a
> host interface are next.

## Building blocks

| Module | What it does |
| --- | --- |
| [`mac`](rtl/mac.sv) | Signed 8×8 → 16-bit multiply, registered, accumulated into 32 bits. `clear` loads the first product and `en` accumulates. |
| [`dot_product`](rtl/dot_product.sv) | Streams `a`/`b` pairs into a MAC with `valid_in`/`last_in` framing and pulses `done` when the result is ready. |
| [`pe`](rtl/pe.sv) | Processing element: a MAC that also forwards `a` to the right and `b` downward one cycle later. |
| [`systolic_array`](rtl/systolic_array.sv) | 4×4 grid of PEs built with `generate` loops. A enters from the left and B from the top, and each PE holds one element of C. |
| [`gemm_core`](rtl/gemm_core.sv) | Operand buffers for A (4×8) and B (8×4), plus an FSM (`IDLE → CLEAR → FEED → DRAIN → DONE`) that feeds the array in the skewed "staircase" order. Computes a 4×4 output tile with K = 8. |

## How the systolic array works

Row `r` of A and column `r` of B start `r` cycles late. That way the
`A[i][k]` and `B[k][j]` that need to meet arrive at PE `(i, j)` in the same
cycle. Every PE does one MAC per cycle, so the full 4×4 tile is computed in
parallel. After the last inputs, a few zero-padded cycles let the data drain
through the array.

## Verification

All testbenches are self-checking: they compute the expected result in
software and compare it to the hardware output.

| Testbench | Checks |
| --- | --- |
| [`sim/mac_tb.sv`](sim/mac_tb.sv) | Clear, accumulate, and signed products |
| [`sim/dot_product_tb.sv`](sim/dot_product_tb.sv) | Streams a vector pair and prints the result on `done` |
| [`sim/systolic_array_tb.sv`](sim/systolic_array_tb.sv) | 4×4 × 4×4 multiply with mixed-sign values, all 16 outputs checked |
| [`sim/gemm_core_tb.sv`](sim/gemm_core_tb.sv) | **8×8 × 8×8 multiply with random signed INT8 values**, tiled into four 4×4 output blocks through `gemm_core`, all 64 outputs checked |
