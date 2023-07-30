`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: sihao.tsang@gmail.com 
// 
// Create Date: 2023/07/08 23:53:49
// Design Name: 
// Module Name: uart_send
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

module uart_send(
    // Input 
	input				sys_clk,		// 系統時鐘
	input				sys_rst_n,		// 系統復位，低電平有效
	input				uart_en,		// 發送使能信號
	input  [7:0]		uart_din,		// 待發送數據

    // Output    
	output              uart_tx_busy,	// 發送忙狀態標志
	output reg			uart_txd		// UART 發送端口
);

	// parameter define
	parameter  CLK_FREQ = 50000000;     // 系統時鐘頻率
	parameter  UART_BPS = 115200;       // 串口波特率，波特率即每秒傳輸多少位數據
	localparam BPS_CNT = CLK_FREQ / UART_BPS;   // 當前波特率下，串口傳輸一位所需要的系統時鐘周期數
	// 1 frame data: start bit + bit0 + bit1 + bit2 + bit3 + bit4 + bit5 + bit6 + bit7 + stop bit

	// reg define
	reg        uart_en_d0;	
	reg        uart_en_d1;	
	reg [15:0] clk_cnt;		// 系统时钟计数器
	reg [ 3:0] tx_cnt;		// 發送數據计数器
	reg        tx_flag;		// 發送過程標志信號
	reg [ 7:0] tx_data;		// 寄存發送數據

	//wire define
	wire en_flag;

	//*****************************************************
	//** main code
	//*****************************************************

	// Indicates the busy flag of status when the serial port is being sent
	assign uart_tx_busy = tx_flag;

	// 捕獲 uart_en 上升沿，得到一個時鐘周期的脈衝信號
	assign en_flag = (~uart_en_d1) & uart_en_d0;

	// 對發送使能信號 uart_en 延遲兩個時鐘周期
	always @(posedge sys_clk or negedge sys_rst_n) begin         
		if (!sys_rst_n) begin
			uart_en_d0 <= 1'b0;                                  
			uart_en_d1 <= 1'b0;
		end                                                      
		else begin                                               
			uart_en_d0 <= uart_en;                               
			uart_en_d1 <= uart_en_d0;                            
		end
	end

	// When en_flag arrives, store data to be sent, and entered the sending process
	always @(posedge sys_clk or negedge sys_rst_n) begin         
		if (!sys_rst_n) begin                                  
			tx_flag <= 1'b0;
			tx_data <= 8'd0;
		end 
		// 檢測到發送使能上升沿 
		else if (en_flag) begin		                     
				tx_flag <= 1'b1;		// 進入發送過程，標志位 tx_flag 拉高
				tx_data <= uart_din;	// 寄存待發送的數據
		end
		else if ((tx_cnt == 4'd9) && (clk_cnt == BPS_CNT - (BPS_CNT / 16))) begin                                       
			tx_flag <= 1'b0;			//發送過程結束，標志位 tx_flag 拉低
			tx_data <= 8'd0;
		end
		else begin
			tx_flag <= tx_flag;
			tx_data <= tx_data;
		end 
	end

	// 進入發送過程后，啓動系統時鐘計數器
	always @(posedge sys_clk or negedge sys_rst_n) begin         
		if (!sys_rst_n)                             
			clk_cnt <= 16'd0;                                  
		else if (tx_flag) begin				// 處於發送過程
			if (clk_cnt < BPS_CNT - 1)
				clk_cnt <= clk_cnt + 1'b1;	
			else
				clk_cnt <= 16'd0;			// 對系統時鐘計數達到一個波特率周期后清零
		end
		else                             
			clk_cnt <= 16'd0; 				// 發送過程結束
	end

	// 進入發送過程后，啓動發送數據計數器
	always @(posedge sys_clk or negedge sys_rst_n) begin         
		if (!sys_rst_n)                             
			tx_cnt <= 4'd0;
		else if (tx_flag) begin         	// 處於發送過程
			if (clk_cnt == BPS_CNT - 1)		// 對系統時鐘計數達到一個波特率周期
				tx_cnt <= tx_cnt + 1'b1;	// 此時發送數據計數器加 1
			else
				tx_cnt <= tx_cnt;       
		end
		else                              
			tx_cnt  <= 4'd0;				// 發送過程結束
	end

	// 根據發送數據計數器來給 uart 發送端口賦值
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)  
        	uart_txd <= 1'b1;  
		else if (tx_flag) begin
			case(tx_cnt)
				4'd0: uart_txd <= 1'b0;         // 起始位
				4'd1: uart_txd <= tx_data[0];   // 數據位最低位
				4'd2: uart_txd <= tx_data[1];
				4'd3: uart_txd <= tx_data[2];
				4'd4: uart_txd <= tx_data[3];
				4'd5: uart_txd <= tx_data[4];
				4'd6: uart_txd <= tx_data[5];
				4'd7: uart_txd <= tx_data[6];
				4'd8: uart_txd <= tx_data[7];   // 數據位最高位
				4'd9: uart_txd <= 1'b1;         // 停止位
				default: ;
			endcase
		end
		else 
			uart_txd <= 1'b1;                   // 空閑時發送端口為高電平
	end

endmodule
