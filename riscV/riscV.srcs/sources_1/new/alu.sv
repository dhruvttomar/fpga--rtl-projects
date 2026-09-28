`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 10:14:29 PM
// Design Name: 
// Module Name: alu
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


module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        zero,
    output logic lt,
    output logic ltu
); 
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR  = 4'b0011;
    localparam XOR = 4'b0100;
    localparam SLT = 4'b0101;
    
    always_comb begin
    case (alu_ctrl)
        ADD: result = a + b; 
        SUB: result = a - b;
        AND: result = a & b;
        OR: result = a | b;
        XOR: result = a ^ b;
        SLT: result = ($signed(a) < $signed(b)) ? 1 : 0;
        default: result = 32'b0; 
    endcase
    end
    
    assign zero = (result == 32'b0);
    assign lt = ($signed(a) < $signed(b)); 
    assign ltu = (a < b); 
endmodule
