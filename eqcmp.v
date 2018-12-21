`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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
module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output reg y
    );
	always@(*) begin
		case(op)
			`BEQ : y <= (a == b);
			`BNE : y <= (a != b);
			`BGTZ: y <= (a[31] == 0 & a != 32'b0);
			`BLEZ: y <= (a[31] == 1 | a == 32'b0);
			`REGIMM_INST:
				case(rt)
					`BLTZ : y <= (a[31] == 1);
					`BLTZAL:y <= (a[31] == 1);
					`BGEZ : y <= (a[31] == 0);
					`BGEZAL:y <= (a[31] == 0);
					
					default : y <= 0;
			endcase
			
			default : y <= 0;
		endcase
	end
endmodule
