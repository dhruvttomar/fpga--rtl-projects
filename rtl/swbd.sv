    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 08/09/2026 10:24:46 PM
    // Design Name: 
    // Module Name: swbd
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
    
    
    `timescale 1ns / 1ps
    module swbd (
        input  logic [3:0] btn,
        input  logic clk,
        output logic [3:0] led
    );
        logic syn1, syn2; 
        logic prev; 
        logic [19:0] counter; 
        logic btnfinish, btnprev;  
        
        
        localparam THRESHOLD = 1_000_000;
         
         always_ff @(posedge clk) begin
            syn1 <= btn[0];
            syn2 <= syn1;
            
            prev <= syn2; 
            if (prev != syn2) begin 
                counter <= 0;
            end else if (counter < THRESHOLD) begin
                counter <= counter + 1;
            end else begin
                btnfinish <= syn2;
            end
            
            btnprev <= btnfinish;
            if (btnprev ^ btnfinish) begin
                led[0] <= ~led[0];
            end
        end
            
             
        
         
    endmodule
