`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 11:09:42 PM
// Design Name: 
// Module Name: async_fifo_tb
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

module async_fifo_tb;

    logic wr_clk = 0, rd_clk = 0;
    logic wr_en = 0, rd_en = 0;
    logic [7:0] wr_data = 0, rd_data;
    logic full, empty;
    logic reset = 1;

    int errors = 0;

    async_fifo #(.WIDTH(8), .DEPTH(16)) dut (
        .reset(reset),
        .wr_clk(wr_clk), .wr_en(wr_en), .wr_data(wr_data), .full(full),
        .rd_clk(rd_clk), .rd_en(rd_en), .rd_data(rd_data), .empty(empty)
    );

    always #5  wr_clk = ~wr_clk;
    always #17 rd_clk = ~rd_clk;

    task write_byte(input logic [7:0] value);
        @(posedge wr_clk);
        while (full) @(posedge wr_clk);
        wr_data = value;
        wr_en   = 1;
        @(posedge wr_clk);
        wr_en = 0;
    endtask

    task read_byte(output logic [7:0] value);
        @(posedge rd_clk);
        while (empty) @(posedge rd_clk);
        rd_en = 1;
        @(posedge rd_clk);
        rd_en = 0;
        @(posedge rd_clk);
        value = rd_data;
    endtask

    // ---------- WRITER ----------
    initial begin
        reset = 1;
        repeat (4) @(posedge wr_clk);
        reset = 0;

        for (int i = 0; i < 16; i++)
            write_byte(i);

        for (int i = 100; i < 116; i++)
            write_byte(i);

        for (int i = 200; i < 208; i++) begin
            repeat (40) @(posedge wr_clk);
            write_byte(i);
        end
    end

    // ---------- READER ----------
    initial begin
        logic [7:0] got;

        @(negedge reset);

        for (int i = 0; i < 16; i++) begin
            read_byte(got);
            if (got !== i[7:0]) begin
                $error("TEST1 slot %0d: expected %0d, got %0d", i, i, got);
                errors++;
            end
        end
        $display("TEST 1 complete");

        for (int i = 100; i < 116; i++) begin
            repeat (30) @(posedge rd_clk);
            read_byte(got);
            if (got !== i[7:0]) begin
                $error("TEST2 slot %0d: expected %0d, got %0d", i, i, got);
                errors++;
            end
        end
        $display("TEST 2 complete");

        for (int i = 200; i < 208; i++) begin
            read_byte(got);
            if (got !== i[7:0]) begin
                $error("TEST3 slot %0d: expected %0d, got %0d", i, i, got);
                errors++;
            end
        end
        $display("TEST 3 complete");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("FAILED with %0d errors", errors);
        $finish;
    end

    initial begin
        #500000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
