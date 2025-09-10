![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

- [Read the documentation for project](docs/info.md)

## DOCUMENTATION

This project implements a compact 4-bit ALU (Arithmetic Logic Unit) capable of performing multiple arithmetic and logic operations on two 4-bit inputs, labeled A and B. The operation is selected through a 3-bit opcode, which directs the ALU to execute addition, subtraction, bitwise AND, OR, XOR, NOR, NOT, or simply pass one input through.

The ALU produces a 4-bit result and includes two status flags: Carry/Borrow for arithmetic operations and Odd Parity for quick error-checking. It operates synchronously with a 50 MHz clock and can be enabled or reset using ena and rst_n.
