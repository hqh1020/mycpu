`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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
module aludec(
	input wire[5:0] func,
	input wire[3:0] aluop,
	output reg[4:0] alucontrol
    );
	always @(*) begin
		case (aluop)
			`R_TYPE_OP:
			case(func)
				`SLL:alucontrol <= `SLL_CONTROL; 
				`AND:  alucontrol <= `AND_CONTROL; //and
				`OR:   alucontrol <= `OR_CONTROL;  //or
				`XOR:  alucontrol <= `XOR_CONTROL; //xor
				`NOR:  alucontrol <= `NOR_CONTROL; //nor
				`ADD:  alucontrol <= `ADD_CONTROL; //add
				`ADDU: alucontrol <= `ADDU_CONTROL;//addu
				`SUB:  alucontrol <= `SUB_CONTROL; //sub
				`SUBU: alucontrol <= `SUBU_CONTROL;//subu
				`SLT:  alucontrol <= `SLT_CONTROL; //slt
				`SLTU: alucontrol <= `SLTU_CONTROL;//sltu
				//add shift instr
				`SLL: alucontrol <= `SLL_CONTROL;//sll
				`SRL: alucontrol <= `SRL_CONTROL;//srl
				`SRA: alucontrol <= `SRA_CONTROL;//sra
				`SLLV: alucontrol <= `SLLV_CONTROL;//sllv
				`SRLV: alucontrol <= `SRLV_CONTROL;//srlv
				`SRAV: alucontrol <= `SRAV_CONTROL;//srav
				
				`MULT: alucontrol <= `MULT_CONTROL;//mutl
				`MULTU: alucontrol <= `MULTU_CONTROL;//multu
				`DIV: alucontrol <= `DIV_CONTROL;//div
				`DIVU: alucontrol <= `DIVU_CONTROL;//divu				

				//data_move inst
				`MFHI:alucontrol <= `MFHI_CONTROL;//mfhi
				`MFLO:alucontrol <= `MFLO_CONTROL;//mflo
				`MTHI:alucontrol <= `MTHI_CONTROL;//mthi
				`MTLO:alucontrol <= `MTLO_CONTROL;//mtlo
				default:  alucontrol <= 5'b00000;
			endcase
        `ANDI_OP: alucontrol <= `AND_CONTROL;
        `XORI_OP: alucontrol <= `ADDU_CONTROL;
        `SLTI_OP: alucontrol <= `SLT_CONTROL;
        `SLTIU_OP:alucontrol <= `SLT_CONTROL;
        `LUI_OP:  alucontrol <= `LUI_CONTROL;
        `ORI_OP:  alucontrol <= `OR_CONTROL;
        `MEM_OP:  alucontrol <=  `ADD_CONTROL;
        `ADDI_OP: alucontrol <= `ADD_CONTROL;
        `ADDIU_OP:alucontrol <= `SLTU_CONTROL;
        default:  alucontrol<=5'b00000;	
        endcase
	end
endmodule
