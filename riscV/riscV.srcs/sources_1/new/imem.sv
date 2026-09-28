`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 12:28:28 AM
// Design Name: 
// Module Name: imem
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


module imem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
    );
    
    
    logic [31:0] mem [0:255];
    
    initial $readmemh("C:/Users/dhruv/OneDrive/Documents/program.hex", mem); //read from program.hex  

    assign instruction = mem[addr[31:2]];
     
       
endmodule
