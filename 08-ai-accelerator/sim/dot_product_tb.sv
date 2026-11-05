`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2026 11:29:07 PM
// Design Name: 
// Module Name: dot_product_tb
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


module dot_product_tb;
    logic clk = 0, reset = 1;
    logic valid_in = 0, last_in = 0;
    logic signed [7:0]  a = 0, b = 0;
    logic signed [31:0] result;
    logic done;

    dot_product dut (.*);

    always #5 clk = ~clk;

    task send(input logic signed [7:0] x, y, input logic is_last);
        @(negedge clk);
        valid_in = 1;
        a = x;
        b = y;
        last_in = is_last;
    endtask

    always @(posedge clk)
        if (done) $display("result = %0d", result);

    initial begin
        repeat (2) @(negedge clk);
        reset = 0;

        send(1, 4, 0);
        send(2, 5, 0);
        send(3, 6, 1);

        send(-1, 3, 0);
        send(7, 2, 1);

        @(negedge clk);
        valid_in = 0;
        last_in  = 0;

        repeat (5) @(negedge clk);
        $finish;
    end
endmodule