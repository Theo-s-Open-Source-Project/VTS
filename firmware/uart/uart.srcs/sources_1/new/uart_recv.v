`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: sihao.tsang@gmail.com 
// 
// Create Date: 2023/07/08 23:53:19
// Design Name: 
// Module Name: uart_recv
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


module uart_recv(
    // Input 
    input               sys_clk,    // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч
    input               uart_rxd,

    // Output       
    output              uart_txd,
    output reg          uart_done,  // ����һ��������ɘ�־
    output reg [7:0]    uart_data   // ���յĔ���
);

	// parameter define
	parameter  CLK_FREQ = 50000000;     // ϵ�y�r��l��
	parameter  UART_BPS = 115200;       // ���ڲ����ʣ������ʼ�ÿ���ݔ����λ����
	localparam BPS_CNT = CLK_FREQ / UART_BPS;   // ��ǰ�������£����ڂ�ݔһλ����Ҫ��ϵ�y�r����ڔ�
	// 1 frame data: start bit + bit0 + bit1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 + stop bit

	// reg define
	reg        uart_rxd_buffer_1;
	reg        uart_rxd_buffer_2;
	reg [15:0] clk_cnt;                // ϵ�y�r�Ӌ����
	reg [ 3:0] rx_cnt;                 // ϵ�y����Ӌ����
	reg        rx_flag;                // �����^�̘�־��̖
	reg [ 7:0] rx_data;                // ���Ք����Ĵ���

	// wire define
	wire       start_flag;

	//*****************************************************
	//** main code
	//*****************************************************

	// ���@���ն˿��½��أ���ʼλ�����õ�һ���r����ڵ��}�n��̖
	assign start_flag = uart_rxd_buffer_2 & (~uart_rxd_buffer_1);

	// �� UART ���ն˿ڵĔ������t�ɂ��r�����
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			uart_rxd_buffer_1 <= 1'b0;
			uart_rxd_buffer_2 <= 1'b0;
		end
		else begin
			uart_rxd_buffer_1 <= uart_rxd;
			uart_rxd_buffer_2 <= uart_rxd_buffer_1;
		end
	end

	// ���}�n��̖ start_flag ���_�r���M������^��
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_flag <= 1'b0;
		else begin
			// �z�y����ʼλ
			if (start_flag)         
				rx_flag <= 1'b1;    // �M������^�̣���־λ rx_flag ����
			// Ӌ����ֹͣλ�r����ϵ�y�r�Ӌ����Ӌ��������λ���g����ֹͣ�����^��
			else if((rx_cnt == 4'd9) && (clk_cnt == BPS_CNT/2)) 
				rx_flag <= 1'b0;    // �����^�̽Y������־λ rx_flag ����
			else
				rx_flag <= rx_flag;
		end
	end

	// �M������^�̺󣬆���ϵ�y�r�Ӌ����
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			clk_cnt <= 16'd0;
		else if (rx_flag) begin     // ���̎춽����^����
			if (clk_cnt < BPS_CNT - 1)  // ��ϵ�y�r�Ӌ���_��һ������������
				clk_cnt <= clk_cnt + 1'b1;
			else
				clk_cnt <= 16'd0;   // ϵ�y�r�Ӌ����Ӌ��һ�����������ں�����
		end
		else
			clk_cnt <= 16'd0;       // �����^�̽Y����Ӌ��������
	end

	// �M������^�̺󣬆��ӽ��Ք���Ӌ����
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_cnt <= 4'd0;
		else if (rx_flag) begin     // ���̎춽����^����
			if (clk_cnt < BPS_CNT - 1)  // ��ϵ�y�r�Ӌ���_��һ������������
				rx_cnt <= rx_cnt + 1'b1;    
			else
				rx_cnt <= rx_cnt;
		end
		else
			rx_cnt <= 4'd0;       // �����^�̽Y����Ӌ��������
	end

	// �������Ք���Ӌ������Ĵ� uart ���ն˿ڔ���
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_data <= 8'd0;
		else if (rx_flag)         // ϵ�y̎춽����^��
			// �Д�ϵ�y�r�Ӌ����Ӌ���Ƿ񵽔���λ���g��Ӌ��������λ���g�r������ģ�
			if (clk_cnt == BPS_CNT / 2) begin
				case (rx_cnt)
					4'd1: rx_data[0] <= uart_rxd_buffer_2;
					4'd2: rx_data[1] <= uart_rxd_buffer_2;
					4'd3: rx_data[2] <= uart_rxd_buffer_2;
					4'd4: rx_data[3] <= uart_rxd_buffer_2;
					4'd5: rx_data[4] <= uart_rxd_buffer_2;
					4'd6: rx_data[5] <= uart_rxd_buffer_2;
					4'd7: rx_data[6] <= uart_rxd_buffer_2;
					4'd8: rx_data[7] <= uart_rxd_buffer_2;
					default: ;
				endcase
			end
			else
				rx_data <= rx_data;
		else
			rx_data <= 8'd0;
	end

	// ���������ꮅ��o����־��̖�K�Ĵ�ݔ�����յ��Ĕ���
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			uart_data <= 8'd0;
			uart_done <= 1'b0;
		end
		// �Д���Ք���Ӌ����Ӌ����ֹͣλ�r
		else if (rx_cnt == 4'd9) begin
			uart_data <= rx_data;	// �Ĵ�ݔ�����յ��Ĕ���
			uart_done <= 1'b1;		// ��������ɘ�־λ����
		end
		else begin
			uart_data <= 8'd0;
			uart_done <= 1'b0;
		end
	end

endmodule
