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
    input               sys_clk,    // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч

    input               recv_done,  // ����һ��������ɘ�־
    input [7:0]         recv_data,  // ���յĔ���

    input               tx_busy,    // �l��æ��B��־

    // Output    
    output              send_en,    // �l��ʹ����̖
    output              send_data   // ���l�͔���
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

    // ���@ recv_done �����أ��õ�һ���r����ڵ��}�n��̖

	// �� UART ���ն˿ڵĔ������t�ɂ��r�����

    // �Д���������̖���K�ڴ��ڰl��ģ�K���e�r�o���l��ʹ����̖
    


endmodule
