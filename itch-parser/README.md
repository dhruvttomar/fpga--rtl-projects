# ITCH Parser

A NASDAQ TotalView-ITCH 5.0 market data parser and order book written in
SystemVerilog. The target board is a Digilent Arty A7-35T (Xilinx Artix-7).

> **Status: work in progress.** The Stage 1 message framer is written but has
> not been verified. `sim/phase1_tb.sv` is only a stub: it instantiates the
> parser, but it has no clock generation, no reset sequence, no stimulus and no
> checks.

## Architecture

```
byte stream ──► parser ──► decoded messages ──► order book
 (8-bit + valid)  (framing +     (type, order ID,     (block RAM)
                   field extract)  side, shares, ...)
```

## Targeted message types

| Type | Name           | Length (bytes) |
|------|----------------|----------------|
| `A`  | Add Order      | 36             |
| `E`  | Order Executed | 31             |
| `X`  | Order Cancel   | 23             |
| `D`  | Order Delete   | 19             |
| `P`  | Trade          | 44             |

The length value counts the bytes after the 2-byte length prefix. The type
byte is included in that count.

## Stage 1 (current): message framing

Module: [`rtl/itch_parser.sv`](rtl/itch_parser.sv)

### Ports

| Port        | Dir    | Width | Description                                      |
|-------------|--------|-------|--------------------------------------------------|
| `clk`       | input  | 1     | Clock                                            |
| `reset`     | input  | 1     | Synchronous, active-high reset                   |
| `data_in`   | input  | 8     | Incoming stream byte                             |
| `msg_valid` | input  | 1     | Per-byte valid: `data_in` is a real byte this cycle |
| `valid`     | output | 1     | One-cycle message-done pulse                     |
| `msg_type`  | output | 8     | Type byte of the current or most recent message  |

### States

| State     | What it does                                                                 |
|-----------|-------------------------------------------------------------------------------|
| `IDLE`    | Waits for the first valid byte and shifts it into `internal_length` (high byte of the length). Then moves to `START`. |
| `START`   | Shifts the second valid byte into `internal_length` (low byte). Then moves to `RECEIVE`. |
| `RECEIVE` | Counts valid bytes with `counter`. When `counter == 0` it captures the byte into `msg_type`. On the valid byte where `counter == internal_length - 1`, it pulses `valid` for one cycle and resets `counter` to 0. |

Internally the module has a 16-bit `internal_length` register for the
big-endian length prefix and a 16-bit `counter` for the byte position inside
the message. The state register is updated in an `always_ff` block, and
`next_state` is computed in a separate `always_comb` block.

The code does not yet have a transition out of `RECEIVE`.

### Test vector

[`test_vectors/sample_stream.hex`](test_vectors/sample_stream.hex) holds a
59-byte stream: an Add Order followed by an Order Delete. The field-by-field
breakdown is in [`test_vectors/sample_stream.md`](test_vectors/sample_stream.md).
The expected Stage 1 result is two `valid` pulses: the first with `msg_type`
`0x41`, the second with `0x44`.

## Roadmap

1. **Stage 1: message framing** (in progress). Split the byte stream into
   messages and report each message's type.
2. **Stage 2: field extraction.** Decode order reference, side, shares, stock
   symbol and price from each message.
3. **Stage 3: order book.** Store resting orders in block RAM, keyed by order
   reference, and apply add/execute/cancel/delete updates.
4. **Top-level integration.** Wire the parser and order book together on the
   Arty A7-35T.

## Layout

```
itch-parser/
├── rtl/           design sources
├── sim/           testbenches
└── test_vectors/  sample input streams
```
