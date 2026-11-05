`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:17:15 AM
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


module top (
    input  logic clk,
    input  logic reset,
    input  logic rx,
    output logic tx,
    output logic [3:0] led
);
    logic [7:0] rx_byte;
    logic rx_valid;
    logic tx_busy;

    uart_rx receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .led(led),
        .data_out(rx_byte),
        .data_valid(rx_valid)
    );

    uart_tx transmitter (
        .clk(clk),
        .reset(reset),
        .send(rx_valid),
        .data_in(rx_byte),
        .tx(tx),
        .busy(tx_busy)
    );
endmodule