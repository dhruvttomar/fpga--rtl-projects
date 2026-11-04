`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 03:39:48 PM
// Design Name: 
// Module Name: systolic_array_tb
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



module systolic_array_tb;
    logic clk = 0, reset = 1, clear = 0;
    logic signed [7:0]  a_left [0:3];
    logic signed [7:0]  b_top  [0:3];
    logic signed [31:0] c [0:3][0:3];

    systolic_array dut (.*);

    always #5 clk = ~clk;

    logic signed [7:0] A [0:3][0:3];
    logic signed [7:0] B [0:3][0:3];
    int expected [0:3][0:3];
    int errors = 0;

    initial begin
        A = '{'{ 1,  2,  3, 4}, '{-1, 0, 5, 2}, '{3, -2, 1, 0}, '{7, 1, -4, 2}};
        B = '{'{ 2,  0,  1, -1}, '{ 1, 3, 0, 2}, '{-2, 1, 4, 0}, '{0, 5, -3, 1}};

        // software reference
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++) begin
                expected[i][j] = 0;
                for (int k = 0; k < 4; k++)
                    expected[i][j] += A[i][k] * B[k][j];
            end

        for (int r = 0; r < 4; r++) begin a_left[r] = 0; b_top[r] = 0; end

        repeat (2) @(negedge clk);
        reset = 0;
        @(negedge clk); clear = 1;      // zero every PE's sum
        @(negedge clk); clear = 0;

        // feed the staircase: row r of A and column r of B start r cycles late
        for (int t = 0; t < 10; t++) begin
            for (int r = 0; r < 4; r++) begin
                a_left[r] = (t - r >= 0 && t - r < 4) ? A[r][t - r] : 8'sd0;
                b_top[r]  = (t - r >= 0 && t - r < 4) ? B[t - r][r] : 8'sd0;
            end
            @(negedge clk);
        end

        // zero padding while the last values drain through
        for (int r = 0; r < 4; r++) begin a_left[r] = 0; b_top[r] = 0; end
        repeat (6) @(negedge clk);

        // check all 16 results
        for (int i = 0; i < 4; i++) begin
            $display("%4d %4d %4d %4d", c[i][0], c[i][1], c[i][2], c[i][3]);
            for (int j = 0; j < 4; j++)
                if (c[i][j] !== expected[i][j]) begin
                    $error("C[%0d][%0d]: got %0d, expected %0d", i, j, c[i][j], expected[i][j]);
                    errors++;
                end
        end
        $display("%0d errors", errors);
        $finish;
    end
endmodule
