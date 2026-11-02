# ITCH Parser

A NASDAQ TotalView-ITCH 5.0 market data parser and order book written in
SystemVerilog. The target board is a Digilent Arty A7-35T (Xilinx Artix-7).

> **Status: work in progress.** The parser, order book and top-level wrapper
> are written. The parser and the order book each have testbenches in `sim/`,
> which print results with `$display` but do not check them automatically.
> There is no testbench for `top.sv` yet, and the design has not been run on
> the board.

## Architecture

```
byte stream ──► parser ──► decoded messages ──► order book
 (8-bit + valid)  (framing +     (type, order ref,    (best bid/ask)
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

## Parser: [`rtl/itch_parser.sv`](rtl/itch_parser.sv)

### Ports

| Port        | Dir    | Width | Description                                         |
|-------------|--------|-------|-----------------------------------------------------|
| `clk`       | input  | 1     | Clock                                               |
| `reset`     | input  | 1     | Synchronous, active-high reset                      |
| `data_in`   | input  | 8     | Incoming stream byte                                |
| `msg_valid` | input  | 1     | Per-byte valid: `data_in` is a real byte this cycle |
| `valid`     | output | 1     | One-cycle message-done pulse                        |
| `msg_type`  | output | 8     | Message type byte                                   |
| `order_ref` | output | 64    | Order reference number                              |
| `side`      | output | 8     | Buy/sell indicator (`A`, `P`)                       |
| `shares`    | output | 32    | Shares (`A`, `P`), executed shares (`E`), cancelled shares (`X`) |
| `stock`     | output | 64    | 8-character stock symbol (`A`, `P`)                 |
| `price`     | output | 32    | Price, 4 implied decimal places (`A`, `P`)          |
| `match`     | output | 64    | Match number (`E`, `P`)                             |

Fields are shifted in big-endian, one byte at a time, as their bytes arrive.
They are complete when `valid` pulses. A field the current message type
doesn't contain keeps its value from an earlier message.

### Stage 1: framing

| State     | What it does                                                                 |
|-----------|-------------------------------------------------------------------------------|
| `IDLE`    | Shifts the first valid byte into `internal_length` (high byte of the length), then moves to `START`. |
| `START`   | Shifts the second valid byte into `internal_length` (low byte), then moves to `RECEIVE`. |
| `RECEIVE` | Counts valid bytes with `counter` and captures the byte at `counter == 0` into `msg_type`. On the valid byte where `counter == internal_length - 1`, it pulses `valid`, resets `counter` and returns to `IDLE` to read the next length prefix. |

Cycles where `msg_valid` is low don't advance the length shift or the
counter, so the stream can have gaps between valid bytes.

### Stage 2: field extraction

While in `RECEIVE`, `counter` is the byte offset inside the message, where 0
is the type byte. The order reference comes from offsets 11-18 for every
message type. The other fields depend on `msg_type`:

| Type | Fields (byte offsets)                                                    |
|------|---------------------------------------------------------------------------|
| `A`  | side 19, shares 20-23, stock 24-31, price 32-35                           |
| `E`  | executed shares 19-22, match number 23-30                                 |
| `X`  | cancelled shares 19-22                                                    |
| `D`  | order reference only                                                      |
| `P`  | side 19, shares 20-23, stock 24-31, price 32-35, match number 36-43       |

## Order book (Stage 3): [`rtl/order_book.sv`](rtl/order_book.sv)

Takes the parser's message-done pulse and decoded fields as inputs, and outputs
`best_bid` and `best_ask`, each with a valid flag.

Orders are stored in 1024-entry arrays (reference, side, shares, price, valid),
addressed directly by `order_ref[9:0]`. Each message type is handled as follows:

| Type     | Action                                                                  |
|----------|--------------------------------------------------------------------------|
| `A`      | Stores the order. Updates the best bid or ask if the new price beats it. |
| `D`      | Reads the slot, and clears it if the stored reference matches.           |
| `E`, `X` | Reads the slot and subtracts the shares if the reference matches. Clears the slot if exactly the remaining shares are removed. |
| `P`      | Ignored.                                                                 |

Removing the order that holds the best price starts a scan of all 1024 entries,
one per clock cycle, to find the new best price. The bid and ask have separate
scans, and the side's valid flag stays low until its scan finishes.

## Top level: [`rtl/top.sv`](rtl/top.sv)

Connects `itch_parser` to `order_book`. Its ports are the input byte stream plus
the best bid and ask outputs. [`constraints/timing.xdc`](constraints/timing.xdc)
defines a 100 MHz clock on `clk`. There are no pin assignments yet.

## Simulation

| Testbench                                   | What it does                                                |
|---------------------------------------------|-------------------------------------------------------------|
| [`sim/phase1_tb.sv`](sim/phase1_tb.sv)       | Feeds the 59-byte sample stream one byte per cycle and prints `msg_type` on every done pulse. |
| [`sim/phase2_tb.sv`](sim/phase2_tb.sv)       | Feeds the same stream, but drops `msg_valid` for 3 cycles (with `data_in = 0xFF`) in the middle of the Add Order's order reference. Prints every decoded field on each done pulse. |
| [`sim/order_book_tb.sv`](sim/order_book_tb.sv) | Drives `order_book` directly, without the parser. Adds bids and asks, deletes the best of each, and prints the best price after the rescan. Does not exercise `E` or `X`. |

`phase1_tb` and `phase2_tb` load the stream with `$readmemh`. The file is
[`test_vectors/sample_stream.hex`](test_vectors/sample_stream.hex); the field
breakdown is in [`test_vectors/sample_stream.md`](test_vectors/sample_stream.md).
Note that these two testbenches currently read it from a local path
(`C:/Users/dhruv/Downloads/stream.hex`), so update that path to run them from
this repo.

The expected parser result is two done pulses: `0x41` (Add Order: order ref 12345,
side `B`, 100 shares, `AAPL    `, price 1825000) and then `0x44` (Order
Delete: order ref 12345).

## Roadmap

1. **Stage 1: message framing.** Written.
2. **Stage 2: field extraction.** Written.
3. **Stage 3: order book.** Written: add/execute/cancel/delete updates and best
   bid/ask tracking.
4. **Top-level integration** (in progress). `top.sv` connects the parser and
   order book. Still to do: end-to-end simulation, pin assignments and bringing
   it up on the Arty A7-35T.

## Layout

```
itch-parser/
├── constraints/   Vivado timing constraints
├── rtl/           design sources
├── sim/           testbenches
└── test_vectors/  sample input streams
```
