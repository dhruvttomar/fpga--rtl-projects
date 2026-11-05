`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 06:04:20 PM
// Design Name: 
// Module Name: gemm_core_tb
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

module gemm_core_tb;
    logic clk = 0, reset = 1, start = 0;
    logic wr_en = 0, wr_sel = 0;
    logic [1:0] wr_bank = 0;
    logic [2:0] wr_addr = 0;
    logic signed [7:0]  wr_data = 0;
    logic done;
    logic signed [31:0] c [0:3][0:3];

    gemm_core dut (.*);

    always #5 clk = ~clk;

    logic signed [7:0] A [0:7][0:7];
    logic signed [7:0] B [0:7][0:7];
    int expected [0:7][0:7];
    int C_hw     [0:7][0:7];
    int errors = 0;

    task write_mem(input logic sel, input logic [1:0] bank, input logic [2:0] addr,
                   input logic signed [7:0] data);
        @(negedge clk);
        wr_en = 1; wr_sel = sel; wr_bank = bank; wr_addr = addr; wr_data = data;
        @(negedge clk);
        wr_en = 0;
    endtask

    initial begin
        for (int i = 0; i < 8; i++)
            for (int j = 0; j < 8; j++) begin
                A[i][j] = $urandom_range(0, 255) - 128;
                B[i][j] = $urandom_range(0, 255) - 128;
            end

        for (int i = 0; i < 8; i++)
            for (int j = 0; j < 8; j++) begin
                expected[i][j] = 0;
                for (int k = 0; k < 8; k++)
                    expected[i][j] += A[i][k] * B[k][j];
            end

        repeat (2) @(negedge clk);
        reset = 0;

        for (int bi = 0; bi < 2; bi++)
            for (int bj = 0; bj < 2; bj++) begin
                for (int r = 0; r < 4; r++)
                    for (int k = 0; k < 8; k++)
                        write_mem(0, r, k, A[bi*4 + r][k]);
                for (int col = 0; col < 4; col++)
                    for (int k = 0; k < 8; k++)
                        write_mem(1, col, k, B[k][bj*4 + col]);

                @(negedge clk); start = 1;
                @(negedge clk); start = 0;
                wait (done == 1);
                @(negedge clk);

                for (int i = 0; i < 4; i++)
                    for (int j = 0; j < 4; j++)
                        C_hw[bi*4 + i][bj*4 + j] = c[i][j];
            end

        for (int i = 0; i < 8; i++)
            for (int j = 0; j < 8; j++)
                if (C_hw[i][j] !== expected[i][j]) begin
                    $error("C[%0d][%0d]: got %0d, expected %0d", i, j, C_hw[i][j], expected[i][j]);
                    errors++;
                end

        $display("8x8 multiply: %0d errors out of 64", errors);
        $finish;
    end
endmodule