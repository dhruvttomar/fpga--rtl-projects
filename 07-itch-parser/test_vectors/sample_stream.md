# sample_stream.hex

59 bytes, one hex byte per line (loadable with `$readmemh`). There are two
length-prefixed ITCH 5.0 messages: an Add Order followed by an Order Delete
for the same order reference.

The length prefix is 2 bytes, big-endian. It counts the bytes that follow it,
and the type byte is included in that count.

## Message 1: Add Order ('A'), bytes 0-37

| Bytes (offset) | Hex                       | Field            | Value              |
|----------------|---------------------------|------------------|--------------------|
| 0-1            | `00 24`                   | length           | 36                 |
| 2              | `41`                      | message type     | 'A' (Add Order)    |
| 3-4            | `00 01`                   | stock locate     | 1                  |
| 5-6            | `00 00`                   | tracking number  | 0                  |
| 7-12           | `00 00 00 00 00 01`       | timestamp        | 1                  |
| 13-20          | `00 00 00 00 00 00 30 39` | order reference  | 12345              |
| 21             | `42`                      | buy/sell         | 'B'                |
| 22-25          | `00 00 00 64`             | shares           | 100                |
| 26-33          | `41 41 50 4C 20 20 20 20` | stock            | "AAPL    "         |
| 34-37          | `00 1B D8 E8`             | price            | 1825000 ($182.5000) |

## Message 2: Order Delete ('D'), bytes 38-58

| Bytes (offset) | Hex                       | Field            | Value              |
|----------------|---------------------------|------------------|--------------------|
| 38-39          | `00 13`                   | length           | 19                 |
| 40             | `44`                      | message type     | 'D' (Order Delete) |
| 41-42          | `00 01`                   | stock locate     | 1                  |
| 43-44          | `00 00`                   | tracking number  | 0                  |
| 45-50          | `00 00 00 00 00 02`       | timestamp        | 2                  |
| 51-58          | `00 00 00 00 00 00 30 39` | order reference  | 12345              |

## Expected Stage 1 behavior

When the stream is fed with `msg_valid` high for each byte, the framer should
produce two one-cycle message-done pulses:

1. `msg_type = 0x41` ('A'), after byte 37
2. `msg_type = 0x44` ('D'), after byte 58
