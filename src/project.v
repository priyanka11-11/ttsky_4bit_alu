 
`timescale 1ns / 1ps
`default_nettype none

module tt_um_4_bit_ALU (
    input  wire [7:0] ui_in,      // Dedicated inputs
    output wire [7:0] uo_out,     // Dedicated outputs
    input  wire [7:0] uio_in,     // IOs: Input path
    output wire [7:0] uio_out,    // IOs: Output path
    output wire [7:0] uio_oe,     // IOs: Enable path (1=output, 0=input)
    input  wire       ena,        // enable
    input  wire       clk,        // clock
    input  wire       rst_n       // reset_n
);

    // --- ALU Opcodes ---
    localparam OP_ADD  = 3'b000;
    localparam OP_SUB  = 3'b001;
    localparam OP_AND  = 3'b010;
    localparam OP_OR   = 3'b011;
    localparam OP_XOR  = 3'b100;
    localparam OP_NOR  = 3'b101;
    localparam OP_NOT  = 3'b110;
    localparam OP_PASS = 3'b111;

    // --- Operands ---
    wire [3:0] a = ui_in[3:0];       
    wire [3:0] b = ui_in[7:4];       
    wire [2:0] opcode = uio_in[2:0]; 

    // --- ALU Result & Flags (sequential) ---
    reg [3:0] alu_out;
    reg       carry_borrow;
    reg       odd_parity;

    // --- Sequential ALU ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_out       <= 4'b0;
            carry_borrow  <= 1'b0;
            odd_parity    <= 1'b0;
        end else if (ena) begin
            case (opcode)
                OP_ADD:  {carry_borrow, alu_out} = a + b;
                OP_SUB:  {carry_borrow, alu_out} = a - b; // borrow in MSB
                OP_AND:  alu_out       = a & b;
                OP_OR:   alu_out       = a | b;
                OP_XOR:  alu_out       = a ^ b;
                OP_NOR:  alu_out       = ~(a | b);
                OP_NOT:  alu_out       = ~a;
                OP_PASS: alu_out       = b;
                default: alu_out       = 4'b0;
            endcase
            odd_parity = ^alu_out; // XOR of all 4 bits
        end else begin
            // Disable output when ena=0
            alu_out       <= 4'b0;
            carry_borrow  <= 1'b0;
            odd_parity    <= 1'b0;
        end
    end

    // --- Output assignments ---
    assign uo_out[3:0] = alu_out;
    assign uo_out[4]   = carry_borrow;
    assign uo_out[5]   = odd_parity;
    assign uo_out[7:6] = 2'b00;

    // --- IO configuration ---
    assign uio_oe  = 8'b11100000;
    assign uio_out = 8'b0;

endmodule
