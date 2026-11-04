`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2026 01:33:35 AM
// Design Name: 
// Module Name: dot_product
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


module dot_product(
    input logic clk, 
    input logic reset, 
    input logic valid_in, last_in,
    input logic signed [7:0] a,b,
    output logic signed [31:0] result,
    output logic done 
    );
    
    logic clear;
    logic en; 
    logic busy; 
    logic last_d1; 
    
    mac m1(
        .clk(clk),
        .reset(reset),
        .en(en),
        .clear(clear),
        .a(a),
        .b(b),
        .acc(result)
    );
    
    assign clear = valid_in & ~busy;
    assign en = valid_in & busy; 
    
    always_ff @(posedge clk) begin
        if (reset) begin
            busy <= 1'b0;
            clear <= 1'b0; 
            last_d1 <= 1'b0;  
            done <= 1'b0;      
        end
        if (valid_in == 1'b1) begin
            if (last_in == 1'b1) begin
                busy <= 1'b0; 
            end else begin
                busy <= 1'b1;
            end
        end 
        last_d1 <= valid_in && last_in;
        done <= last_d1; 
    end
    
endmodule
