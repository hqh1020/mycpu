`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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
`include "defines.h"

module hazard(
	//fetch stage
	output wire stallF,
	output wire flushF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire [1:0] forwardaD,forwardbD,
	output wire stallD,
	output wire flushD,
	//execute stage
	input wire[4:0] alucontrolE,
	input wire[4:0] rsE,rtE,rdE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire [1:0] hilo_weE,
	output wire [1:0] forwardaE,forwardbE,
	output wire [1:0] forwardhiloE,
	output wire forwardC0E,
	output wire flushE,
	output wire stallE,
	input wire div_start,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire [1:0] hilo_weM,
	input wire C0_weM,
	input wire [4:0] rdM,
	input wire [31:0] excepttypeM,
	output wire flushM,
	input wire [31:0] cp0_epcM,
	output reg [31:0] newpcM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	input wire [1:0] hilo_weW,
	output wire flushW
    );

	wire lwstallD,branchstallD,flush_except;
	assign forwardaD = (rsD != 0 & rsD == writeregE & regwriteE) ? 2'b01 :
						(rsD != 0 & rsD == writeregM & regwriteM) ? 2'b10 : 2'b00;
	assign forwardbD = (rtD != 0 & rtD == writeregE & regwriteE) ? 2'b01 :
						(rtD != 0 & rtD == writeregM & regwriteM) ? 2'b10 : 2'b00;
	
	assign forwardhiloE =  (!hilo_weE && hilo_weM) ? 2'b01 :
						  (!hilo_weE && hilo_weW) ? 2'b10 : 2'b00;
	assign forwardC0E = ((rdE != 0) & (rdE == rdM) & (C0_weM)) ? 1'b1 : 1'b0;
	assign forwardaE = ((rsE != 0) & (rsE == writeregM) & regwriteM) ? 2'b10 : 
						((rsE != 0) & (rsE == writeregW) & regwriteW) ? 2'b01 : 2'b00;
	assign forwardbE = ((rtE != 0) & (rtE == writeregM) & regwriteM) ? 2'b10 : 
						((rtE != 0) & (rtE == writeregW) & regwriteW) ? 2'b01 : 2'b00;

	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign branchstallD = (branchD & regwriteE  & (writeregE == rsD | writeregE == rtD))//还没计算出来，只能暂停 branchD.只有branch是D时候比较，其他可以放在E阶段
                 | (branchD & memtoregM & (writeregM == rsD | writeregM == rtD));//lw指令，只能暂停,not necessary
    
  	assign stallE = div_start;		       
	assign stallD = lwstallD | branchstallD | div_start;
	assign stallF = lwstallD | branchstallD | div_start;

	assign flush_except = (excepttypeM != 32'b0);
	assign flushF = flush_except;
	assign flushD = flush_except;
	assign flushE = lwstallD | branchstallD |flush_except; 
	assign flushM = flush_except;
	assign flushW = flush_except;

	//assign newpcM = flush_except ? (excepttypeM == 32'h0000000e ? cp0_epcM : 32'hBFC00380) : 32'h00000001;
		//CP0 ->bfc00380
  	always @(*) begin
		if(excepttypeM != 32'b0) begin
			/* code */
			case (excepttypeM)
				32'h00000001:begin 
					newpcM <= 32'hBFC00380;
				end
				32'h00000004:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h00000005:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h00000008:begin 
					newpcM <= 32'hBFC00380;
					// new_pc <= 32'h00000040;
				end
				32'h00000009:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000a:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000c:begin 
					newpcM <= 32'hBFC00380;

				end
				32'h0000000e:begin 
					newpcM <= cp0_epcM;
				end
				default : /* default */;
			endcase
		end
	
	end
endmodule