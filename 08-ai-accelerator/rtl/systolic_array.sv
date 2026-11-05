`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 02:17:00 PM
// Design Name: 
// Module Name: systolic_array
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


module systolic_array(
    input logic clk, reset, clear, 
    input logic signed [7:0] a_left [0:3],
    input logic signed [7:0] b_top [0:3],
    output logic signed [31:0] c [0:3][0:3]
    );
    
    logic signed [7:0] a_wires [0:3][0:4];
    logic signed [7:0] b_wires [0:4][0:3];
    
    genvar k;
    generate 
        for (k = 0; k < 4; k++) begin : assignment
            assign a_wires[k][0] = a_left[k];
            assign b_wires[0][k] = b_top[k];
        end
    endgenerate
        
    genvar i;
    genvar j;
    generate 
        for (i = 0; i < 4; i++) begin : row
            for ( j = 0; j < 4; j++) begin : column
                pe p1 (
                    .clk(clk),
                    .reset(reset),
                    .clear(clear),
                    .a_in(a_wires[i][j]),
                    .b_in(b_wires[i][j]),
                    .a_out(a_wires[i][j+1]),
                    .b_out(b_wires[i+1][j]),
                    .acc(c[i][j])
                );
            end 
        end
    endgenerate
    
        
            
endmodule
