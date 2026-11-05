`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 04:26:40 PM
// Design Name: 
// Module Name: gemm_core
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

module gemm_core(
    input logic clk,
    input logic start,
    input logic reset, 
    input logic wr_en,
    input logic wr_sel,
    input logic [1:0] wr_bank,
    input logic [2:0] wr_addr,
    input logic signed [7:0] wr_data,
    output logic done,
    output logic signed [31:0] c [0:3][0:3]
    );
    
    logic signed [7:0] a_mem [0:3][0:7];
    logic signed [7:0] b_mem [0:3][0:7];
    logic signed [7:0] a_left [0:3];
    logic signed [7:0] b_top  [0:3];
    
    typedef enum logic [3:0] {
        IDLE, 
        CLEAR, 
        FEED,
        DRAIN,
        DONE
    } state_t;

    state_t state, next_state;
    logic [3:0] t; 
    logic clear;
    logic feeding; 
    
    systolic_array sa(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .a_left(a_left),
        .b_top(b_top),
        .c(c)
    );
    always_comb begin
        for (int r = 0; r < 4; r++) begin 
            if (feeding && t >= r && t < r + 8) begin
                a_left[r] = a_mem[r][t - r];
                b_top[r]  = b_mem[r][t - r];
            end else begin
                a_left[r] = 0;
                b_top[r]  = 0;
            end    
        end
    end
    always_ff @(posedge clk) begin
        if (reset) begin
        end
        else if (wr_en) begin
            if (wr_sel) begin
                b_mem[wr_bank][wr_addr] <= wr_data; 
            end else begin
                a_mem[wr_bank][wr_addr] <= wr_data; 
            end
        end
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE; 
        end 
        else begin
            state <= next_state; 
            if (state == CLEAR) begin         
                t <= 0;
            end
            else if (state == FEED && t == 10) begin
                t <= 0; 
            end
            else if (state == FEED || state == DRAIN) begin
                t <= t + 1;
            end
        end
    end
    always_comb begin
        next_state = state; 
        clear = 0; 
        done = 0; 
        feeding = 0; 
        case(state)
            IDLE: begin
                if (start) begin
                    next_state = CLEAR;
                end
            end
            CLEAR: begin
                clear = 1; 
                next_state = FEED;
            end
            FEED: begin
                feeding = 1; 
                if (t == 10) begin
                    next_state = DRAIN; 
                end 
            end
            DRAIN: begin
                if (t == 5) begin
                    next_state = DONE; 
                end
            end
            DONE: begin
                done = 1; 
                next_state = IDLE; 
            end
        default: 
            next_state = IDLE;
        endcase   
    end
endmodule
