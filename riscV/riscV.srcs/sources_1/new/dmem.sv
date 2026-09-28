`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 01:41:26 AM
// Design Name: 
// Module Name: dmem
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


module dmem (
    input  logic clk,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    input  logic        mem_write,
    output logic [31:0] read_data
);
    logic [31:0] mem[0:255];
    assign read_data = mem[addr[31:2]];
    
    always_ff @(posedge clk) begin
        if (mem_write) begin
            mem[addr[31:0]] <= write_data;
        end
    end
   
endmodule
