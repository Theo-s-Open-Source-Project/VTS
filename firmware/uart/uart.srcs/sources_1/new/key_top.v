`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 17:30:46
// Design Name: 
// Module Name: key_top
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


module key_top(
    // Input 
    input               sys_clk,    // ϵ�y���ݔ��r�
    input               sys_rst_n,  // ϵ�y��λ�����ƽ��Ч

    input  [1:0]        key,        // ���I
    input               recv_event, 

    // Output 
    output reg          FAN         // �L��
    );


    //*****************************************************
    //** main code
    //*****************************************************

    // FAN
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) 
            FAN <= 1'b1;
        else begin
            case ({recv_event, key})
                3'b100:   FAN <= 1'b1;
                3'b110:   FAN <= 1'b1;
                3'b101:   FAN <= 1'b1;
                3'b111:   FAN <= FAN;
                3'b000:   FAN <= 1'b0;
                3'b010:   FAN <= 1'b0;
                3'b001:   FAN <= 1'b1;
                3'b011:   FAN <= FAN;
                default: ;
            endcase
        end
    end

endmodule
