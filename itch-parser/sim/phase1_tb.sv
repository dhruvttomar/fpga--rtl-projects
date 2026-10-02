`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2026 11:50:19 PM
// Design Name: 
// Module Name: phase1_tb
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


module phase1_tb;
    logic clk = 0;
    logic reset;
    
    itch_parser test(
        .clk(clk),
        .reset(reset),
        .data_in(),
        .msg_valid(),
        .valid(),
        .msg_type()
    );
endmodule
