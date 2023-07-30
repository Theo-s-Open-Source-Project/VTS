`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: sihao.tsang@gmail.com
// 
// Create Date: 2023/07/08 23:54:39
// Design Name: 
// Module Name: uart_loop
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

module uart_loop(
    // Input 
    input               sys_clk,    // 系統差分輸入時鐘
    input               sys_rst_n,  // 系統復位，低電平有效

    input               recv_done,  // 接受一幀數據完成標志
    input [7:0]         recv_data,  // 接收的數據

    input               tx_busy,    // 發送忙狀態標志

    // Output    
    output              send_en,    // 發送使能信號
    output              send_data   // 待發送數據
);

    // reg define
    reg recv_done_buffer1;
    reg recv_done_buffer2;
    reg tx_ready;

    // wire define
    wire recv_done_flag;

    //*****************************************************
    //**                    main code
    //*****************************************************

    // 捕獲 recv_done 上升沿，得到一個時鐘周期的脈衝信號

	// 對 UART 接收端口的數據延遲兩個時鐘周期

    // 判斷接收完成信號，並在串口發送模塊空閑時給出發送使能信號
    


endmodule
