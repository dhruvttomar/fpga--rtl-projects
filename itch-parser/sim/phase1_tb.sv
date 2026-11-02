    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 09/28/2026 11:50:19 PM
    // Design Name: 
    // Module Name: phase1_tb
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
    
    
    module phase1_tb;
        logic clk = 0;
        logic reset;
        
        int errors = 0;
        always #5 clk = ~clk; 
        logic [7:0] samples [0:58];
        logic msg_valid = 0; 
        logic  [7:0] data_in;
        logic valid; 
        logic [7:0] message_type;
        
        
        itch_parser test(
            .clk(clk),
            .reset(reset),
            .data_in(data_in),
            .msg_valid(msg_valid),
            .valid(valid),
            .msg_type(message_type)
        );
        
        
        always @(posedge clk)
            if (valid) $display("done, result = %h", message_type);        
        initial begin
            reset = 1;
            repeat (4) @(posedge clk);
            reset = 0;
            $readmemh("C:/Users/dhruv/Downloads/stream.hex", samples);
            
            @(negedge clk); 
            for (int i = 0; i < 59; i++) begin
                data_in = samples[i];
                msg_valid = 1; 
                @(negedge clk);
                msg_valid = 0;
            end
            repeat (5) @(posedge clk);
            $finish; 

        end
    endmodule
