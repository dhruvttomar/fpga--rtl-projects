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


module uart_tx (
    input  logic clk,
    input  logic reset,
    input  logic send,
    input  logic [7:0] data_in,
    output logic tx,
    output logic busy
);
    localparam CLK_FREQ       = 100_000_000;
    localparam BAUD_RATE      = 115_200;
    localparam CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {IDLE, START, SEND, STOP} state_e;

    state_e state, next_state;
    logic [9:0] cyclecounter, next_cyclecounter;
    logic [2:0] bitindexcounter, next_bitindexcounter;
    logic [7:0] data, next_data;

    always_ff @(posedge clk) begin
        if (reset) begin
            state           <= IDLE;
            cyclecounter    <= 0;
            bitindexcounter <= 0;
            data            <= 0;
        end else begin
            state           <= next_state;
            cyclecounter    <= next_cyclecounter;
            bitindexcounter <= next_bitindexcounter;
            data            <= next_data;
        end
    end

    always_comb begin
        next_state           = state;
        next_cyclecounter    = cyclecounter;
        next_bitindexcounter = bitindexcounter;
        next_data            = data;
        tx                   = 1'b1;
        busy                 = 1'b1;

        case (state)
            IDLE: begin
                busy                 = 1'b0;
                next_cyclecounter    = 10'b0;
                next_bitindexcounter = 3'b0;
                if (send) begin
                    next_data  = data_in;
                    next_state = START;
                end
            end
            START: begin
                tx = 1'b0;
                if (cyclecounter == CYCLES_PER_BIT - 1) begin
                    next_cyclecounter = 10'b0;
                    next_state        = SEND;
                end else begin
                    next_cyclecounter = cyclecounter + 1;
                end
            end
            SEND: begin
                tx = data[0];
                if (cyclecounter == CYCLES_PER_BIT - 1) begin
                    next_cyclecounter    = 10'b0;
                    next_data            = {1'b0, data[7:1]};
                    next_bitindexcounter = bitindexcounter + 1;
                    if (bitindexcounter == 7) begin
                        next_state           = STOP;
                        next_bitindexcounter = 3'b0;
                    end
                end else begin
                    next_cyclecounter = cyclecounter + 1;
                end
            end
            STOP: begin
                if (cyclecounter == CYCLES_PER_BIT - 1) begin
                    next_cyclecounter = 10'b0;
                    next_state        = IDLE;
                end else begin
                    next_cyclecounter = cyclecounter + 1;
                end
            end
            default: next_state = IDLE;
        endcase
    end
endmodule