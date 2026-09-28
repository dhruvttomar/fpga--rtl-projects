`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 09:02:19 PM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen (
    input  logic [31:0] instruction,
    output logic [31:0] imm
);
    localparam I = 7'b0010011;
    localparam I2 = 7'b0000011;
    localparam S = 7'b0100011;
    localparam B = 7'b1100011;
    localparam U = 7'b0110111;
    localparam J = 7'b1101111;

    always_comb begin
        case(instruction[6:0])
            I, I2: imm = {{20{instruction[31]}}, instruction[31:20]};
            S:     imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            U:     imm = {instruction[31:12], 12'b0};
            B:     imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            J:     imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
              default: imm = 32'b0; 
        endcase
    end
endmodule
