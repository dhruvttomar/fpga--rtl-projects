`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 01:44:42 PM
// Design Name: 
// Module Name: pe
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


module pe(
    input logic clk, 
    input logic reset, 
    input logic clear, 
    input logic signed [7:0] a_in, b_in,
    output logic signed [7:0] a_out, b_out,
    output logic signed [31:0] acc
    );
    
    mac m2(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .clear(clear),
        .a(a_in),
        .b(b_in),
        .acc(acc)
    );
    
    always_ff @(posedge clk) begin 
        a_out <= a_in;
        b_out <= b_in;
        if (reset) begin
            a_out <= '0;
            b_out <= '0;
        end 
    end
endmodule
