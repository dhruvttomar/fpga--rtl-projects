# 03 · PWM Breathing LED

An LED that smoothly fades in and out by combining two counters on very
different timescales.

- **PWM carrier**: an 8-bit counter that wraps every 256 cycles (~390 kHz). The
  LED is on while `counter < duty`, so `duty` sets the brightness.
- **Breathing sweep**: a second counter steps `duty` by one every 390,625 cycles
  (3.9 ms). It ramps up to 254, reverses, ramps back down to 1, and repeats.
  One full breath takes about 2 seconds.

| File | Description |
| --- | --- |
| [`rtl/PWMproj3.sv`](rtl/PWMproj3.sv) | PWM generator and duty-cycle sweep |
| [`constraints/pwm.xdc`](constraints/pwm.xdc) | Clock and LED pins |
