`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2026 06:54:18 PM
// Design Name: 
// Module Name: fifo
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

module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic reset,
    // write domain
    input  logic wr_clk,
    input  logic wr_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic full,
    // read domain
    input  logic rd_clk,
    input  logic rd_en,
    output logic [WIDTH-1:0] rd_data,
    output logic empty
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [4:0] wr_ptr = 0, r_ptr = 0;
    logic [4:0] wr_ptr_gray = 0, r_ptr_gray = 0;
    logic [4:0] sync1wr = 0, sync2wr = 0;
    logic [4:0] sync1r = 0, sync2r = 0;
    logic [4:0] wr_ptr_next, r_ptr_next;

    assign wr_ptr_next = wr_ptr + 1;
    assign r_ptr_next  = r_ptr + 1;

    always_ff @(posedge wr_clk) begin
        if (reset) begin
            wr_ptr      <= 0;
            wr_ptr_gray <= 0;
            sync1r      <= 0;
            sync2r      <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[3:0]] <= wr_data;
                wr_ptr      <= wr_ptr_next;
                wr_ptr_gray <= wr_ptr_next ^ (wr_ptr_next >> 1);
            end
            sync1r <= r_ptr_gray;
            sync2r <= sync1r;
        end
    end

    always_ff @(posedge rd_clk) begin
        if (reset) begin
            r_ptr      <= 0;
            r_ptr_gray <= 0;
            rd_data    <= 0;
            sync1wr    <= 0;
            sync2wr    <= 0;
        end else begin
            if (rd_en && !empty) begin
                rd_data    <= mem[r_ptr[3:0]];
                r_ptr      <= r_ptr_next;
                r_ptr_gray <= r_ptr_next ^ (r_ptr_next >> 1);
            end
            sync1wr <= wr_ptr_gray;
            sync2wr <= sync1wr;
        end
    end
    always_comb begin
        empty = (r_ptr_gray == sync2wr);
        full  = (wr_ptr_gray == {~sync2r[4:3], sync2r[2:0]});
    end
endmodule