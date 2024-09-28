`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 18:16:10
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input key_clk,
    input keydata,
    output key_state,            //键盘的按下状态，按下置1，松开置0
    output switch,              //开关
    output up,
    output down,
    output wire H,
    output wire V,
    output wire [3:0] R,
    output wire [3:0] G,
    output wire [3:0] B,
    output [7:0] o_seg,
    output [7:0] o_sel
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
    parameter lineup=Column_base+80;
    parameter linemid=Column_base+200;
    parameter linelow=Column_base+320;
    
    wire vga_clk;
    wire move_clk;
    wire [9:0] h_count;
    wire [9:0] v_count;
    wire valid;
    
    reg [9:0] picX1=784;
    reg [9:0] picX2=784;
    reg [9:0] picX3=784;
    reg lineenable[2:0]={1,1,1};    //是否进行绘画
    reg linetype[2:0]={0,1,0};      //各个轨道的障碍物种类
    reg [30:0] count1=54000;
    reg [30:0] count2=0;
    reg [30:0] count3=12000;

    reg [9:0] dinoX=Line_base;
    reg [9:0] dinoY=linemid;
    reg [1:0] dino_line=2;
    reg [30:0] count_dino=0;

    reg collision=0;
    reg [31:0] score=0;
    reg addscore=0;
    
    vga_divider vga_divider_inst(clk,vga_clk);
    vga_count vga_count_inst(vga_clk,H,V,h_count,v_count,valid);
    
    
    keyboard keyboard(clk,1,key_clk,keydata,key_state,switch,up,down);
    
    always @ (posedge vga_clk)
    begin
    if(switch) 
        begin 
        count1=count1+1;
        count2=count2+1;
        count3=count3+1;
        count_dino=count_dino+1;
        if(count1==780000)  
            begin  
            picX1=picX1-2-linetype[2];
            if(picX1==Line_base)            begin picX1=0;lineenable[0]=0;addscore=1;end
            if(count2>=45200 && picX1==0 )      begin picX1=784;lineenable[0]=1;linetype[0]= (linetype[1] ^ linetype[2]) ;end
            count1=0;
            end
        if(count2==840000)  
            begin  
            picX2=picX2-1-linetype[0]-linetype[2];
            if(picX2==Line_base)            begin picX2=0;lineenable[1]=0;addscore=1;end
            if(count3>=33000 && picX2==0 )      begin picX2=784;lineenable[1]=1;linetype[1]= ~(linetype[2] ^ linetype[0]) ;end
            count2=0;
            end
        if(count3==910000)  
            begin  
            picX3=picX3-2-linetype[2];
            if(picX3==Line_base)            begin picX3=0;lineenable[2]=0;addscore=1;end
            if(count1>=57600 && picX3==0 )      begin picX3=784;lineenable[2]=1;linetype[2]= ~(linetype[0] ^ linetype[1]) ;end
            count3=0;
            end
        if(count_dino==250000)
            begin    
            if(up==1)
                begin 
                    if(dino_line==2) 
                        begin 
                            if(dinoY>lineup) begin dinoY=dinoY-1;end
                            if(dinoY==lineup)begin dino_line=1;end
                        end
                    else if(dino_line==3) 
                        begin 
                            if(dinoY>linemid)begin dinoY=dinoY-1;end
                            if(dinoY==linemid)begin dino_line=2;end
                        end
                end   
            else if(down==1)       
                begin 
                    if(dino_line==1) 
                        begin
                            if(dinoY<linemid)begin dinoY=dinoY+1;end
                            if(dinoY==linemid)begin dino_line=2;end
                        end
                    else if(dino_line==2)
                        begin
                            if(dinoY<linelow)begin dinoY=dinoY+1;end
                            if(dinoY==linelow)begin dino_line=3;end
                        end
                end
            count_dino=0;
            end
        if((dinoX+50>=picX1 && picX1!=0 && dinoY>=lineup-100 && dinoY <=lineup+100)||
           (dinoX+50>=picX2 && picX2!=0 && dinoY>=linemid-100 && dinoY <=linemid+100)||
           (dinoX+50>=picX3 && picX3!=0 && dinoY>=linelow-100 && dinoY <=linelow))
            begin collision=1;end
        if(collision==0 && addscore==1) begin score=score+1;addscore=0;end
        end
    end
    vga_pic lines(valid,switch,collision,h_count,v_count,R,G,B,picX1,lineup,picX2,linemid,picX3,linelow,
                  linetype[0],linetype[1],linetype[2],lineenable[0],lineenable[1],lineenable[2],
                  dinoX,dinoY);
    Seg7display scoredisplay(clk,0,1,score,o_seg,o_sel);
endmodule

