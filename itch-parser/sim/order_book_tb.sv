`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 08:15:56 PM
// Design Name: 
// Module Name: order_book_tb
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

module order_book_tb;
    logic clk = 0, reset = 1, msg_done = 0;
    logic [7:0]  msg_type, side;
    logic [63:0] order_ref;
    logic [31:0] shares, price;

    order_book dut (.*);

    always #5 clk = ~clk;

    task send(input [7:0] t, input [63:0] r, input [7:0] s, input [31:0] sh, input [31:0] p);
        @(negedge clk);
        msg_type = t; 
        order_ref = r; 
        side = s; 
        shares = sh; 
        price = p;
        msg_done = 1;
        @(negedge clk);
        msg_done = 0;
        repeat (3) @(negedge clk);
    endtask

    initial begin
        repeat (3) @(negedge clk);
        reset = 0;

        send(8'h41, 64'd1, 8'h42, 32'd100, 32'd1000000);
        send(8'h41, 64'd2, 8'h42, 32'd200, 32'd1015000);
        send(8'h41, 64'd3, 8'h42, 32'd300, 32'd992500);
        $display("after adds:   best_bid = %0d, ref = %0d", dut.best_bid, dut.best_bid_ref);

        send(8'h44, 64'd2, 8'h00, 32'd0, 32'd0);
        repeat (4200) @(negedge clk);
        $display("after delete: best_bid = %0d, ref = %0d, valid = %0d",dut.best_bid, dut.best_bid_ref, dut.bid_valid);

        send(8'h41, 64'd4, 8'h53, 32'd150, 32'd1020000);
        send(8'h41, 64'd5, 8'h53, 32'd250, 32'd1035000);
        $display("after sells:  best_ask = %0d, ref = %0d", dut.best_ask, dut.best_ask_ref);

        send(8'h44, 64'd4, 8'h00, 32'd0, 32'd0);
        repeat (4200) @(negedge clk);
        $display("after delete: best_ask = %0d, ref = %0d, valid = %0d",dut.best_ask, dut.best_ask_ref, dut.ask_valid);
        $finish;
    end
endmodule
