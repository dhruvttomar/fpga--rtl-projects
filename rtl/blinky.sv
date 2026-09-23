`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2026 10:53:38 PM
// Design Name: 
// Module Name: blinky
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


module blinky (
    input  logic clk,        // 100 MHz board clock
    output logic led          // one LED
);
    logic [25:0] counter = 0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    assign led = counter[25]; // toggles ~1.5 Hz at 100 MHz

endmodule
