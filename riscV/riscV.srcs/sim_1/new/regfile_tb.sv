`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 10:25:04 PM
// Design Name: 
// Module Name: alu_tb
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


module regfile_tb;
    logic clk;
    logic reset;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        reg_write;
    logic [4:0]  rd_addr;
    logic [31:0] rd_data;

    int errors = 0;

    regfile dut (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .reg_write(reg_write),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );
    
    
    initial begin
        //Test 1
        rd_addr = 5'd5;
        rd_data = 32'd42;
        reg_write = 1;
        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd5;
        #1;
        if (rs1_data !== 32'd42) begin
            $error("Read incorrect value: got %0d", rs1_data);      
            errors =  errors + 1;   
        end     
        //Test 2
        rs1_addr = 5'd0;
        #1
        if (rs1_data !== 32'd0) begin
            $error("0 register incorrect value: got %0d", rs1_data);
            errors = errors + 1;
        end
        //Test 3
        rd_addr = 5'd0;
        rd_data = 32'd99;
        reg_write = 1;
        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd0;       
        if (rs1_data !== 32'd42) begin
            $error("0 register incorrect value test 2: got %0d", rs1_data);      
            errors =  errors + 1;   
        end     
        //Test 4
        rd_addr = 5'd5; rd_data = 32'd42; reg_write = 1;
        @(posedge clk);
        rd_addr = 5'd6; rd_data = 32'd77;
        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd5;
        rs2_addr = 5'd6;
        #1;
        if (rs1_data !== 32'd42) $error("port 1 wrong: got %0d", rs1_data);
        if (rs2_data !== 32'd77) $error("port 2 wrong: got %0d", rs2_data);
        
        if (errors !== 0) $display ("Errors detected");
        else              $display ("No errors detected");
        $finish;  
        
              

              
    end
endmodule
