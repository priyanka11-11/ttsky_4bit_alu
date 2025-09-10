<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a compact 4-bit ALU (Arithmetic Logic Unit) capable of performing multiple arithmetic and logic operations on two 4-bit inputs, labeled A and B. The operation is selected through a 3-bit opcode, which directs the ALU to execute addition, subtraction, bitwise AND, OR, XOR, NOR, NOT, or simply pass one input through.

The ALU produces a 4-bit result and includes two status flags: Carry/Borrow for arithmetic operations and Odd Parity for quick error-checking. It operates synchronously with a 50 MHz clock and can be enabled or reset using `ena` and `rst_n`.

## How to test

The ALU opertation can be tested using the following operation code(opcode) given that both rst_n and ena are HIGH:

000: Addition  
001: Subtraction  
010: AND  
011: OR  
100: XOR  
101: NOR  
110: NOT  
111: PASS-through

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
