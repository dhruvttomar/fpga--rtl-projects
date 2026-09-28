`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2026 11:52:44 PM
// Design Name: 
// Module Name: imm_gen_tb
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


module imm_gen_tb;
    logic [31:0] instruction;
    logic [31:0] imm;
    
    int errors = 0; 
    
    imm_gen dut (
        .instruction(instruction),
        .imm(imm)
    );
    
    initial begin
        //Test 1
        instruction[6:0] = 7'b0010011;
        if (imm !== {{20{instruction[31]}}, instruction[31:20]}) $error("I, I2 wrong: got %0d", instruction);
        errors = errors + 1;
        //Test 2
        instruction[6:0] = 7'b0000011;
        if (imm !== {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}) $error("S wrong: got %0d", instruction);
        errors = errors + 1;
        //Test 3
        instruction[6:0] = 7'b0100011;
        if (imm !== {instruction[31:12], 12'b0}) $error("U wrong: got %0d", instruction);
        errors = errors + 1;
        //Test 4
        instruction[6:0] = 7'b1100011;
        if (imm !== {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}) $error("B wrong: got %0d", instruction);
        errors = errors + 1;
        //Test 5
        instruction[6:0] = 7'b0110111;
        if (imm !== {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}) $error("J wrong: got %0d", instruction);
        errors = errors + 1;
        
        if (errors !== 0) $display("Errors detected above");
        else              $display("No errors detected above");
        $finish;
    end
endmodule
