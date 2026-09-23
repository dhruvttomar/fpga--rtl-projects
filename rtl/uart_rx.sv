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

module uart_rx (
    input  logic clk,
    input  logic reset,
    input  logic rx,
    output logic [3:0] led,
    output logic [7:0] data_out,
    output logic data_valid
);
    localparam CLK_FREQ       = 100_000_000;
    localparam BAUD_RATE      = 115_200;
    localparam CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT       = CYCLES_PER_BIT / 2;

    typedef enum logic [1:0] {IDLE, START, RECEIVE, STOP} state_e;

    state_e state, next_state;
    logic rx_1, rx_2, rx_previous;
    logic [9:0] cyclecounter, next_cyclecounter;
    logic [2:0] bitindexcounter, next_bitindexcounter;
    logic [7:0] data, next_data;

    always_ff @(posedge clk) begin
        if (reset) begin
            state           <= IDLE;
            rx_1            <= 1'b1;
            rx_2            <= 1'b1;
            rx_previous     <= 1'b1;
            cyclecounter    <= 0;
            bitindexcounter <= 0;
            data            <= 0;
            data_out        <= 0;
            data_valid      <= 0;
            led             <= 0;
        end else begin
            state           <= next_state;
            rx_1            <= rx;
            rx_2            <= rx_1;
            rx_previous     <= rx_2;
            cyclecounter    <= next_cyclecounter;
            bitindexcounter <= next_bitindexcounter;
            data            <= next_data;

            data_valid <= 1'b0;
            if (state == STOP && next_state == IDLE) begin
                led        <= data[3:0];
                data_out   <= data;
                data_valid <= 1'b1;
            end
        end
    end

    always_comb begin
        next_state           = state;
        next_cyclecounter    = cyclecounter;
        next_bitindexcounter = bitindexcounter;
        next_data            = data;

        case (state)
            IDLE: begin
                next_cyclecounter = 10'b0;
                if (rx_previous & ~rx_2)
                    next_state = START;
            end
            START: begin
                if (cyclecounter == HALF_BIT - 1) begin
                    next_cyclecounter = 10'b0;
                    if (rx_2 == 1'b0) begin
                        next_state           = RECEIVE;
                        next_bitindexcounter = 3'b0;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin
                    next_cyclecounter = cyclecounter + 1;
                end
            end
            RECEIVE: begin
                if (cyclecounter == CYCLES_PER_BIT - 1) begin
                    next_cyclecounter    = 10'b0;
                    next_data            = {rx_2, data[7:1]};
                    next_bitindexcounter = bitindexcounter + 1;
                    if (bitindexcounter == 7)
                        next_state = STOP;
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