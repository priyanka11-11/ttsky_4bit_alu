# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# The function to handle 'x' values
def resolve_x(value):
    """
    Replaces 'x' or 'z' bits in a Cocotb BinaryValue string representation
    with '0' before converting to an integer.
    """
    bin_str = value.binstr
    if 'x' in bin_str or 'z' in bin_str:
        resolved_str = bin_str.replace('x', '0').replace('z', '0')
        return int(resolved_str, 2)
    return value.integer

@cocotb.test()
async def alu_operations_test(dut):
    """Test various ALU operations in the 4-bit ALU including reset and enable cases"""

    # Create and start the clock (50MHz → period = 20ns)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # INITIAL RESET
    dut.rst_n.value = 0
    dut.ena.value = 0
    await Timer(40, units='ns')
    dut.rst_n.value = 1
    await Timer(20, units='ns')
    dut.ena.value = 1

    # --- Case 1: rst_n = 0, ena = 1 (reset active while enabled) ---
    dut.ui_in.value = 0x23  # random data
    dut.uio_in.value = 0b000  # operation ignored
    await RisingEdge(dut.clk)
    await Timer(10, units="ns")

    # Assert reset while ena is active
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await Timer(10, units="ns")

    # Use the new function to get the resolved output
    dut._log.info(f"uo_out before resolve_x: {dut.uo_out.value.binstr}")
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    dut._log.info(f"uo_out after resolve_x: {dut.uo_out.value.binstr}")
    result = full_output & 0xF
    carry = (full_output >> 4) & 1
    parity = (full_output >> 5) & 1

    expected_result = 0
    expected_carry = 0
    expected_parity = 0

    assert result == expected_result, f"Reset active while enabled failed: expected result={expected_result}, got {result}"
    assert carry == expected_carry, f"Reset active while enabled failed: expected carry={expected_carry}, got {carry}"
    assert parity == expected_parity, f"Reset active while enabled failed: expected parity={expected_parity}, got {parity}"
    dut._log.info(f"Reset active while enabled passed: result={result}, carry={carry}, parity={parity}")

    # Deassert reset for following tests
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await Timer(10, units="ns")

    # --- Test ADD operation ---
    dut.ui_in.value = 0x23  # a=3, b=2
    dut.uio_in.value = 0b000  # OP_ADD
    dut._log.info(f"uo_out before resolve_x: {dut.uo_out.value.binstr}")
    await RisingEdge(dut.clk)
    await Timer(10, units="ns")
    full_output = resolve_x(dut.uo_out.value) & 0x3F     
    dut._log.info(f"uo_out after resolve_x: {dut.uo_out.value.binstr}")
    result = full_output & 0xF
    dut._log.info(f"result after resolve_x: {result}")
    
    carry = (full_output >> 4) & 1
    parity = (full_output >> 5) & 1
    expected = (3 + 2) & 0xF
    assert result == expected, f"ADD failed: expected result={expected}, got {result}"
    dut._log.info(f"ADD passed: result={result}, carry={carry}, parity={parity}")

    # --- Test SUB operation ---
    dut.ui_in.value = 0x51  # a=1, b=5
    dut.uio_in.value = 0b001  # OP_SUB
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    carry = (full_output >> 4) & 1
    parity = (full_output >> 5) & 1
    expected = (1 - 5) & 0xF
    assert result == expected, f"SUB failed: expected result={expected}, got {result}"
    dut._log.info(f"SUB passed: result={result}, carry={carry}, parity={parity}")

    # --- Test AND operation ---
    dut.ui_in.value = 0xA5  # a=5, b=10
    dut.uio_in.value = 0b010  # OP_AND
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = 5 & 10
    assert result == expected, f"AND failed: expected result={expected}, got {result}"
    dut._log.info(f"AND passed: result={result}")

    # --- Test OR operation ---
    dut.ui_in.value = 0x1C  # a=12, b=1
    dut.uio_in.value = 0b011  # OP_OR
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = 12 | 1
    assert result == expected, f"OR failed: expected result={expected}, got {result}"
    dut._log.info(f"OR passed: result={result}")

    # --- Test XOR operation ---
    dut.ui_in.value = 0x3C  # a=12, b=3
    dut.uio_in.value = 0b100  # OP_XOR
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = 12 ^ 3
    assert result == expected, f"XOR failed: expected result={expected}, got {result}"
    dut._log.info(f"XOR passed: result={result}")

    # --- Test NOR operation ---
    dut.ui_in.value = 0xF0  # a=0, b=15
    dut.uio_in.value = 0b101  # OP_NOR
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = ~(0 | 15) & 0xF
    assert result == expected, f"NOR failed: expected result={expected}, got {result}"
    dut._log.info(f"NOR passed: result={result}")

    # --- Test NOT operation ---
    dut.ui_in.value = 0x04  # a=4, b ignored
    dut.uio_in.value = 0b110  # OP_NOT
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = (~4) & 0xF
    assert result == expected, f"NOT failed: expected result={expected}, got {result}"
    dut._log.info(f"NOT passed: result={result}")

    # --- Test PASS operation ---
    dut.ui_in.value = 0x78  # a ignored, b=7
    dut.uio_in.value = 0b111  # OP_PASS
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result = full_output & 0xF
    expected = 7
    assert result == expected, f"PASS failed: expected result={expected}, got {result}"
    dut._log.info(f"PASS passed: result={result}")

    # --- Case 2: rst_n = 1, ena = 0 (disabled state test) ---
    # Enable ALU and perform operation first
    dut.ena.value = 1
    dut.ui_in.value = 0x12  # a=2, b=1
    dut.uio_in.value = 0b000  # OP_ADD
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result_active = full_output & 0xF
    assert result_active != 0, f"Precondition failed: expected non-zero result, got {result_active}"

    # Now disable ALU
    dut.ena.value = 0
    await RisingEdge(dut.clk)
    await Timer(10, units='ns')
    full_output = resolve_x(dut.uo_out.value) & 0x3F
    result_disabled = full_output & 0xF
    carry_disabled = (full_output >> 4) & 1
    parity_disabled = (full_output >> 5) & 1

    expected_result = 0
    expected_carry = 0
    expected_parity = 0

    assert result_disabled == expected_result, f"Disabled state failed: expected result={expected_result}, got {result_disabled}"
    assert carry_disabled == expected_carry, f"Disabled state failed: expected carry={expected_carry}, got {carry_disabled}"
    assert parity_disabled == expected_parity, f"Disabled state failed: expected parity={expected_parity}, got {parity_disabled}"
    dut._log.info(f"Disabled state with rst_n=1, ena=0 passed: result={result_disabled}, carry={carry_disabled}, parity={parity_disabled}")
