![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

- [Read the documentation for project](docs/info.md)

## DOCUMENTATION

This project implements a compact 4-bit ALU (Arithmetic Logic Unit) capable of performing multiple arithmetic and logic operations on two 4-bit inputs, labeled A and B. The operation is selected through a 3-bit opcode, which directs the ALU to execute addition, subtraction, bitwise AND, OR, XOR, NOR, NOT, or simply pass one input through.

The ALU produces a 4-bit result and includes two status flags: Carry/Borrow for arithmetic operations and Odd Parity for quick error-checking. It operates synchronously with a 50 MHz clock and can be enabled or reset using ena and rst_n.

## IO

Input pins:
ui_in[0]:a[0]
ui_in[1]:a[1]
ui_in[2]:a[2]
ui_in[3]:a[3]
ui_in[4]:b[0]
ui_in[5]:b[1]
ui_in[6]:b[2]
ui_in[7]:b[3]

Bidirectional pins:
uio_in[0]:opcode[0]
uio_in[1]:opcode[1]
uio_in[2]:opcode[2]


Output pins:
uo_out[0]:alu_out[0]
uo_out[1]:alu_out[1]
uo_out[2]:alu_out[2]
uo_out[3]:alu_out[3]
uo_out[4]:carry_borrow //gives carry when Addition operation takes place and borrow when Subtraction operation takes place.
uo_out[5]:odd_parity
uo_out[6]:0
uo_out[0]:0
