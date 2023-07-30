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
    input               sys_clk,    // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч
    input               uart_rxd,   // UART ���ն˿�

    // Output
    output			    uart_txd,   // UART ���Ͷ˿�
    output			    recv_event
);

    //parameter define
    parameter  CLK_FREQ = 50000000; // ϵ�y�r��l��
    parameter  UART_BPS = 115200;   // ���ڲ����ʣ������ʼ�ÿ���ݔ����λ����
    localparam BPS_CNT = CLK_FREQ / UART_BPS; // ��ǰ�������£����ڂ�ݔһλ����Ҫ��ϵ�y�r����ڔ�
    // 1 frame data: start bit + bit0 + bit1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 + stop bit

    //wire define
    wire         uart_recv_done;    // UART �������
    wire [ 7:0 ] uart_recv_data;    // UART ���Ք���
    wire         uart_send_en;      // UART �l��ʹ��
    wire [ 7:0 ] uart_send_data;    // UART �l�͔���
    wire         uart_tx_busy;      // UART �l��æ��B��־

    //reg define
    reg          recv_event;

    //*****************************************************
    //**                    main code
    //*****************************************************

    // uart receive module
    uart_recv #(
    .CLK_FREQ           (CLK_FREQ), //����ϵͳʱ��Ƶ��
    .UART_BPS           (UART_BPS)  //���ô��ڽ��ղ�����
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
    .CLK_FREQ           (CLK_FREQ), //����ϵͳʱ��Ƶ��
    .UART_BPS           (UART_BPS)  //���ô��ڽ��ղ�����
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
