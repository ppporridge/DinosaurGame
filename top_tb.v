`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 20:43:55
// Design Name: 
// Module Name: top_tb
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


module top_tb();
   reg clk;
   reg switch;
   reg up;
   reg down;
   wire H;
   wire V;
   wire [3:0] R;
   wire [3:0] G;
   wire [3:0] B;
   
   initial
   begin
    clk=0;
    switch=1;
    up=0;
    down=0;
   end
   always
    #5 clk=~clk;
    
   top top_inst(clk,switch,up,down,H,V,R,G,B);

endmodule
