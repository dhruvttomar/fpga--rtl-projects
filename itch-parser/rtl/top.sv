`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 08:50:42 PM
// Design Name: 
// Module Name: top
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


module top (input logic clk, input logic reset, input logic [7:0] data_in, input msg_valid, 
            output logic [31:0] best_bid, output logic [31:0] best_ask, output logic bid_valid, output logic ask_valid );
    logic [7:0] msg_type;
    logic [63:0] order_ref; 
    logic [7:0] side; 
    logic [31:0] shares; 
    logic [31:0] price;
    logic valid; 
    itch_parser test(
            .clk(clk),
            .reset(reset),
            .data_in(data_in),
            .msg_valid(msg_valid),
            .valid(valid),
            .msg_type(msg_type),
            .order_ref(order_ref), 
            .side(side),
            .shares(shares),
            .stock(),
            .price(price),
            .match()
    );
    
    order_book test1(
            .clk(clk),
            .reset(reset),
            .msg_done(valid),
            .msg_type(msg_type),
            .order_ref(order_ref),
            .side(side),
            .shares(shares),
            .price(price),
            .best_bid(best_bid),
            .best_ask(best_ask),
            .bid_valid(bid_valid),
            .ask_valid(ask_valid)
    );
    
endmodule
