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
    
    
    module phase2_tb;
        logic clk = 0;
        logic reset;
        
        int errors = 0;
        always #5 clk = ~clk; 
        logic [7:0] samples [0:58];
        logic msg_valid = 0; 
        logic  [7:0] data_in;
        logic valid; 
        logic [7:0] message_type;
        logic [63:0] order_ref; 
        logic [7:0] side;
        logic [31:0] shares; 
        logic [63:0] stock;
        logic [31:0] price;
        logic [63:0] match;       
        
        itch_parser test(
            .clk(clk),
            .reset(reset),
            .data_in(data_in),
            .msg_valid(msg_valid),
            .valid(valid),
            .msg_type(message_type),
            .order_ref(order_ref), 
            .side(side),
            .shares(shares),
            .stock(stock),
            .price(price),
            .match(match)
        );
        
        
        always @(posedge clk)
            if (valid) $display("done, message_type = %h, order_ref = %h, side = %h, shares = %h, stock = %h, price = %h, match = %h", message_type, order_ref, side, shares, stock, price, match);        
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
                if (i == 20) begin
                    msg_valid = 0;
                    data_in = 8'hFF;  
                    repeat (3) @(negedge clk);
                end
            end
            repeat (5) @(posedge clk);
            $finish; 

        end
    endmodule
