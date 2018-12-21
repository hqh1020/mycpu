`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/14 12:08:57
// Design Name: 
// Module Name: memsel
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

module memsel(
	input wire [31:0] pcM,
	input wire [5:0] op,
	input wire [31:0] addr,//virtual addr
	input wire [31:0] writedataM,
	input wire [31:0] readdataM,
	output reg[3:0] sel,
	output reg[31:0] writedata2M, 
	output reg[31:0] finaldata,
	output reg adelM,
	output reg adesM,
	output reg [31:0] bad_addrM
    );

	always @(*) begin 
		adelM <= 1'b0; 
		adesM <= 1'b0;
		bad_addrM <= pcM;//.??
		case (op)
			`LW: begin
				sel <= 4'b0000;
				if(addr[1:0] != 2'b00) begin 
					adelM <= 1'b1; 
					bad_addrM <= addr;
				end
			end
			`LB,`LBU: begin
				sel <= 4'b0000; 
			end
			`LH,`LHU : begin 
					sel <= 4'b0000; 
					if(addr[0] != 1'b0) begin
						adelM <= 1'b1; 
						bad_addrM <= addr;
					end
			end
			`SW : begin 
					sel <= 4'b1111; writedata2M <= writedataM;
					if(addr[1:0] != 2'b00) begin
						adesM <= 1'b1;  
						bad_addrM <= addr;
						sel <= 4'b0000;
					end
			end
			`SH : begin
				writedata2M <= {writedataM[15:0],writedataM[15:0]};
				if(addr[0] != 1'b0) begin
					adesM <= 1'b1;
					bad_addrM <= addr;
					sel <= 4'b0000;
				end
				case (addr[1:0])
					2'b10 : sel <= 4'b1100;
					2'b00 : sel <= 4'b0011;
					default : sel <= 4'b0000;
				endcase
			end
			`SB : begin
				writedata2M <= {writedataM[7:0],writedataM[7:0],writedataM[7:0],writedataM[7:0]};
				case (addr[1:0])
					2'b11 : sel <= 4'b1000;
					2'b10 : sel <= 4'b0100;
					2'b01 : sel <= 4'b0010;
					2'b00 : sel <= 4'b0001;
					default : sel <= 4'b0000;
				endcase
			end
			default : sel <= 4'b0000;
		endcase
	end

	always @(*) begin 
		case (op)
			`LW : finaldata <= readdataM ;
			`LB : begin
				case (addr[1:0])
					2'b11 : finaldata <= {{24{readdataM[31]}},readdataM[31:24]};
					2'b10 : finaldata <= {{24{readdataM[23]}},readdataM[23:16]};
					2'b01 : finaldata <= {{24{readdataM[15]}},readdataM[15:8]};
					2'b00 : finaldata <= {{24{readdataM[7]}},readdataM[7:0]};
				endcase
			end
			`LBU : begin
				case (addr[1:0])
					2'b11 : finaldata <= {{24{0}},readdataM[31:24]};
					2'b10 : finaldata <= {{24{0}},readdataM[23:16]};
					2'b01 : finaldata <= {{24{0}},readdataM[15:8]};
					2'b00 : finaldata <= {{24{0}},readdataM[7:0]};
				endcase
			end
			`LH : begin
				case (addr[1:0])
					2'b10 : finaldata <= {{16{readdataM[31]}},readdataM[31:16]};
					2'b00 : finaldata <= {{16{readdataM[15]}},readdataM[15:0]};
				endcase
			end
			`LHU : begin
				case (addr[1:0])
					2'b10 : finaldata <= {{16{0}},readdataM[31:16]};
					2'b00 : finaldata <= {{16{0}},readdataM[15:0]};
				endcase
			end
			default : /* default */;
		endcase
	end
endmodule