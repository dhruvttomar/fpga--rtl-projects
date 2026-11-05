`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2026 01:36:17 PM
// Design Name: 
// Module Name: PWMproj3
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


module PWMproj3(
    input clk,
    output logic led
    );

    logic [7:0] counter;
    logic [18:0] dutycounter;
    localparam dc = 390625;
    logic [7:0] duty = 0;
    logic dir = 0;              // 0 = brightening, 1 = dimming

    always_ff @(posedge clk) begin
        // Job 1: PWM, every cycle
        counter <= counter + 1;
        if (counter < duty)
            led <= 1'b1;
        else
            led <= 1'b0;

        // Job 2: slow breathing sweep
        dutycounter <= dutycounter + 1;
        if (dutycounter >= dc) begin
            dutycounter <= 0;
            if (dir == 0) begin
                if (duty == 254)
                    dir <= 1;      // reached top, start dimming
                duty <= duty + 1;
            end else begin
                if (duty == 1)
                    dir <= 0;      // reached bottom, start brightening
                duty <= duty - 1;
            end
        end
    end
endmodule
