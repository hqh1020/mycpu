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

module mips(
	input wire clk,rst,
	output wire [31:0] pcF,
	input wire [31:0] instrF,
	output wire memwriteM,
	output wire [31:0] aluoutM,writedata2M,
	input wire [31:0] readdataM,
	output wire[3:0] sel
    );
	wire [31:0] instrD;
	wire regdstE,alusrcE,pcsrcD,jumpD,jalD,jrD,balD,jalrD,branchD,memtoregE,memtoregM,memtoregW,regwriteE,regwriteM,regwriteW;
	wire [1:0] hilo_weD;
	wire [4:0] alucontrolD;
	wire flushE,stallE,equalD;
	wire overflow,zero;
	wire adelM;
	wire invalidD;
	wire [31:0] excepttypeM;
	wire [31:0] pcW;
	wire [31:0] resultW;
	wire [4:0] writeregW;

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
		regwriteM,adelM,
		//write back stage
		memtoregW,regwriteW
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
		excepttypeM,
		//writeback stage
		memtoregW,
		regwriteW,
		pcW,
		resultW,
		writeregW
	    );
	
endmodule
