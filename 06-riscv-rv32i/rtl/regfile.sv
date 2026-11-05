`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 12:44:02 AM
// Design Name: 
// Module Name: regfile
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


module regfile (
    input  logic clk,
    input  logic reset,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] debug_reg,
    input  logic        reg_write,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data
);

    logic [31:0] regs[0:31]; 
    
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];
    assign debug_reg = regs[11];
    
    
    always_ff @ (posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; ++i) begin
                regs[i] <= 0; 
            end
        end
        else if (reg_write && rd_addr != 5'd0) begin 
            regs[rd_addr] <= rd_data;
        end
    end
endmodule
