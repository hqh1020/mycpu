`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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

module mycpu_top(
	input wire clk,
	input wire resetn,
	input wire [5:0] int,       ///????

	output wire inst_sram_en,
	output wire [3:0] inst_sram_wen,
	output wire [31:0] inst_sram_addr,
	output wire [31:0] inst_sram_wdata,
	input wire [31:0] inst_sram_rdata,

	output wire data_sram_en,     
	output wire [3:0] data_sram_wen,    
	output wire [31:0] data_sram_addr,   
	output wire [31:0] data_sram_wdata,  
	input wire [31:0] data_sram_rdata, 

	output wire [31:0] debug_wb_pc,      
	output wire [3 :0] debug_wb_rf_wen,  
	output wire [4 :0] debug_wb_rf_wnum, 
	output wire [31:0] debug_wb_rf_wdata
    );
	
	wire rst;
	wire [31:0] pcF;
	wire [31:0] instrF;
	wire memwriteM;
	wire [31:0] aluoutM,writedata2M;
	wire [31:0] readdataM;
	wire [3:0] sel;
	wire [31:0] pcW,resultW;
	wire [4:0] writeregW;

	wire [31:0] instrD;
	wire regdstE,alusrcE,pcsrcD,jumpD,jalD,jrD,balD,jalrD,branchD,memtoregE,memtoregM,memtoregW,regwriteE,regwriteM,regwriteW;
	wire [1:0] hilo_weD;
	wire [4:0] alucontrolD;
	wire flushE,stallE,equalD;
	wire overflow,zero;
	wire adelM,flushM;
	wire invalidD;
	wire [31:0] excepttypeM;
	wire flushW;


	assign rst = resetn;         
	           
	assign inst_sram_en = 1'b1;    
	assign inst_sram_wen = 4'b0;   
	assign inst_sram_addr = pcF;  
	assign inst_sram_wdata = 32'b0;
	assign instrF = inst_sram_rdata; 

	assign data_sram_en = memwriteM;    
	assign data_sram_wen = sel;   
	assign data_sram_addr = aluoutM;  
	assign data_sram_wdata = writedata2M;
	assign readdataM = data_sram_rdata; 

	assign debug_wb_pc = pcW;     
	assign debug_wb_rf_wen = 4'b0;//{4{regwriteW}}; 
	assign debug_wb_rf_wnum = writeregW;
	assign debug_wb_rf_wdata = resultW;

	controller c(
		clk,rst,
		//decode stage
		instrD,equalD,
		pcsrcD,branchD,jumpD,
		jalD,jrD,balD,jalrD,
		alucontrolD,
		hilo_weD,
		invalidD,
		//execute stage
		flushE,stallE,overflow,
		memtoregE,alusrcE,
		regdstE,regwriteE,	

		//mem stage
		memtoregM,memwriteM,
		regwriteM,adelM,flushM,
		//write back stage
		memtoregW,regwriteW,
		flushW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jalD,jrD,balD,jalrD,
		equalD,
		instrD,
		alucontrolD,
		hilo_weD,
		invalidD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		flushE,stallE,
		overflow,zero,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedata2M,
		readdataM,
		sel,
		adelM,
		flushM,
		excepttypeM,
		//writeback stage
		memtoregW,
		regwriteW,
		pcW,
		resultW,
		writeregW,
		flushW
	    );
	
endmodule
