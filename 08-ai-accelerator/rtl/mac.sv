`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 11:41:03 PM
// Design Name: 
// Module Name: mac
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


module mac(
    input logic clk,
    input logic reset, 
    input logic en, 
    input logic clear, 
    input logic signed [7:0] a, b,
    output logic signed [31:0] acc
    );
    
    logic signed [15:0] prod;
    logic en_d;
    logic clear_d;
    
    always_ff @(posedge clk) begin 
        prod <= a * b;
        en_d <= en;
        clear_d <= clear; 
        if (reset) begin 
            acc <= 32'b0; 
            en_d <= 1'b0; 
            clear_d <= 1'b0;    
        end else if (clear_d == 1'b1) begin 
            acc <= prod;
        end else if (en_d == 1'b1) begin 
            acc <= acc + prod;
        end
    end
    
endmodule
