

`timescale 1ns / 1ps

module tb_tt_um_4_bit_ALU ();
    // Inputs to DUT
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg ena;
    reg clk;
    reg rst_n;
    
    // Outputs from DUT
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Instantiate the DUT
    tt_um_4_bit_ALU uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

	    
    // ALU Opcodes
    localparam OP_ADD  = 3'b000;
    localparam OP_SUB  = 3'b001;
    localparam OP_AND  = 3'b010;
    localparam OP_OR   = 3'b011;
    localparam OP_XOR  = 3'b100;
    localparam OP_NOR  = 3'b101;
    localparam OP_NOT  = 3'b110;
    localparam OP_PASS = 3'b111;
    
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, uut);
    end
    
    // Clock period
    localparam CLK_PERIOD = 20;
    
    // Generate clock
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // Task to apply a single ALU operation
    task test_operation;
        input [2:0] op;
        input [3:0] a_val;
        input [3:0] b_val;
        input [3:0] expected;
        input carry_expect;
        input parity_expect;
        begin
            ui_in = {b_val, a_val};
            uio_in = {5'b0, op};
            #(CLK_PERIOD); // wait for sequential update
            
            if (uo_out[3:0] === expected)
                $display("PASS: Op=%b A=%d B=%d Result=%d", op, a_val, b_val, uo_out[3:0]);
            else
                $display("FAIL: Op=%b A=%d B=%d Got=%d Exp=%d", op, a_val, b_val, uo_out[3:0], expected);
            
            if (uo_out[4] === carry_expect)
                $display("PASS: Carry/Borrow correct: %b", uo_out[4]);
            else
                $display("FAIL: Carry/Borrow expected %b, got %b", carry_expect, uo_out[4]);
            
            if (uo_out[5] === parity_expect)
                $display("PASS: Odd parity correct: %b", uo_out[5]);
            else
                $display("FAIL: Odd parity expected %b, got %b", parity_expect, uo_out[5]);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        ui_in = 8'b0;
        uio_in = 8'b0;
        ena = 1'b1;
        rst_n = 1'b1;
        
        // --- CASE 1: rst_n=0, ena=0 ---
        ui_in = 8'b00100010;
        uio_in = 8'b0;
        $display("\nCASE 1: rst_n=0, ena=0");
        ena = 1'b0;
        rst_n = 1'b0;
        #(CLK_PERIOD);
        $display("Outputs after rst_n=0, ena=0 ui_in=%b uio_in=%b ->  uo_out=%b",ui_in,uio_in, uo_out);
        
        // Release reset
        rst_n = 1'b1;
        #(CLK_PERIOD);
        $display("Outputs after rst_n=1, ena=0 ui_in=%b uio_in=%b ->  uo_out=%b",ui_in,uio_in, uo_out);
        
        // --- CASE 2: rst_n=0, ena=1 ---
        $display("\nCASE 2: rst_n=0, ena=1");
        ena = 1'b1;
        rst_n = 1'b0;
        #(CLK_PERIOD);
        $display("Outputs after rst_n=0, ena=1 ui_in=%b uio_in=%b ->  uo_out=%b",ui_in,uio_in, uo_out);
        
        rst_n = 1'b1; 
        #(CLK_PERIOD);
        $display("Outputs after rst_n=1, ena=1 ui_in=%b uio_in=%b ->  uo_out=%b",ui_in,uio_in, uo_out);
        
        #(CLK_PERIOD);
        ui_in = 8'b0;
        uio_in = 8'b0;
        
        // Normal ALU tests with ena=1
        $display("\nStarting normal ALU tests...");
        test_operation(OP_ADD, 4'd5, 4'd3, 4'd8, 1'b0, 1'b1);
        test_operation(OP_SUB, 4'd10,4'd4,4'd6, 1'b0, 1'b0);
        test_operation(OP_AND, 4'b1100,4'b1010,4'b1000,1'b0,1'b1);
        test_operation(OP_OR,  4'b1100,4'b1010,4'b1110,1'b0,1'b1);
        test_operation(OP_XOR, 4'b1100,4'b1010,4'b0110,1'b0,1'b0);
        test_operation(OP_NOR, 4'b1100,4'b1010,4'b0001,1'b0,1'b1);
        test_operation(OP_NOT, 4'b1010,4'b0000,4'b0101,1'b0,1'b0);
        test_operation(OP_PASS,4'b0000,4'b1010,4'b1010,1'b0,1'b0);
        
        $display("\nAll tests completed.");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t: opcode=%b A=%d B=%d Result=%d Carry=%b OddParity=%b", 
                 $time, uio_in[2:0], ui_in[3:0], ui_in[7:4], uo_out[3:0], uo_out[4], uo_out[5]);
    end
endmodule
