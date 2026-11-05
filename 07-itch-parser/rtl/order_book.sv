`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 05:29:15 PM
// Design Name: 
// Module Name: order_book
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


module order_book (
    input logic clk,
    input logic reset,
    input logic msg_done,
    input logic [7:0] msg_type,
    input logic [63:0] order_ref, 
    input logic [7:0] side, 
    input logic [31:0] shares, 
    input logic [31:0] price,
    output logic [31:0] best_bid,
    output logic [31:0] best_ask,
    output logic bid_valid,
    output logic ask_valid
);

    logic [63:0] oref [0:1023];
    logic [7:0] oside [0:1023];
    logic [31:0] oshares [0:1023];
    logic [31:0] oprice [0:1023];
    logic ovalid [0:1023];
    
    logic [63:0] rd_ref;          
    logic rd_valid;        
    logic pending_delete;  
    logic pending_cancel; 
    logic [63:0] del_ref; 
    logic [31:0] rd_shares;
    logic [31:0] cxl_shares;  
    logic [63:0] best_bid_ref; 
    logic [63:0] best_ask_ref; 

    
    logic bid_scan; 
    logic [12:0] scan_addr; 
    logic [31:0] scan_best; 
    logic [63:0] scan_best_ref;
    logic scan_found; 
    
    logic ask_scan; 
    logic [12:0] ascan_addr; 
    logic [31:0] ascan_best; 
    logic [63:0] ascan_best_ref;
    logic ascan_found; 
    
    logic sh_we;
    logic [9:0] sh_addr;
    logic [31:0] sh_data;

    always_comb begin
        if (pending_cancel) begin
            sh_we   = (del_ref == rd_ref) && rd_valid;
            sh_addr = del_ref[9:0];
            sh_data = rd_shares - cxl_shares;
        end else begin
            sh_we   = msg_done && (msg_type == 8'h41);
            sh_addr = order_ref[9:0];
            sh_data = shares;
        end
    end
    always_ff @(posedge clk) begin 
        pending_delete <= 1'b0; 
        pending_cancel <= 1'b0; 
        if (reset) begin
            bid_valid <= 0; 
            ask_valid <= 0; 
            bid_scan <= 0; 
            ask_scan <= 0; 
            
        end else begin 
            if (sh_we) oshares[sh_addr] <= sh_data;
            if (pending_delete) begin 
                if (del_ref == rd_ref && rd_valid) begin
                    ovalid[del_ref[9:0]] <= 1'b0;
                    if (del_ref == best_bid_ref) begin
                        bid_scan <= 1'b1;
                        scan_addr <= 13'd0; 
                        scan_found <= 1'b0; 
                        bid_valid <= 1'b0; 
                    end
                    if (del_ref == best_ask_ref) begin
                        ask_scan <= 1'b1;
                        ascan_addr <= 13'd0; 
                        ascan_found <= 1'b0; 
                        ask_valid <= 1'b0;    
                    end
                end
            end 
            if (pending_cancel) begin 
                if (del_ref == rd_ref && rd_valid) begin 
                    if (cxl_shares == rd_shares) begin
                        ovalid[del_ref[9:0]] <= 1'b0; 
                        if (del_ref == best_bid_ref) begin
                            bid_scan <= 1'b1;
                            scan_addr <= 13'd0; 
                            scan_found <= 1'b0; 
                            bid_valid <= 1'b0; 
                        end
                        if (del_ref == best_ask_ref) begin
                            ask_scan <= 1'b1;
                            ascan_addr <= 13'd0; 
                            ascan_found <= 1'b0; 
                            ask_valid <= 1'b0;    
                        end
                    end
                end
            end
            if (bid_scan) begin
                if (scan_addr == 13'd1024) begin
                    bid_scan <= 1'b0;
                    best_bid <= scan_best;
                    best_bid_ref <= scan_best_ref;
                    bid_valid <= scan_found;
                end else begin
                    if (ovalid[scan_addr[9:0]] && oside[scan_addr[9:0]] == 8'h42 &&
                        (!scan_found || oprice[scan_addr[9:0]] > scan_best)) begin
                        scan_best <= oprice[scan_addr[9:0]];
                        scan_best_ref <= oref[scan_addr[9:0]];
                        scan_found <= 1'b1;
                    end
                    scan_addr <= scan_addr + 1;
                end
            end
            if (ask_scan) begin
                if (ascan_addr == 13'd1024) begin
                    ask_scan <= 1'b0;
                    best_ask <= ascan_best;
                    best_ask_ref <= ascan_best_ref;
                    ask_valid <= ascan_found;
                end else begin
                    if (ovalid[ascan_addr[9:0]] && oside[ascan_addr[9:0]] == 8'h53 &&
                        (!ascan_found || oprice[ascan_addr[9:0]] < ascan_best)) begin
                        ascan_best <= oprice[ascan_addr[9:0]];
                        ascan_best_ref <= oref[ascan_addr[9:0]];
                        ascan_found <= 1'b1;
                    end
                    ascan_addr <= ascan_addr + 1;
                end
            end
            if (msg_done) begin 
                if (msg_type == 8'h41) begin 
                    oref[order_ref[9:0]] <= order_ref[63:0];
                    oside[order_ref[9:0]] <= side[7:0];
                    oprice[order_ref[9:0]] <= price[31:0];
                    ovalid[order_ref[9:0]] <= 1'b1; 
                    if (side == 8'h42) begin
                        if (!bid_valid || price > best_bid) begin
                            best_bid <= price;
                            best_bid_ref <= order_ref; 
                            bid_valid <= 1;  
                        end    
                    end 
                    if (side == 8'h53) begin
                        if (!ask_valid || price < best_ask) begin
                            best_ask <= price;
                            best_ask_ref <= order_ref; 
                            ask_valid <= 1;  
                        end  
                    end
                end
                else if (msg_type == 8'h44) begin
                    rd_ref <= oref[order_ref[9:0]];
                    rd_valid <= ovalid[order_ref[9:0]];
                    pending_delete <= 1'b1;
                    del_ref <= order_ref;
                end
                else if (msg_type == 8'h58 || msg_type == 8'h45) begin
                    rd_ref <= oref[order_ref[9:0]];
                    rd_valid <= ovalid[order_ref[9:0]];
                    pending_cancel <= 1'b1;
                    rd_shares <= oshares[order_ref[9:0]]; 
                    del_ref <= order_ref; 
                    cxl_shares <= shares; 
                end
            end 
        end               
    end
    
endmodule
