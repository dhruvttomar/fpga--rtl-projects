`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 02:07:28 AM
// Design Name: 
// Module Name: control
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


module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic       mem_write,
    output logic       alu_src,
    output logic       result_src,
    output logic       branch,
    output logic       jump,
    output logic [3:0] alu_ctrl
    );
    
    localparam rtype = 7'b0110011; 
    localparam itype = 7'b0010011; 
    localparam lwtype = 7'b0000011;
    localparam swtype = 7'b0100011;
    localparam beqtype = 7'b1100011;
    localparam luitype = 7'b0110111;
    localparam jaltype = 7'b1101111;
    
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR  = 4'b0011;
    localparam XOR = 4'b0100;
    localparam SLT = 4'b0101;
     
    always_comb begin
        reg_write = 0;
        mem_write = 0;
        alu_src = 0;
        result_src = 0;
        branch = 0;
        jump = 0;
        alu_ctrl = ADD; 
        case(opcode)
            rtype: begin
                reg_write = 1;
                mem_write = 0; 
                branch = 0; 
                jump = 0; 
                alu_src = 0; 
                case(funct3)
                    3'b000: begin
                        if (funct7[5] == 1'b1) alu_ctrl = SUB;
                        else                   alu_ctrl = ADD;
                    end
                    3'b010: alu_ctrl = SLT;
                    3'b100: alu_ctrl = XOR;
                    3'b110: alu_ctrl = OR;
                    3'b111: alu_ctrl = AND;
                    default: alu_ctrl = ADD; 
                endcase     
            end
            itype: begin
                reg_write = 1;
                mem_write = 0; 
                branch = 0; 
                jump = 0; 
                alu_src = 1; 
                case(funct3)
                    3'b000: alu_ctrl = ADD;
                    3'b010: alu_ctrl = SLT;
                    3'b100: alu_ctrl = XOR;
                    3'b110: alu_ctrl = OR;
                    3'b111: alu_ctrl = AND;
                    default: alu_ctrl = ADD; 
                endcase   
            end
            lwtype: begin 
                reg_write = 1; 
                mem_write = 0; 
                alu_src = 1;
                result_src = 1; 
                branch = 0;
                jump = 0; 
                alu_ctrl = ADD; 
            end
            swtype: begin
                reg_write = 0; 
                mem_write = 1; 
                alu_src = 1; 
                alu_ctrl = ADD;
                branch = 0;
                jump = 0; 
            end            
            beqtype: begin
                reg_write = 0; 
                branch = 1; 
                alu_src = 0; 
                alu_ctrl = SUB;
                jump = 0;
            end
            luitype: begin
                reg_write = 1; 
                mem_write = 0; 
                alu_src = 1;
                result_src = 0; 
                branch = 0;
                jump = 0; 
                alu_ctrl = ADD;
            end
            jaltype: begin
                reg_write = 1'b1; 
                jump = 1'b1;
                mem_write = 0;
            end
            default: begin
                reg_write = 0;
                mem_write = 0;
                alu_src = 0;
                result_src = 0;
                branch = 0;
                jump = 0;
                alu_ctrl = ADD; 
            end
        endcase
    end
endmodule
