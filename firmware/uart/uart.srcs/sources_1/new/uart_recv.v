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
    input               sys_clk,    // 系統差分輸入時鐘
    input               sys_rst_n,  // 系統復位，低電平有效
    input               uart_rxd,

    // Output       
    output              uart_txd,
    output reg          uart_done,  // 接收一幀數據完成標志
    output reg [7:0]    uart_data   // 接收的數據
);

	// parameter define
	parameter  CLK_FREQ = 50000000;     // 系統時鐘頻率
	parameter  UART_BPS = 115200;       // 串口波特率，波特率即每秒傳輸多少位數據
	localparam BPS_CNT = CLK_FREQ / UART_BPS;   // 當前波特率下，串口傳輸一位所需要的系統時鐘周期數
	// 1 frame data: start bit + bit0 + bit1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 + stop bit

	// reg define
	reg        uart_rxd_buffer_1;
	reg        uart_rxd_buffer_2;
	reg [15:0] clk_cnt;                // 系統時鐘計數器
	reg [ 3:0] rx_cnt;                 // 系統數據計數器
	reg        rx_flag;                // 接收過程標志信號
	reg [ 7:0] rx_data;                // 接收數據寄存器

	// wire define
	wire       start_flag;

	//*****************************************************
	//** main code
	//*****************************************************

	// 捕獲接收端口下降沿（起始位），得到一個時鐘周期的脈衝信號
	assign start_flag = uart_rxd_buffer_2 & (~uart_rxd_buffer_1);

	// 對 UART 接收端口的數據延遲兩個時鐘周期
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

	// 當脈衝信號 start_flag 到達時，進入接收過程
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_flag <= 1'b0;
		else begin
			// 檢測到起始位
			if (start_flag)         
				rx_flag <= 1'b1;    // 進入接收過程，標志位 rx_flag 拉高
			// 計數到停止位時（且系統時鐘計數器計數到數據位中間），停止接收過程
			else if((rx_cnt == 4'd9) && (clk_cnt == BPS_CNT/2)) 
				rx_flag <= 1'b0;    // 接收過程結束，標志位 rx_flag 拉低
			else
				rx_flag <= rx_flag;
		end
	end

	// 進入接收過程后，啓動系統時鐘計數器
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			clk_cnt <= 16'd0;
		else if (rx_flag) begin     // 如果處於接收過程中
			if (clk_cnt < BPS_CNT - 1)  // 當系統時鐘計數達到一個波特率周期
				clk_cnt <= clk_cnt + 1'b1;
			else
				clk_cnt <= 16'd0;   // 系統時鐘計數器計數一個波特率周期后清零
		end
		else
			clk_cnt <= 16'd0;       // 接收過程結束，計數器清零
	end

	// 進入接收過程后，啓動接收數據計數器
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_cnt <= 4'd0;
		else if (rx_flag) begin     // 如果處於接收過程中
			if (clk_cnt < BPS_CNT - 1)  // 當系統時鐘計數達到一個波特率周期
				rx_cnt <= rx_cnt + 1'b1;    
			else
				rx_cnt <= rx_cnt;
		end
		else
			rx_cnt <= 4'd0;       // 接收過程結束，計數器清零
	end

	// 根據接收數據計數器來寄存 uart 接收端口數據
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			rx_data <= 8'd0;
		else if (rx_flag)         // 系統處於接收過程
			// 判斷系統時鐘計數器計數是否到數據位中間（計數到數據位中間時是最穩定的）
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

	// 數據接收完畢后給出標志信號並寄存輸出接收到的數據
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			uart_data <= 8'd0;
			uart_done <= 1'b0;
		end
		// 判斷接收數據計數器計數到停止位時
		else if (rx_cnt == 4'd9) begin
			uart_data <= rx_data;	// 寄存輸出接收到的數據
			uart_done <= 1'b1;		// 將接收完成標志位拉高
		end
		else begin
			uart_data <= 8'd0;
			uart_done <= 1'b0;
		end
	end

endmodule
