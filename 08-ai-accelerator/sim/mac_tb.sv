`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 06:00:19 PM
// Design Name: 
// Module Name: mac_tb
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


module mac_tb;
    logic reset = 1;
    logic clk = 0; 
    logic en = 0;
    logic signed [7:0] a,b; 
    logic clear = 0; 
    logic signed [31:0] acc;
    logic signed [31:0] expected;  
    
    always #5 clk = ~clk; 
    mac dut (.*);

    initial begin
        repeat (2) @(negedge clk);
        reset = 0;
            
        clear = 1; 
        a = 3;
        b = 4; 
        expected = 12;  
        repeat (2) @(posedge clk);
        if (acc != expected) $error("mismatch: got %0d, expected %0d", acc, expected);
        @(negedge clk); 
        
        clear = 0; 
        en = 1'b1; 
        a = -2;
        b = 5; 
        expected = expected + acc;
        repeat (2) @(posedge clk);
        if (acc != expected) $error("mismatch: got %0d, expected %0d", acc, expected);
        @(negedge clk); 

        clear = 0; 
        en = 1'b1; 
        a = -128;
        b = -128; 
        expected = expected + (a * b);
        repeat (2) @(posedge clk);
        if (acc != expected) $error("mismatch: got %0d, expected %0d", acc, expected);
        @(negedge clk); 
        
        clear = 0;
        en = 0;
        repeat (2) @(posedge clk);
        if (acc != expected) $error("mismatch: got %0d, expected %0d", acc, expected);
        @(negedge clk); 
        
        
    end     
endmodule
