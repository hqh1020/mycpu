`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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
module alu(
	input wire [31:0] a,b,
	input wire [4:0] sa,
	input wire [4:0] alucontrol,
	input wire [31:0] hi_in,lo_in,
	input wire [31:0] C0_in,
	output reg [31:0] C0_out,
	output reg [31:0] y,
	output wire overflow,
	output wire zero,
	output reg [31:0] hi_alu_out,lo_alu_out
	//need to add pcplus8E and cp0
    );
	
	reg[63:0] temp;

	assign overflow = (alucontrol==`SUB_CONTROL && (a[31]^y[31]) & (a[31]^b[31])) 
							|(alucontrol==`ADD_CONTROL && (a[31]^y[31]) & (y[31]^b[31]));
	assign zero = (y == 32'b0);

	always @(*)
	begin
		//overflow <= 0;
		case (alucontrol)
			//logical operation
		    `AND_CONTROL: y <= a & b;
		    `OR_CONTROL : y <= a | b;
		    `XOR_CONTROL: y <= a ^ b;
		    `NOR_CONTROL: y <= ~(a | b);
		    `LUI_CONTROL: y <= {b[15:0],{16{1'b0}}};
		    `MAX_CONTROL: y <= ($signed(a) < $signed(b)) ? b : a;
		    //shift operation
 		    `SLL_CONTROL: y <= b << sa;
		    `SRL_CONTROL: y <= b >> sa;
		    `SRA_CONTROL: begin temp = {{32{b[31]}},b} >> sa ; y = temp[31:0]; end
		    `SLLV_CONTROL: y <= b << a[4:0];
		    `SRLV_CONTROL: y <= b >> a[4:0];
		    `SRAV_CONTROL: begin temp = {{32{b[31]}},b} >>a[4:0] ; y = temp[31:0]; end

		    //arithmatic operation
 		    `ADD_CONTROL: begin 
 		    			y  <= a + b;
 		    			//overflow = (a[31]^y[31]) & (y[31]^b[31]);
 		    			end
 		    `ADDU_CONTROL:y <= a + b;
 		    `SUB_CONTROL: begin 
 		    			y  <= a - b;
 		    			//overflow = (a[31]^y[31]) & (a[31]^b[31]);
 		    			end
		    `SUBU_CONTROL: y <= a - b;
		    `SLT_CONTROL:  y <= ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
		    `SLTU_CONTROL: y <= (a < b) ? 32'b1 : 32'b0;
 		    `MULT_CONTROL: {hi_alu_out,lo_alu_out} <= $signed(a) * $signed(b);
		    `MULTU_CONTROL: {hi_alu_out,lo_alu_out} <= a * b;

		    //Data movement	
		    `MFHI_CONTROL: y <= hi_in;
 		    `MTHI_CONTROL: hi_alu_out <= a;
 		    `MFLO_CONTROL: y <= lo_in;
 		    `MTLO_CONTROL: lo_alu_out <= a;

 		    `MTC0_CONTROL: C0_out <= b;
 		    `MFC0_CONTROL: y <= C0_in; 

			default : y = 32'h00000000;
		endcase
	end

endmodule