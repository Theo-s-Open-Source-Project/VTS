`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: sihao.tsang@gmail.com
// 
// Create Date: 2023/07/26 23:37:46
// Design Name: 
// Module Name: led_top
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


module led_top(
    // Input 
    input               sys_clk,    // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч

    // Output
    output              led
);

    // reg define
    reg  [26:0 ]  cnt; // �r����ڣ�1/100MHz=1/(100*1000KHz)=1/100000000Hz=10ns��Ӌ�r��1S��1s/10ns=10000_0000 

    //*****************************************************
    //** main code
    //*****************************************************

    // Ӌ������ 0~10000_0000 ֮�g�M��Ӌ��
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt <= 27'd0;
        else if (cnt < 27'd10000_0000)
            cnt <= cnt + 1'b1;
        else
            cnt <= 27'd0;
    end

    // led
    assign led = (cnt < 27'd5000_0000) ? 1'b1 : 1'b0;

endmodule
