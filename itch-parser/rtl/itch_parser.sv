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
    output logic [7:0] msg_type,
    output logic [63:0] order_ref, 
    output logic [7:0] side, 
    output logic [31:0] shares, 
    output logic [63:0] stock, 
    output logic [31:0] price,
    output logic [63:0] match
);
    
    logic [15:0] internal_length = 16'b0; 
    logic [15:0] counter = 16'b0;  
    localparam [7:0] A = 8'h41;
    localparam [7:0] E = 8'h45;
    localparam [7:0] X = 8'h58;
    localparam [7:0] D = 8'h44;
    localparam [7:0] P = 8'h50; 
    
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
                    if (counter inside {[11:18]}) begin
                        order_ref <= {order_ref[55:0], data_in};
                    end 
                    case (msg_type) 
                        A: begin
                            if (counter == 19) begin
                                side <= data_in;
                            end else if (counter inside {[20:23]}) begin
                                shares <= {shares[23:0], data_in};
                            end else if (counter inside {[24:31]}) begin
                                stock <= {stock[55:0], data_in};
                            end else if (counter inside {[32:35]}) begin 
                                price <= {price[23:0], data_in};
                            end 
                        end
                        E: begin
                            if (counter inside {[19:22]}) begin
                                shares <= {shares[23:0], data_in};
                            end else if (counter inside {[23:30]}) begin
                                match <= {match[55:0], data_in};
                            end 
                        end
                        X: begin
                            if (counter inside {[19:22]}) shares <= {shares[23:0], data_in};
                        end
                        P: begin
                            if (counter == 19) begin
                                side <= data_in;
                            end else if (counter inside {[20:23]}) begin
                                shares <= {shares[23:0], data_in};
                            end else if (counter inside {[24:31]}) begin
                                stock <= {stock[55:0], data_in};
                            end else if (counter inside {[32:35]}) begin 
                                price <= {price[23:0], data_in};
                            end else if (counter inside{[36:43]}) begin
                                match <= {match[55:0], data_in};
                            end
                        end
                        default: ; 
                    endcase
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
                        next_state = IDLE;
                    end
                end    
            end
        default: 
            next_state = IDLE;
        endcase   
    end                
endmodule