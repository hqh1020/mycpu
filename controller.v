`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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

module controller(
	input wire clk,rst,
	//decode stage
	input wire[31:0] instrD,
	input equalD,
	output wire pcsrcD,branchD,jumpD,
	output wire jalD,jrD,balD,jalrD,
	output wire [4:0] alucontrolD,
	output wire [1:0] hilo_weD,
	output wire invalidD,
	//execute stage
	input wire flushE,stallE,
	input wire overflowE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	input wire adelM,flushM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire flushW
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;

	//execute stage
	wire memwriteE;

	maindec md(
		instrD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		jalD,
		jrD,
		balD,
		jalrD,
		hilo_weD,
		alucontrolD,
		invalidD
		);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(5) regE(//MODEFIED
		clk,
		rst,~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE}
		);
	floprc #(3) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,~overflowE & regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	floprc #(2) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM & ~adelM},
		{memtoregW,regwriteW}
		);
endmodule
