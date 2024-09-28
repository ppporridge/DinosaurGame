`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 18:07:25
// Design Name: 
// Module Name: VGA_control
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


module vga_divider(
    input clk,
    output reg vga_clk
    );
    reg mid;
    initial
    begin
        mid=0;
        vga_clk=0;
    end
    always @ (posedge clk)
    mid=~mid;
    always @ (posedge mid)
    vga_clk=~vga_clk;
endmodule


            
module vga_pic(
    input valid,
    input switch,
    input collision,
    input [9:0] h_count,
    input [9:0] v_count,
    output reg [3:0] R,
    output reg [3:0] G,
    output reg [3:0] B,
    input [9:0] picX1,
    input [9:0] picY1,
    input [9:0] picX2,
    input [9:0] picY2,
    input [9:0] picX3,
    input [9:0] picY3,
    input mode1,
    input mode2,
    input mode3,
    input enable1,
    input enable2,
    input enable3,
    input [9:0] dinoX,
    input [9:0] dinoY
);
    parameter H_SYNC_PULSE=96, 
            H_BACK_PORCH=48,
            H_ACTIVE_TIME=640,
            H_FRONT_PORCH=16,
            H_LINE_PERIOD=800;
    parameter V_SYNC_PULSE=2, 
            V_BACK_PORCH=33,
            V_ACTIVE_TIME=480,
            V_FRONT_PORCH=10,
            V_FRAME_PERIOD=525; 
            
    parameter Line_base=H_SYNC_PULSE+H_BACK_PORCH;
    parameter Column_base=V_SYNC_PULSE+V_BACK_PORCH;
    parameter obstacleXstart=Line_base+490;
    parameter lineup=Column_base+80;
    parameter linemid=Column_base+200;
    parameter linelow=Column_base+320;
    

    wire [11:0] RGB_info0[1:0];
    wire [11:0] RGB_info1[1:0];
    wire [11:0] RGB_info2[1:0];
    wire [13:0] address_in1;
    wire [13:0] address_in2;
    wire [13:0] address_in3;

    assign address_in1=(v_count-picY1)*100+(h_count-picX1)+2;
    assign address_in2=(v_count-picY2)*100+(h_count-picX2)+2;
    assign address_in3=(v_count-picY3)*100+(h_count-picX3)+2;
    tree tree1 (address_in1,RGB_info0[0]);
    torch torch1 (address_in1,RGB_info0[1]);//0代表tree,1代表torch
    tree tree2 (address_in2,RGB_info1[0]);
    torch torch2 (address_in2,RGB_info1[1]);//0代表tree,1代表torch
    tree tree3 (address_in3,RGB_info2[0]);
    torch torch3 (address_in3,RGB_info2[1]);//0代表tree,1代表torch
    

    wire [13:0] address_dino;
    wire [11:0] RGB_dino;
    assign address_dino=(v_count-dinoY)*100+(h_count-dinoX)+2;
    pic dino(address_dino,RGB_dino);
    
    wire [13:0] address_end;
    wire [11:0] RGB_end;
    assign address_end=(v_count-Column_base-190)*100+(h_count-Line_base-270)+2;
    pic endpic(address_end,RGB_end);
    
    always @ (*)
    begin
        if(valid && ~collision)
        begin
            if(v_count>=dinoY && v_count< dinoY+100 && h_count>=dinoX && h_count<dinoX+100)//小恐龙
                begin 
                R=RGB_dino[11:8];G=RGB_dino[7:4];B=RGB_dino[3:0];
                end
            else if(v_count>=picY1 && v_count< picY1+100 && h_count>=picX1 && h_count<picX1+100 && enable1)//第一个轨道
                begin 
                R=RGB_info0[mode1][11:8];G=RGB_info0[mode1][7:4];B=RGB_info0[mode1][3:0];
                end
           else if(v_count>=picY2 && v_count< picY2+100 && h_count>=picX2 && h_count<picX2+100 && enable2)//第二个轨道
                 begin 
                 R=RGB_info1[mode2][11:8];G=RGB_info1[mode2][7:4];B=RGB_info1[mode2][3:0];
                 end   
          else if(v_count>=picY3 && v_count< picY3+100 && h_count>=picX3 && h_count<picX3+100 && enable3)//第三个轨道
                 begin 
                 R=RGB_info2[mode3][11:8];G=RGB_info2[mode3][7:4];B=RGB_info2[mode3][3:0];
                 end             
           else if((v_count==Column_base+70 || v_count==Column_base+71 || v_count==Column_base+190 || v_count==Column_base+191 
                    || v_count==Column_base+310 || v_count==Column_base+311|| v_count==Column_base+430 || v_count==Column_base+431)
                    &&(h_count>=Line_base && h_count<Line_base+640))//画横线
                begin R=4'b0000;G=4'b0000;B=4'b0000; end
            //else if((v_count>=Column_base+70 && v_count<=Column_base+431)&&(h_count==Line_base+40 || h_count==Line_base+600))//画竖线
                //begin R=4'b0000;G=4'b0000;B=4'b0000; end
            else
                begin R=4'b1111;G=4'b1111;B=4'b1111; end       
        end
        else if(valid && collision)
            begin
            if(v_count>=Column_base+190 && v_count< Column_base+290 && h_count>=Line_base+270 && h_count<Line_base+370)
                begin R=RGB_end[11:8];G=RGB_end[7:4];B=RGB_end[3:0]; end            //gameend
                //begin R=4'b0000;G=4'b1111;B=4'b0000; end       
            else
                begin R=4'b1111;G=4'b1111;B=4'b1111; end 
            end
        else 
            begin R=4'b0000;G=4'b0000;B=4'b0000; end
   end 
endmodule



module vga_count(
    input vga_clk,
    output reg H,
    output reg V,
    output reg [9:0] h_count,
    output reg [9:0] v_count,
    output wire valid
    );
    parameter H_SYNC_PULSE=96, 
                H_BACK_PORCH=48,
                H_ACTIVE_TIME=640,
                H_FRONT_PORCH=16,
                H_LINE_PERIOD=800;
    parameter V_SYNC_PULSE=2, 
                V_BACK_PORCH=33,
                V_ACTIVE_TIME=480,
                V_FRONT_PORCH=10,
                V_FRAME_PERIOD=525; 
    initial
    begin h_count=0;v_count=0; end   
    always @(posedge vga_clk)
    begin
        if(h_count<H_SYNC_PULSE)    H=0;
        else                        H=1;                 
        if(h_count == H_LINE_PERIOD - 1)    h_count=0;
        else                                h_count=h_count+1;
    end 
    always @(posedge vga_clk)
    begin
        if(v_count<V_SYNC_PULSE)    V=0;
        else                        V=1;
        if(v_count==V_FRAME_PERIOD-1)           v_count=0;
        else if(h_count==H_LINE_PERIOD - 1)     v_count=v_count+1;
        else                                    v_count=v_count;
    end
    assign  valid=(h_count>=(H_SYNC_PULSE+H_BACK_PORCH))&&(h_count<=(H_SYNC_PULSE+H_BACK_PORCH+H_ACTIVE_TIME))&&(v_count>=(V_SYNC_PULSE+V_BACK_PORCH))&&(v_count<=(V_SYNC_PULSE+V_BACK_PORCH+V_ACTIVE_TIME));

endmodule



