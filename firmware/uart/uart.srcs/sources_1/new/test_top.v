`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: sihao.tsang@gmail.com
// 
// Create Date: 2023/07/26 23:21:01
// Design Name: 
// Module Name: test_top
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


module test_top (
    // Input 
    input               sys_clk_p,  // ϵ�y���ݔ��r�
    input               sys_clk_n,  // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч

    input  [1:0]        key,        // ���I
    input               uart_rxd,

    // Output 
    output              FAN,        // �L��
    output              uart_txd,
    output              led
);

    // wire define
    wire                recv_event;

    //*****************************************************
    //** main code
    //*****************************************************

    // �D�Q�����̖
    IBUFDS diff_clock (
        .O (sys_clk),   // 1-bit output: Buffer output
        .I (sys_clk_p), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(sys_clk_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    // led
    led_top u_led_top(
        .sys_clk                (sys_clk),
        .sys_rst_n              (sys_rst_n),

        .led                    (led)
    );

    // key
    key_top u_key_top(
        .sys_clk                (sys_clk),
        .sys_rst_n              (sys_rst_n),

        .key                    (key),

        .FAN                    (FAN)
    );

    // uart
    uart_top u_uart_top(
        .sys_clk                (sys_clk),
        .sys_rst_n              (sys_rst_n),

        .uart_rxd               (uart_rxd),
        .uart_txd               (uart_txd),

        .recv_event             (recv_event)
    );


endmodule
