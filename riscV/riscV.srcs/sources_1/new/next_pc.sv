`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 04:45:54 PM
// Design Name: 
// Module Name: next_pc
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


module next_pc (
    input logic [2:0] funct3,
    input logic lt,
    input logic ltu,
    input  logic [31:0] pc,
    input  logic [31:0] imm,
    input  logic branch,
    input  logic jump,
    input  logic zero,
    output logic [31:0] pc_next
);

    localparam BEQ = 3'b000; 
    localparam BNE = 3'b001; 
    localparam BLT = 3'b100; 
    localparam BGE = 3'b101; 
    localparam BLTU = 3'b110; 
    localparam BGEU = 3'b111; 
    logic cond = 0; 
   
   
    always_comb begin 
        case(funct3)
            BEQ: cond = zero;
            BNE: cond = ~zero;
            BLT: cond = lt; 
            BGE: cond = ~lt; 
            BLTU: cond = ltu;
            BGEU: cond = ~ltu; 
            default: cond = 0;
        endcase
        if (jump) begin
            pc_next = pc + imm; 
        end else if (branch && cond) begin
            pc_next = pc + imm;
        end else begin
            pc_next = pc + 4; 
        end
    end
    
    
        
endmodule
