`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/26 23:26:02
// Design Name: 
// Module Name: uart_top
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

module uart_top(
    // Input 
    input               sys_clk,    // 系統差分輸入時鐘
    input               sys_rst_n,  // 系統復位，低電平有效
    input               uart_rxd,   // UART 接收端口

    // Output
    output			    uart_txd,   // UART 发送端口
    output			    recv_event
);

    //parameter define
    parameter  CLK_FREQ = 50000000; // 系統時鐘頻率
    parameter  UART_BPS = 115200;   // 串口波特率，波特率即每秒傳輸多少位數據
    localparam BPS_CNT = CLK_FREQ / UART_BPS; // 當前波特率下，串口傳輸一位所需要的系統時鐘周期數
    // 1 frame data: start bit + bit0 + bit1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 + stop bit

    //wire define
    wire         uart_recv_done;    // UART 接受完成
    wire [ 7:0 ] uart_recv_data;    // UART 接收數據
    wire         uart_send_en;      // UART 發送使能
    wire [ 7:0 ] uart_send_data;    // UART 發送數據
    wire         uart_tx_busy;      // UART 發送忙狀態標志

    //reg define
    reg          recv_event;

    //*****************************************************
    //**                    main code
    //*****************************************************

    // uart receive module
    uart_recv #(
    .CLK_FREQ           (CLK_FREQ), //设置系统时钟频率
    .UART_BPS           (UART_BPS)  //设置串口接收波特率
    ) u_uart_receive(
        .sys_clk        (sys_clk),
        .sys_rst_n      (sys_rst_n),
        .uart_rxd       (uart_rxd),

        .uart_txd       (uart_txd),
        .uart_done      (uart_recv_done),
        .uart_data      (uart_recv_data)
	);

    // uart send module
    uart_send #(
    .CLK_FREQ           (CLK_FREQ), //设置系统时钟频率
    .UART_BPS           (UART_BPS)  //设置串口接收波特率
    ) u_uart_send(
        .sys_clk        (sys_clk),
        .sys_rst_n      (sys_rst_n),
        .uart_en        (uart_send_en),
        .uart_din       (uart_send_data),

        .uart_tx_busy   (uart_tx_busy),
        .uart_txd       (uart_txd)
    );

    // uart loop module

    // uart receive data comparison event
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            recv_event <= 1'b0;
        else if ((uart_recv_data == 8'h05) || (uart_recv_data == 8'h54)) //hex: 05 or ASCII: T
            recv_event <= 1'b1;
        else if ((uart_recv_data == 8'h04) || (uart_recv_data == 8'h46)) //hex: 04 or ASCII: F
            recv_event <= 1'b0;
        else
            recv_event <= recv_event;
    end

endmodule
