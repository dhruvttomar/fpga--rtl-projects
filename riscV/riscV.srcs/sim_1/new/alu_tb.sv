`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 10:25:04 PM
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb;
    logic [31:0] a, b;
    logic [3:0]  alu_ctrl;
    logic [31:0] result;
    logic        zero;

    int errors = 0;

    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );
    
    
    initial begin
        //Test 1
        a = 32'd5; b = 32'd3; alu_ctrl = 4'b0000;
        #1;
        if (result !== 32'd8) $error("ADD failed: got %0d", result);
        //Test 2
        a = 32'd10; b = 32'd4; alu_ctrl = 4'b0001;
        #1
        if (result !== 32'd6) $error("SUB failed: got 0d", result); 
        //Test 3
        a = 32'd0; b = 32'd0; alu_ctrl = 4'b0000;
        #1
        if (zero !== 1'b1) $error("ZERO failed: got 0d", result);  
        //Test 4    
        a = 32'b10; b = 32'b10; alu_ctrl = 4'b0001;
        #1
        if (result !== 32'd0) $error("ZERO2 failed: got 0d", result);
        if (zero !== 1'b1) $error("ZERO2 failed: got 0d", result);
        //Test 5
        a = 32'h7FFFFFFF; b = 32'd1; alu_ctrl = 4'b0000;
        #1
        if (result !== 32'h80000000) $error("OVERFLOW failed: got 0d", result); 
        a = 32'h80000000; b = 32'h7FFFFFFF; alu_ctrl = 4'b0101;
        #1
        if (result !== 1'b1) $error("SLT failed: got 0d", result);
        a = 32'hFFFFFFFF ; b = 32'h0000001; alu_ctrl = 4'b0101;
        #1
        if (result !== 1'b1) $error("SLT2 failed: got 0d", result);   
        
        if(errors !== 0) $display("Error detected"); 
        else             $display("No errors detected");
        $finish;      
    end
endmodule
