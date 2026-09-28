`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 09:11:17 PM
// Design Name: 
// Module Name: riscv_core_tb
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


module riscv_core_tb;
    logic clk = 0;
    logic reset;
        
    riscv_core test(
        .clk(clk),
        .reset(reset)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        reset = 1;
        repeat (2)@(posedge clk);
        reset = 0 ;
        
        #500
        $finish;
    end
endmodule
