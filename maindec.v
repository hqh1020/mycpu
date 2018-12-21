`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
`include"defines.h"
module maindec(
	input wire[31:0] instr,
	output wire memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,
	output wire jal,jr,bal,jalr,
	output wire [1:0] hilo_we,//00 don't write, 10 write hi, 01 write lo, 11 write both 
	output reg [4:0] alucontrol,
	output reg invalidD
	);
	wire [5:0] op, funct;
	wire [4:0] rt,rs;
	reg [12:0] controls;

	assign op = instr[31:26];
	assign funct = instr[5:0];
	assign rt = instr[20:16];
	assign rs = instr[25:21];

	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,jal,jr,bal,jalr,hilo_we} = controls;
	assign default_controls = 13'b0000_00_00000_00;
	assign default_alucontrol = 5'b00000;
	always @(*) begin
		invalidD <= 1'b0;
		case(op)
			`R_TYPE : begin
				controls <= 13'b1100_00_00000_00;
				case(funct)
				//logical operation
					`AND : alucontrol <= `AND_CONTROL;
					`OR  : alucontrol <= `OR_CONTROL;
					`XOR : alucontrol <= `XOR_CONTROL;
					`NOR : alucontrol <= `NOR_CONTROL;
				//shift operation
					`SLL : alucontrol <= `SLL_CONTROL;
					`SRL : alucontrol <= `SRL_CONTROL;
					`SRA : alucontrol <= `SRA_CONTROL;
					`SLLV : alucontrol <= `SLLV_CONTROL;
					`SRLV : alucontrol <= `SRLV_CONTROL;
					`SRAV : alucontrol <= `SRAV_CONTROL;
				//data movement operation
					`MFHI : alucontrol <= `MFHI_CONTROL;
					`MTHI : begin controls <= 13'b0000_00_00000_10; alucontrol <= `MTHI_CONTROL; end
					`MFLO : alucontrol <= `MFLO_CONTROL;
					`MTLO : begin controls <= 13'b0000_00_00000_01; alucontrol <= `MTLO_CONTROL; end
				//arithmetic operation
					`ADD : alucontrol <= `ADD_CONTROL;
					`ADDU: alucontrol <= `ADDU_CONTROL;
					`SUB : alucontrol <= `SUB_CONTROL;
					`SUBU: alucontrol <= `SUBU_CONTROL;
					`SLT : alucontrol <= `SLT_CONTROL;
					`SLTU: alucontrol <= `SLTU_CONTROL;
					`MULT: begin controls <= 13'b0000_00_00000_11; alucontrol <= `MULT_CONTROL; end
					`MULTU:begin controls <= 13'b0000_00_00000_11; alucontrol <= `MULTU_CONTROL; end
					`DIV : begin controls <= 13'b0000_00_00000_11; alucontrol <= `DIV_CONTROL; end
					`DIVU: begin controls <= 13'b0000_00_00000_11; alucontrol <= `DIVU_CONTROL; end
				//jump
					`JR :  begin controls <= 13'b0000_00_00100_00; alucontrol <= default_alucontrol; end
					`JALR: begin controls <= 13'b1100_00_00001_00; alucontrol <= default_alucontrol; end		
					
				// Privileged instrs
					`BREAK,`SYSCALL: begin controls <= default_controls; alucontrol <= default_alucontrol; end
					default : begin 
						controls <= default_controls; 
						alucontrol <= default_alucontrol; 
						invalidD <= 1'b1;
					end
				endcase
			end
			// logical operation
			`ANDI : begin controls <= 13'b1010_00_00000_00;	alucontrol <= `AND_CONTROL;	end
			`XORI : begin controls <= 13'b1010_00_00000_00;	alucontrol <= `XOR_CONTROL;	end
			`LUI  : begin controls <= 13'b1010_00_00000_00; alucontrol <= `LUI_CONTROL; end
			`ORI  : begin controls <= 13'b1010_00_00000_00; alucontrol <= `OR_CONTROL; end
			`MAX  : begin controls <= 13'b1100_00_00000_00; alucontrol <= `MAX_CONTROL; end
			//arithmetic operation
			`ADDI : begin controls <= 13'b1010_00_00000_00;	alucontrol <= `ADD_CONTROL;	end
			`ADDIU: begin controls <= 13'b1010_00_00000_00; alucontrol <= `ADDU_CONTROL; end
			`SLTI : begin controls <= 13'b1010_00_00000_00;	alucontrol <= `SLT_CONTROL;	end
			`SLTIU: begin controls <= 13'b1010_00_00000_00; alucontrol <= `SLTU_CONTROL; end
			//Branch 
			`BEQ : begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
			`BNE : begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
			`BGTZ: begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
			`BLEZ: begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
			`REGIMM_INST : case(rt)
				`BLTZ  : begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
				`BLTZAL: begin controls <= 13'b1001_00_00010_00; alucontrol <= default_alucontrol; end
				`BGEZ  : begin controls <= 13'b0001_00_00000_00; alucontrol <= default_alucontrol; end
				`BGEZAL: begin controls <= 13'b1001_00_00010_00; alucontrol <= default_alucontrol; end
				
				default : begin	
					controls <= default_controls; 
					alucontrol <= default_alucontrol;
					invalidD <= 1'b1; 
				end
			endcase
			//jump
			`J  : begin controls <= 13'b0000_00_10000_00; alucontrol <= default_alucontrol; end
			`JAL: begin controls <= 13'b1000_00_01000_00; alucontrol <= default_alucontrol; end
			//memory 
			`LW: begin controls <= 13'b1010_11_00000_00; alucontrol <= `ADD_CONTROL; end
			`SW: begin controls <= 13'b0010_10_00000_00; alucontrol <= `ADD_CONTROL; end
			`LB: begin controls <= 13'b1010_11_00000_00; alucontrol <= `ADD_CONTROL; end
			`LBU:begin controls <= 13'b1010_11_00000_00; alucontrol <= `ADD_CONTROL; end
			`LH: begin controls <= 13'b1010_11_00000_00; alucontrol <= `ADD_CONTROL; end
			`LHU:begin controls <= 13'b1010_11_00000_00; alucontrol <= `ADD_CONTROL; end
			`SH: begin controls <= 13'b0010_10_00000_00; alucontrol <= `ADD_CONTROL; end
			`SB: begin controls <= 13'b0010_10_00000_00; alucontrol <= `ADD_CONTROL; end

			//CP0
			`CP0: begin
				case(rs)
					5'b00100 : begin
						controls <= default_controls; alucontrol <= `MTC0_CONTROL;	
					end
					5'b00000 : begin
						controls <= 13'b1000_00_00000_00; alucontrol <= `MFC0_CONTROL;
					end
					default : begin 
						controls <= default_controls; 
						alucontrol <= default_alucontrol;
						invalidD <= 1'b1; 
					end
				endcase
			end
			
			default : begin 
				controls <= default_controls; 
				alucontrol <= default_alucontrol;
				invalidD <= 1'b1; 
			end
		endcase
	end
endmodule