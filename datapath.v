`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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
module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD,jalrD,
	output wire equalD,
	output wire [31:0] instrD,
	input wire[4:0] alucontrolD,
	input wire[1:0] hilo_weD, 
	input wire invalidD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	output wire flushE,stallE,
	output wire overflow,zero,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedata2M,
	input wire[31:0] readdataM,
	output	wire [3:0] sel,
	output wire adelM,flushM,
	output wire [31:0] excepttypeM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire [31:0] pcW,
	output wire [31:0] resultW,
	output wire [4:0] writeregW,
	output wire flushW

	
    );

	//fetch stage
	wire stallF,flushF,is_in_delayslotF;
	wire [7:0] exceptF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcjrFD;
	//decode stage
	wire [31:0] pcplus4D;
	wire [5:0] opD,functD;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD,saD;//modefied add saD
	wire stallD,flushD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [31:0] pcD;
	wire [39:0] ascii;
	wire [7:0] exceptD;
	wire syscallD,breakD,eretD,is_in_delayslotD;
	// hi-lo reg read out
	wire [31:0] hiD,loD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [1:0] forwardhiloE;
	wire [4:0] rsE,rtE,rdE,saE;//modefied add saE
	wire [4:0] writereg1E,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	wire [31:0] aluout2E;
	wire [31:0] pcE;
	wire [5:0] opE;
	wire balE,jalE,jalrE;
	wire forwardC0E;
	wire [31:0] C0_inE,C0_outE,C0_in1E;
	wire C0_weE;//10 : mfc0; 11 : mtc0
	wire [7:0] exceptE;
	wire is_in_delayslotE;
	//hi-lo reg value to be written back
	wire [31:0] hi_alu_outE,lo_alu_outE;
	wire [31:0] hi_div_outE,lo_div_outE;
	wire div_start,div_ready;
	wire isdiv;
	wire [31:0] hi_mux_outE,lo_mux_outE;
	//hi-lo reg value propagate
	wire [31:0] hiE,loE;
	wire [31:0] hi2E,lo2E;
	wire [4:0] alucontrolE;
	wire [1:0] hilo_weE,hilo_we2E;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] pcM;
	wire [5:0] opM;
	wire [31:0] bad_addrM,writedataM,finaldata;
	wire adesM;
	wire [31:0] hi_alu_outM,lo_alu_outM;
	wire [1:0] hilo_weM;
	wire [5:0] rdM,rtM;
	wire C0_weM;
	wire [31:0] C0_outM;
	wire is_in_delayslotM;;
	wire [31:0] count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;
	wire timer_int_o;
	wire [7:0] exceptM;
	wire [31:0] newpcM;
 	//writeback stage
	wire [31:0] aluoutW,readdataW;
	//hi-lo reg
	wire [31:0] hi_alu_outW,lo_alu_outW;
	wire [1:0] hilo_weW;

	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		flushF,
		//decode stage
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,
		flushD,
		//execute stage
		alucontrolE,
		rsE,rtE,rdE,
		writereg2E,
		regwriteE,
		memtoregE,
		hilo_weE,
		forwardaE,forwardbE,forwardhiloE,forwardC0E,
		flushE,
		stallE,
		div_start,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		hilo_weM,
		C0_weM,
		rdM,
		excepttypeM,
		flushM,
		epc_o,
		newpcM,
		//write back stage
		writeregW,
		regwriteW,
		hilo_weW,
		flushW
		);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	//hi-lo reg
	hilo_reg hilo(clk,rst,hilo_weW,hi_alu_outW,lo_alu_outW,hiD,loD);

	//next PC logic (operates in fetch and decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);// +4  branch
	mux2 #(32) pcjrmux(pcnextbrFD,srca2D,jrD|jalrD,pcjrFD); //+4  branch  jr  jalr
	mux2 #(32) pcmux(pcjrFD,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD|jalD,pcnextFD); // +4  branch  jr jalr j jal 


	//fetch stage logic
	
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	assign is_in_delayslotF = (jumpD|jalrD|jrD|jalD|branchD);
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b0000_0000 : 8'b1000_0000;

	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8)  r4D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1)  r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);

	assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	assign functD = instrD[5:0];

	assign syscallD = (opD == 6'b000000 && functD == 6'b001100);
	assign breakD = (opD == 6'b000000 && functD == 6'b001101);
	assign eretD = (instrD == 31'b010000_1_0000_0000_0000_0000_000_011000);
	instdec instdec(instrD,ascii);

	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);//branch
	mux3 #(32) forwardamux(srcaD,aluout2E,aluoutM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,aluout2E,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	//execute stage
	assign C0_weE = ((opE == 6'b010000) & (rsE == 5'b00100)) ? 1 : 0;
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(32) r7E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(5)  r8E(clk,rst,~stallE,flushE,alucontrolD,alucontrolE);
	flopenrc #(5)  r9E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(6)  r10E(clk,rst,~stallE,flushE,opD,opE);//modefied add opM
	flopenrc #(64) r11E(clk,rst,~stallE,flushE,{hiD,loD},{hiE,loE});
	flopenrc #(2)  r12E(clk,rst,~stallE,flushE,hilo_weD,hilo_weE);
	flopenrc #(1)  r13E(clk,rst,~stallE,flushE,balD,balE);
	flopenrc #(1)  r14E(clk,rst,~stallE,flushE,jalD,jalE);
	flopenrc #(2)  r15E(clk,rst,~stallE,flushE,{is_in_delayslotD,jalrD},{is_in_delayslotE,jalrE});
	flopenrc #(8)  r16E(clk,rst,~stallE,flushE,{exceptD[7],syscallD,breakD,eretD,invalidD,3'b000},exceptE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux3 #(64) forwardhimux({hiE,loE},{hi_alu_outM,lo_alu_outM},{hi_alu_outW,lo_alu_outW},forwardhiloE,{hi2E,lo2E});
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	mux2 #(32) forwardC0_inmux(C0_inE,aluoutM,forwardC0E,C0_in1E);
	alu alu (srca2E,srcb3E,saE,alucontrolE,hi2E,lo2E,C0_in1E,C0_outE,aluoutE,overflow,zero,hi_alu_outE,lo_alu_outE);
	mux2 #(32) jalmux(aluoutE,pcE+8,jalE | jalrE | balE,aluout2E);//answer or pc to be stored
	mux2 #(5)  wr1mux(rtE,rdE,regdstE,writereg1E);//rt or rd
	mux2 #(5)  wr2mux(writereg1E,5'b11111,balE | jalE,writereg2E); // or 31 reg

	//divider_Primary modefied
	assign isdiv = (alucontrolE == `DIV_CONTROL)|(alucontrolE == `DIVU_CONTROL);
	assign div_start = ((alucontrolE == `DIV_CONTROL) | (alucontrolE == `DIVU_CONTROL)) ? 
							((div_ready == `DivResultNotReady) ? `DivStart : `DivStop) : `DivStop;
	assign hilo_we2E = (isdiv && div_ready) ? 2'b11:
						 	(isdiv && !div_ready) ? 2'b00:hilo_weE;
	mux2 #(64) hilo_div({hi_alu_outE,lo_alu_outE},{hi_div_outE,lo_div_outE},isdiv,{hi_mux_outE,lo_mux_outE});
	div div (clk,rst,alucontrolE == `DIV_CONTROL,srca2E,srcb3E,div_start,1'b0,{hi_div_outE,lo_div_outE},div_ready);

	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluoutM);
	floprc #(5)  r3M(clk,rst,flushM,writereg2E,writeregM);
	floprc #(32) r4M(clk,rst,flushM,pcE,pcM);
	floprc #(6)  r6M(clk,rst,flushM,opE,opM);//modefied add opM
	floprc #(64) r7M(clk,rst,flushM,{hi_mux_outE,lo_mux_outE},{hi_alu_outM,lo_alu_outM});//hi_alu_outM need to be renamed as hi_mux_outM;
	floprc #(2)  r8M(clk,rst,flushM,hilo_we2E,hilo_weM);
	floprc #(5)  r9M(clk,rst,flushM,rtE,rtM);
	floprc #(5)  r10M(clk,rst,flushM,rdE,rdM);
	floprc #(2)  r11M(clk,rst,flushM,C0_weE,C0_weM);
	floprc #(32) r12M(clk,rst,flushM,C0_outE,C0_outM);
	floprc #(8)  r13M(clk,rst,flushM,{exceptE[7:3],overflow,2'b00},exceptM);
	floprc #(1)  r14M(clk,rst,flushM,is_in_delayslotE,is_in_delayslotM);

	exception exp(rst,exceptM,adelM,adesM,status_o,cause_o,excepttypeM);
	memsel mems(pcM,opM,aluoutM,writedataM,readdataM,sel,writedata2M,finaldata,adelM,adesM,bad_addrM);//aluoutM: virtual address
	//exception exp(rst,exceptM,adelM,adesM,status_o,cause_o,excepttypeM);
	cp0_reg CP0(.clk(clk),
		.rst(rst),
		.we_i(C0_weM),
		.waddr_i(rdM),
		.raddr_i(rdE),
		.data_i(C0_outM),
		.int_i(6'b000000),
		.excepttype_i(excepttypeM),
		.current_inst_addr_i(pcM),
		.is_in_delayslot_i(is_in_delayslotM),
		.bad_addr_i(bad_addrM),
		//.memwriteM(memwriteM),

		.data_o(C0_inE),
		.count_o(count_o),
		.compare_o(compare_o),
		.status_o(status_o),
		.cause_o(cause_o),
		.epc_o(epc_o),
		.config_o(config_o),
		.prid_o(prid_o),
		.badvaddr(badvaddr),
		.timer_int_o(timer_int_o)
		);

	//writeback stage
	floprc #(32) r1W(clk,rst,flushW,aluoutM,aluoutW);
	floprc #(32) r2W(clk,rst,flushW,finaldata,readdataW);
	floprc #(5)  r3W(clk,rst,flushW,writeregM,writeregW);
	floprc #(64) r4W(clk,rst,flushW,{hi_alu_outM,lo_alu_outM},{hi_alu_outW,lo_alu_outW});
	floprc #(2)  r5W(clk,rst,flushW,hilo_weM,hilo_weW);
	floprc #(32) r6W(clk,rst,flushW,pcM,pcW);

	mux2 #(32) res1mux(aluoutW,readdataW,memtoregW,resultW);
	
  
endmodule
