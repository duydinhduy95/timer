# 8-Bit Timer Module
Overview
This project implements an 8-bit timer module designed for integration into SoC architectures using the AMBA APB protocol. The design supports selectable clock sources, up/down counting, manual load operations, and status flags for underflow and overflow detection.

Features
APB-compliant interface with standard signals (PSEL, PWRITE, PENABLE, PADDR, PWDATA, PRDATA, PREADY, PSLVERR).

Register Control Module:

TDR: Holds the 8-bit value used to update the counter during a manual load.

TCR: Controls manual load, up/down counting direction, enable/disable counting, and selects one of four internal clock sources.

TSR: Status register indicating underflow and overflow; flags are set by hardware and cleared by software.

Logic Control Module:

Implements APB read/write control logic and clock source selection via a 4:2 multiplexer.

Generates control signals for counter operation.

Counter Module:

Supports up/down counting with manual load capability.

Synchronizes counting with the selected clock and system clock (PCLK).

Detects and signals overflow/underflow conditions.
