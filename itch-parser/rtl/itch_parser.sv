`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2026 01:53:53 AM
// Design Name: 
// Module Name: itch_parser
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


module itch_parser (
    input  logic clk,
    input  logic reset,
    input  logic [7:0] data_in,
    input  logic msg_valid,
    output logic valid, 
    output logic [7:0] msg_type
);
    
    logic [15:0] internal_length = 16'b0; 
    logic [15:0] counter = 16'b0;  
    
    typedef enum logic [1:0] {
        IDLE,
        START,
        RECEIVE
    } state_t;
    
    state_t state, next_state;
    
    always_ff @(posedge clk) begin
        valid <= 0; 
        if (reset) begin
            valid <= 0; 
            msg_type <= 8'b00000000;
            state <= IDLE;
            counter <= 0; 
        end 
        else begin
            state <= next_state;
            if (state == IDLE) begin
                if (msg_valid) begin
                    internal_length <= {internal_length[7:0], data_in};
                end
            end else if(state == START) begin
                if (msg_valid) begin 
                    internal_length <= {internal_length[7:0], data_in};
                end
            end else begin
                if (counter == 0) begin 
                    msg_type <= data_in;
                end
                if (msg_valid) begin
                    if (counter == internal_length - 1) begin 
                        counter <= 0;
                        valid <= 1;
                    end else begin
                        counter <= counter + 1; 
                    end     
                end   
            end
        end 
    end
    always_comb begin
        next_state = state; 
        case(state)
            IDLE: begin
                if (msg_valid) begin
                    next_state = START;
                end
            end
            START: begin
                if (msg_valid) begin
                    next_state = RECEIVE;
                end
            end
            RECEIVE: begin
                if(counter == internal_length-1) begin 
                    if (msg_valid) begin 
                        next_state = RECEIVE;
                    end
                end    
            end
        default: 
            next_state = IDLE;
        endcase   
    end                
endmodule