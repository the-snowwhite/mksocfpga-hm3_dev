/*
//   0x1100       DDR for I/O port  0..23
//   0x1104       DDR for I/O port  24..47
//   0x1108       DDR for I/O port  48..71
//   0x110C       DDR for I/O port  72..95
//   0x1110       DDR for I/O port  96..127
//   0x1114       DDR for I/O port  128..144
//   '1' bit in DDR register makes corresponding GPIO bit an output
*/

module gpio_adr_decoder_reg(
	input													CLOCK,
	input													reg_clk,
	input													reset_reg_N,
	input													write_reg,
	input													read_reg,
	input	[MuxLedWidth-1:0]							leds_sig[NumGPIO-1:0],
	input	[AddrWidth-3:0]							busaddress,
	input	[BusWidth-1:0]								busdata_in,
	input	[MuxGPIOIOWidth-1:0]						iodatafromhm3[NumGPIO-1:0],
	input [BusWidth-1:0]								busdata_fromhm2,
//
	inout	[GPIOWidth-1:0]							ioport[NumGPIO-1:0],
//
	output reg [MuxGPIOIOWidth-1:0]				iodatatohm3[NumGPIO-1:0],
	output 	reg	[BusWidth-1:0]					busdata_out
);

parameter AddrWidth     	= 16;
parameter BusWidth			= 32;
parameter GPIOWidth			= 36;
parameter MuxGPIOIOWidth	= 34;
parameter NumIOReg			= 6;
parameter MuxLedWidth 		= 2;
parameter NumGPIO 			= 1;
parameter PortNumWidth		= 8;
parameter PortNumsPrReg		= 4;
parameter MuxregPrIOReg		= 6;
parameter TotalNumregs 	= MuxregPrIOReg * NumIOReg * PortNumsPrReg;

	wire reset_reg = ~reset_reg_N;
	wire [GPIOWidth-1:0] io_read_data[NumGPIO-1:0];

	reg [1:0] write_r;
	reg [3:0] read_r;
	reg [AddrWidth-1:0]			busaddr;
	reg [32:0]						busdata_in_reg;
	reg [23:0]						ddr_reg[NumIOReg-1:0];
	reg [23:0]						odrain_reg[NumIOReg-1:0];
	reg [32:0]						mux_reg[NumIOReg-1:0][MuxregPrIOReg-1:0];
	reg [MuxLedWidth-1:0]		leds_r[NumGPIO-1:0];
	reg [MuxGPIOIOWidth-1:0]	iodatafromhm3_r[NumGPIO-1:0];
	reg [PortNumWidth-1:0] 		portselnum[TotalNumregs-1:0];

	wire [GPIOWidth-1:0]	oe[NumGPIO-1:0];
	wire [GPIOWidth-1:0]	od[NumGPIO-1:0];

	wire [PortNumWidth-1:0] portnumsel[NumGPIO-1:0][GPIOWidth-1:0];

	wire read_ready;

	generate begin
		if (NumGPIO >= 1) begin
			assign oe[0] = {2'b11,ddr_reg[1][9:0],ddr_reg[0][23:0]};
			assign od[0] = {2'b0,odrain_reg[1][9:0],odrain_reg[0][23:0]};
		end
		if (NumGPIO >= 2) begin
			assign oe[1] = {2'b11,ddr_reg[2][19:0],ddr_reg[1][23:10]};
			assign od[1] = {2'b11,odrain_reg[2][19:0],odrain_reg[1][23:10]};
		end
		if (NumGPIO >= 3) begin
			assign oe[2] = {2'b11,ddr_reg[4][5:0],ddr_reg[3][23:0],ddr_reg[2][23:20]};
			assign od[2] = {2'b11,odrain_reg[4][5:0],odrain_reg[3][23:0],odrain_reg[2][23:20]};
		end
		if (NumGPIO == 4) begin
			assign oe[3] = {2'b11,ddr_reg[5][15:0],ddr_reg[4][23:6]};
			assign od[3] = {2'b11,odrain_reg[5][15:0],odrain_reg[4][23:6]};
		end
	end
	endgenerate
//	reg syx_data_rdy_r[3:0];

//	wire [MuxGPIOIOWidth-1:0] tohm2data;
//

	genvar ki,ps,mr;
	generate for(ki=0;ki<NumIOReg;ki=ki+1) begin : ininitloop
		for(ps=0;ps<MuxregPrIOReg;ps=ps+1) begin : psinitloop
			for(mr=0;mr<PortNumsPrReg;mr=mr+1) begin : mrinitloop
				always @(posedge reg_clk) begin
					portselnum[((ki * NumIOReg * PortNumsPrReg) + (ps * PortNumsPrReg) + mr)]
					<= mux_reg[ki][ps][(mr*PortNumWidth)+:PortNumWidth];
				end
			end
		end
	end
	endgenerate


	genvar po;
	generate for(po=0;po<NumGPIO;po=po+1) begin : pnloop
		assign portnumsel[po][MuxGPIOIOWidth-1:0] = portselnum[(po*MuxGPIOIOWidth)+:MuxGPIOIOWidth];
		assign portnumsel[po][GPIOWidth-1] = 8'h23;
		assign portnumsel[po][GPIOWidth-2] = 8'h22;
	end
	endgenerate

	always @(posedge reg_clk or posedge reset_reg)begin
		if (reset_reg)begin
			busaddr <= 0;
			busdata_in_reg <= 0;
			leds_r <= '{NumGPIO{'0}};
			iodatafromhm3_r <= '{NumGPIO{~0}};
			write_r <= 0;
			read_r <=  0;
//			iodatatohm3 <= 0;
		end
		else begin
			busaddr <= {busaddress,2'b0};
			busdata_in_reg <= busdata_in;
			write_r[0] <= write_reg;
			write_r[1] <= write_r[0];
			leds_r <= leds_sig;
			iodatafromhm3_r <= iodatafromhm3;
//			iodatatohm3<= io_read_data[GPIOWidth-MuxLedWidth-1:0];
			iodatatohm3<= io_read_data;
			read_r[0] <= read_reg;
			read_r[1] <= read_r[0];
			read_r[2] <= read_r[1];
			read_r[3] <= read_r[2];
//			iodatatohm3 <= tohm2data;
		end
	end

		assign read_ready = read_r[1] | read_r[2] | read_r[3];

	genvar l,pl;
	generate for(l=0;l<NumIOReg;l=l+1) begin : reg_initloop
		for(pl=0;pl<MuxregPrIOReg;pl=pl+1) begin : initpnumloop
			always @(posedge reset_reg or posedge write_r[1])begin
				if (reset_reg)begin
					if(pl == 0) ddr_reg[l] <= 0;
					if(pl == 0) odrain_reg[l] <= 0;
					mux_reg[l][pl] <= (((l*24) + (pl*4)) + (((l*24)+((pl*4)+1)) << PortNumWidth) +
					(((l*24)+((pl*4)+2)) << (PortNumWidth * 2)) + (((l*24)+((pl*4)+3)) << (PortNumWidth * 3)));
				end
				else begin
					if (busaddr == (14'h1100+(l*4))) begin if(pl == 0) ddr_reg[l] <= busdata_in_reg[23:0]; end
					if (busaddr == (14'h1120+(l*4))) begin mux_reg[l][pl] <= busdata_in_reg; end
					if (busaddr == (14'h1300+(l*4))) begin if(pl == 0) odrain_reg[l] <= busdata_in_reg[23:0]; end
				end
			end
		end
	end
	endgenerate

	genvar il;
	generate for(il=0;il<NumGPIO;il=il+1) begin : gpiooutloop
		bidir_io #(.IOWidth(GPIOWidth),.PortNumWidth(PortNumWidth)) bidir_io_inst
		(
			.portselnum(portnumsel[il]),
			.oe(oe[il]) ,	// input  oe_sig
			.od(od[il]) ,	// input  od_sig
			.out_data({leds_r[il],iodatafromhm3_r[il]}) ,	// input [IOIOWidth-1:0] out_data_sig
			.ioport(ioport[il]) ,	// inout [IOIOWidth-1:0] ioport_sig
			.read_data(io_read_data[il]) 	// output [IOIOWidth-1:0] read_data_sig
		);
//		defparam bidir_io_inst[il].IOWidth = GPIOWidth;
//		defparam bidir_io_inst[il].PortNumWidth = PortNumWidth;
	end
//	
//	else begin
//		bidir_io #(.IOWidth(GPIOWidth),.PortNumWidth(PortNumWidth)) bidir_io_inst [NumGPIO-1:0]
//		(
//			.portselnum(portnumsel),
//			.oe(oe) ,	// input  oe_sig
//			.od(od) ,	// input  od_sig
//			.out_data('{leds_r,iodatafromhm3_r}) ,	// input [IOIOWidth-1:0] out_data_sig
//			.ioport(ioport) ,	// inout [IOIOWidth-1:0] ioport_sig
//			.read_data(io_read_data) 	// output [IOIOWidth-1:0] read_data_sig
//		);
//
////		defparam bidir_io_inst[].IOWidth = GPIOWidth;
////		defparam bidir_io_inst[].PortNumWidth = PortNumWidth;
//	end
	endgenerate
	
	always @(posedge reset_reg or posedge read_ready or posedge CLOCK)begin
		if (reset_reg)begin
//				busdata_out <= ~ 'bz;
				busdata_out <= 0;
			end
		else if (read_ready) begin
			unique case (busaddr)
				14'h1120 : begin busdata_out <= mux_reg[0][0]; end
				14'h1124 : begin busdata_out <= mux_reg[0][1]; end
				14'h1128 : begin busdata_out <= mux_reg[0][2]; end
				14'h112C : begin busdata_out <= mux_reg[0][3]; end
				14'h1130 : begin busdata_out <= mux_reg[0][4]; end
				14'h1134 : begin busdata_out <= mux_reg[0][5]; end
				14'h1138 : begin busdata_out <= mux_reg[1][0]; end
				14'h113C : begin busdata_out <= mux_reg[1][1]; end
				14'h1140 : begin busdata_out <= mux_reg[1][2]; end
// 				14'h1100 : begin busdata_out <= ddr_reg[0]; end
// 				14'h1104 : begin busdata_out <= ddr_reg[1]; end
// 				14'h1108 : begin busdata_out <= ddr_reg[2]; end
// 				14'h110C : begin busdata_out <= ddr_reg[3]; end
// 				14'h1110 : begin busdata_out <= ddr_reg[4]; end
// 				14'h1114 : begin busdata_out <= ddr_reg[5]; end
// 				14'h1300 : begin busdata_out <= odrain_reg[0]; end
// 				14'h1304 : begin busdata_out <= odrain_reg[1]; end
// 				14'h1308 : begin busdata_out <= odrain_reg[2]; end
// 				14'h130C : begin busdata_out <= odrain_reg[3]; end
// 				14'h1310 : begin busdata_out <= odrain_reg[4]; end
// 				14'h1314 : begin busdata_out <= odrain_reg[5]; end
				default : begin busdata_out <= busdata_fromhm2; end
			endcase
		end
		else if (CLOCK) begin
			busdata_out <= busdata_fromhm2;
		end
	end
endmodule

