`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 06:05:14 PM
// Design Name: 
// Module Name: riscv_core
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


module riscv_core(
        input  logic clk,
        input  logic reset,
        output logic [3:0] led,
        output logic tx
    );
    
    
    logic [31:0] pc, pc_next, instruction, imm;
    logic [31:0] rs1_data, rs2_data, alu_result, mem_read_data, writeback_data;
    logic [31:0] alu_b;
    logic reg_write, mem_write, alu_src, result_src, branch, jump, zero;
    logic [3:0]  alu_ctrl;
    logic [31:0] debug_reg;
    logic uart_sel;
    logic dmem_write;
    logic uart_write;
    logic lt, ltu; 
    
    assign alu_b = alu_src ? imm : rs2_data;
    assign writeback_data = result_src ? mem_read_data : alu_result;
    assign uart_sel   = alu_result[12];
    assign dmem_write = mem_write & ~uart_sel;
    assign uart_write = mem_write &  uart_sel; 
        
    uart_tx uart(
        .clk(clk),
        .reset(reset),
        .send(uart_write),
        .data_in(rs2_data[7:0]),
        .tx(tx),
        .busy()
    );
    pc programcounter(
        .clk(clk), 
        .reset(reset),
        .pc(pc),
        .pc_next(pc_next)
    );
    
    imem instructionmem(
        .addr(pc),
        .instruction(instruction)
    );
    
    control controller(
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .result_src(result_src),
        .branch(branch),
        .jump(jump),
        .alu_ctrl(alu_ctrl)
    );
    
    imm_gen immediategen(
        .instruction(instruction),
        .imm(imm)
    );
    
    regfile registerfile(
        .clk(clk),
        .reset(reset),
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .debug_reg(debug_reg),
        .reg_write(reg_write),
        .rd_addr(instruction[11:7]),
        .rd_data(writeback_data)
    );
    
    assign led = debug_reg[3:0];
    
    alu arithmeticlu(
        .a(rs1_data),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );
    
    dmem datamem (
        .clk(clk),
        .addr(alu_result),
        .write_data(rs2_data),
        .mem_write(dmem_write),
        .read_data(mem_read_data)
    );
    
    next_pc nextpc (
        .funct3(instruction[14:12]),
        .lt(lt),
        .ltu(ltu),
        .pc(pc),
        .imm(imm),
        .branch(branch),
        .jump(jump),
        .zero(zero),
        .pc_next(pc_next)
    );
endmodule
