/*
//		adc addresses:
//		0x0300 for start and status
//		0x0304 for data
*/
/*
//		0x1000	I/O port  0..23
//		0x1004  	I/O port 24..47
//		0x1008	I/O port 48..71
//		0x100C	I/O port 72..95
//		0x1010	I/O port 96..127
//		0x1014	I/O port 128..143

//   	0x1100	DDR for I/O port  0..23
//   	0x1104	DDR for I/O port  24..47
//   	0x1108	DDR for I/O port  48..71
//   	0x110C	DDR for I/O port  72..95
//   	0x1110	DDR for I/O port  96..127
//   	0x1114	DDR for I/O port  128..144
//   	'1' bit in DDR register makes corresponding GPIO bit an output
//
//		0x1300	OpenDrainSelect for I/O port  0..23
//		0x1304	OpenDrainSelect for I/O port  24..47
//		0x1308	OpenDrainSelect for I/O port  48..71
//		0x130C	OpenDrainSelect for I/O port  72..95
//		0x1310	OpenDrainSelect for I/O port  96..127
//		0x1314 	OpenDrainSelect for I/O port  128..143
//		'1' bit in OpenDrainSelect register makes corresponding GPIO an
//		open drain output.
//		If OpenDrain is selected for an I/O bit , the DDR register is ignored.
*/



module gpio_adr_decoder_reg(
	input													CLOCK,
	input													reg_clk,
	input													reset_reg_N,
	input													chip_sel,
	input													write_reg,
	input													read_reg,
	input	[AddrWidth-1:2]							busaddress,
	input	[BusWidth-1:0]								busdata_in,
	input	[MuxGPIOIOWidth-1:0]						iodatafromhm3[NumGPIO-1:0],
	input [BusWidth-1:0]								busdata_fromhm2,
//
	inout	[GPIOWidth-1:0]							gpioport[NumGPIO-1:0],
//
	output reg [MuxGPIOIOWidth-1:0]				iodatatohm3[NumGPIO-1:0],
	output reg [BusWidth-1:0]						busdata_out,

// adc interface

	input   adc_clk, // max 40mhz
	output  ADC_CONVST_o,
	output  ADC_SCK_o,
	output  ADC_SDI_o,
	input   ADC_SDO_i
);

parameter AddrWidth     	= 16;
parameter BusWidth			= 32;
parameter GPIOWidth			= 36;
parameter MuxGPIOIOWidth	= 36;
parameter NumIOAddrReg		= 6;
parameter NumGPIO 			= 2;

// local param
parameter IoRegWidth			= 24;
parameter AdcOutShift		= 1;
parameter ReadInShift		= 2;
parameter WriteInShift		= 2;
// //parameter CsInShift			= 4;
parameter PortNumWidth		= 8;
parameter NumPinsPrIOAddr	= 4;
parameter Mux_regPrIOReg	= 6;
parameter TotalNumregs 		= Mux_regPrIOReg * NumIOAddrReg * NumPinsPrIOAddr;

	wire reset_in = ~reset_reg_N;
	wire [GPIOWidth-1:0] io_read_data[NumGPIO-1:0];

	reg reset_in_r;
// //	reg [5:0] 						chip_sel_r;
	reg [ReadInShift:0]			read_reg_r;
	reg [WriteInShift:0]			write_reg_r;
	reg [AddrWidth-1:0]			busaddress_r;
	reg [BusWidth-1:0]			busdata_in_r;
	reg [MuxGPIOIOWidth-1:0]	iodatafromhm3_r[NumGPIO-1:0];
	reg [BusWidth-1:0]			busdata_fromhm2_r;

	reg [AddrWidth-1:0]			local_address_r;

	reg [IoRegWidth-1:0]			io_reg[NumIOAddrReg-1:0];
	reg [IoRegWidth-1:0]			od_reg[NumIOAddrReg-1:0];
	reg [IoRegWidth-1:0]			ddr_reg[NumIOAddrReg-1:0];

//	reg [BusWidth-1:0]			mux_reg[NumIOAddrReg-1:0][Mux_regPrIOReg-1:0];

//	reg [PortNumWidth-1:0]		portselnum[TotalNumregs-1:0];


	wire [GPIOWidth-1:0]			io_reg_gpio[NumGPIO-1:0];
	wire [PortNumWidth-1:0]		mux_reg_index;
	wire [4:0] 						mux_reg_addr;
	wire [1:0] 						mux_reg_byte;

	wire [GPIOWidth-1:0]			oe[NumGPIO-1:0];
	wire [GPIOWidth-1:0]			od[NumGPIO-1:0];

	wire [PortNumWidth-1:0]		portnumsel[NumGPIO-1:0][GPIOWidth-1:0];

//	wire valid_address;
//	wire write_address_valid;
	wire read_address 			= read_reg_r[ReadInShift];
	wire read_adc_address 		= read_reg_r[0];
	wire read_adc_out		 		= read_reg_r[AdcOutShift];
	wire write_address 			= write_reg_r[WriteInShift];
//	wire adc_cs 					= chip_sel_r[CsInShift];

	wire adc_address_valid = ( (busaddress_r == 'h0300) || (busaddress_r == 'h0304)) ? 1'b1 : 1'b0;
	wire io_address_valid = ((busaddress_r >= 'h1000) && (busaddress_r < 'h1020)) ? 1'b1 : 1'b0;
	wire ddr_address_valid = ((busaddress_r >= 'h1100) && (busaddress_r < 'h1120)) ? 1'b1 : 1'b0;
	wire mux_address_valid = ((busaddress_r >= 'h1120) && (busaddress_r < 'h1200)) ? 1'b1 : 1'b0;
	wire od_address_valid = ((busaddress_r >= 'h1300) && (busaddress_r < 'h1320)) ? 1'b1 : 1'b0;

	wire adc_read = (adc_address_valid && read_adc_address) ?  1'b1 : 1'b0;
	wire io_read = (io_address_valid && read_address) ?  1'b1 : 1'b0;
	wire ddr_read = (ddr_address_valid && read_address) ?  1'b1 : 1'b0;
	wire mux_read = (mux_address_valid && read_address) ?  1'b1 : 1'b0;
	wire od_read = (od_address_valid && read_address) ?  1'b1 : 1'b0;

	wire adc_write = (adc_address_valid && write_address) ?  1'b1 : 1'b0;
	wire io_write = (io_address_valid && write_address) ?  1'b1 : 1'b0;
	wire ddr_write = (ddr_address_valid && write_address) ?  1'b1 : 1'b0;
	wire mux_write = (mux_address_valid && write_address) ?  1'b1 : 1'b0;
	wire od_write = (od_address_valid && write_address) ?  1'b1 : 1'b0;

// ADC module:
	wire [31:0]adc_data_out;


adc_ltc2308_fifo adc_ltc2308_fifo_inst
(
	.clock(CLOCK) ,	// input  clock_sig
	.reset_n(reset_reg_N) ,	// input  reset_n_sig
	.addr(busaddress_r[2]) ,	// input  addr_sig
	.read(adc_read) ,	// input  read_sig
	.reg_outdata(read_adc_out) ,	// input  read_sig
	.write(adc_write) ,	// input  write_sig
	.readdataout(adc_data_out) ,	// output [31:0] readdataout_sig
	.writedatain(busdata_in_r) ,	// input [31:0] writedatain_sig
//ADC
	.adc_clk(adc_clk) ,	// input  adc_clk_sig
	.ADC_CONVST_o(ADC_CONVST_o) ,	// output  ADC_CONVST_o_sig
	.ADC_SCK_o(ADC_SCK_o) ,	// output  ADC_SCK_o_sig
	.ADC_SDI_o(ADC_SDI_o) ,	// output  ADC_SDI_o_sig
	.ADC_SDO_i(ADC_SDO_i) 	// input  ADC_SDO_i_sig
);

// I/O stuff:

	always @(posedge reg_clk or posedge reset_in) begin
		if(reset_in) begin
			reset_in_r			<= 0;
//			chip_sel_r			<= 0;
			read_reg_r			<= 0;
			write_reg_r			<= 0;
			busaddress_r		<= 0;
			busdata_in_r		<= 0;
			iodatafromhm3_r	<= '{NumGPIO{~0}};
			busdata_fromhm2_r	<= 0;
		end else begin
			reset_in_r							<= reset_in;
//			chip_sel_r[CsInShift:1]			<= chip_sel_r[CsInShift-1:0];
//			chip_sel_r[0]						<= chip_sel;
			read_reg_r[ReadInShift:1]		<= read_reg_r[ReadInShift-1:0];
			read_reg_r[0]						<= read_reg;
			write_reg_r[WriteInShift:1]	<= write_reg_r[WriteInShift-1:0];
			write_reg_r[0]						<= write_reg;
			busaddress_r						<= {{busaddress[AddrWidth-1:2]},{2'b0}};
			busdata_in_r						<= busdata_in;
			iodatafromhm3_r					<= iodatafromhm3;
			busdata_fromhm2_r					<= busdata_fromhm2;
			local_address_r					<= busaddress;
		end
	end

	genvar numio, numgio;
	generate begin
		if (NumGPIO >= 1) begin
			assign io_reg_gpio[0] = {io_reg[1][11:0],io_reg[0][23:0]};
			assign oe[0] = {ddr_reg[1][11:0],ddr_reg[0][23:0]};
			assign od[0] = {od_reg[1][11:0],od_reg[0][23:0]};
		end
		if (NumGPIO >= 2) begin
			assign io_reg_gpio[1] = {io_reg[2][23:0],io_reg[1][23:12]};
			assign oe[1] = {ddr_reg[2][23:0],ddr_reg[1][23:12]};
			assign od[1] = {od_reg[2][23:0],od_reg[1][23:12]};
		end
		if (NumGPIO >= 3) begin
			assign io_reg_gpio[2] = {io_reg[4][11:0],io_reg[3][23:0]};
			assign oe[2] = {ddr_reg[4][11:0],ddr_reg[3][23:0]};
			assign od[2] = {od_reg[4][11:0],od_reg[3][23:0]};
		end
		if (NumGPIO == 4) begin
			assign io_reg_gpio[3] = {io_reg[5][23:0],io_reg[4][23:12]};
			assign oe[3] = {ddr_reg[5][23:0],ddr_reg[4][23:12]};
			assign od[3] = {od_reg[5][23:0],od_reg[4][23:12]};
		end

//		for(numgio=0;numio<NumGPIO;numgio++)begin : gioloop
////			for(numio=0;numio<GPIOWidth;numio++)begin : gportloop
////				assign gpioport[numgio][numio] = oe[numgio][numio] ? io_reg_gpio[numgio][numio] : 1'bz;
//			assign gpioport[numgio] = oe[numgio] ? io_reg_gpio[numgio] : '{NumGPIO{1'bz}};
//			assign io_data_in[numgio] = gpioport[numgio];
////			end
//		end
	end
	endgenerate

//	genvar ni,ps;
//	generate for(ni=0;ni<NumIOAddrReg;ni=ni+1) begin : niinitloop
//		for(ps=0;ps<Mux_regPrIOReg;ps=ps+1) begin : psinitloop
//			always @(posedge reg_clk) begin
//				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+0] <= mux_reg[ni][ps][0+:PortNumWidth];
//				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+1] <= mux_reg[ni][ps][PortNumWidth+:PortNumWidth];
//				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+2] <= mux_reg[ni][ps][(PortNumWidth*2)+:PortNumWidth];
//				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+3] <= mux_reg[ni][ps][(PortNumWidth*3)+:PortNumWidth];
//			end
//		end
//	end
//	endgenerate
//

//	genvar po;
//	generate for(po=0;po<NumGPIO;po=po+1) begin : pnloop
//		assign portnumsel[po][MuxGPIOIOWidth-1:0] = portselnum[(po*MuxGPIOIOWidth)+:MuxGPIOIOWidth];
//	end
//	endgenerate
//
//	assign valid_address = 	((local_address_r >= 'h400) && (local_address_r < 'h480) ||
//									(local_address_r >= 'h4C0) && local_address_r < 'h500) ? 1'b1 : 1'b0;

//	assign write_address_valid = ((valid_address == 1'b1) && (write_address == 1'b1)) ? 1'b1 : 1'b0;

//	assign mux_reg_index 	= local_address_r - 16'h0448;
//	assign mux_reg_addr		= (mux_reg_index[6:2]);
//	assign mux_reg_byte		= (mux_reg_index[1:0]);

	// Writes:
	genvar ll,pl;
	generate for(ll=0;ll<NumIOAddrReg;ll=ll+1) begin : reg_initloop
//		for(pl=0;pl<NumPinsPrIOAddr;pl=pl+1) begin : initpnumloop
//			always @(posedge reset_in_r or posedge io_write or posedge ddr_write or posedge od_write or posedge write_address)begin
			always @(posedge reset_in_r or posedge io_write or posedge ddr_write or posedge od_write) begin
				if (reset_in_r) begin io_reg[ll] <= 0; ddr_reg[ll] <= 0; od_reg[ll] <= 0; end
//					if(pl == 0) begin io_reg[l] <= 0; ddr_reg[l] <= 0; od_reg[l] <= 0; end
//					mux_reg[l][pl] <= (((l*16) + (pl*4)) + (((l*16)+((pl*4)+1)) << PortNumWidth) +
//					(((l*16)+((pl*4)+2)) << (PortNumWidth * 2)) + (((l*16)+((pl*4)+3)) << (PortNumWidth * 3)));
//				end
				else begin
					if(ll == 0) begin
						if (io_write) begin io_reg[local_address_r[2:0]] <= busdata_in_r[IoRegWidth-1:0]; end
						else if (ddr_write) begin ddr_reg[local_address_r[2:0]] <= busdata_in_r[IoRegWidth-1:0]; end
						else if (od_write) begin od_reg[local_address_r[2:0]] <= busdata_in_r[IoRegWidth-1:0]; end
//						else if (mux_address_valid) begin mux_reg[mux_reg_addr][mux_reg_byte] <= busdata_in_r; end
//						else begin
//						iodatatohm3 <= busdata_in_r;
					end
				end
			end
//		end
	end
	endgenerate


	genvar il;
	generate for(il=0;il<NumGPIO;il=il+1) begin : gpiooutloop
		bidir_io #(.IOWidth(GPIOWidth),.PortNumWidth(PortNumWidth)) bidir_io_inst
		(
			.clk(reg_clk),
//			.portselnum(portnumsel[il]),
			.oe(oe[il]) ,	// input  oe_sig
//			.od(od[il]) ,	// input  od_sig
         .out_data(iodatafromhm3_r[il]) ,  // input [IOIOWidth-1:0] out_data_sig
			.gpioport(gpioport[il]) ,	// inout [IOIOWidth-1:0] gpioport_sig
			.read_data(io_read_data[il]) 	// output [IOIOWidth-1:0] read_data_sig
		);
//		defparam bidir_io_inst[il].IOWidth = GPIOWidth;
//		defparam bidir_io_inst[il].PortNumWidth = PortNumWidth;
	end
	endgenerate


	// Read:

	always @(posedge reset_in_r or posedge adc_read or posedge io_read or posedge ddr_read
//	or posedge mux_read or posedge od_read or posedge read_address)begin
	or posedge od_read or posedge read_address)begin
		if (reset_in_r)begin
//			busdata_out <= ~ 'bz;
			busdata_out <= 32'b0;
		end
		else if (adc_read) begin
			busdata_out <= adc_data_out;
		end
		else if (io_read) begin
			if((busaddress_r >= 'h1000) && (busaddress_r < 'h1004))
				busdata_out <= {8'b0,io_read_data[0][23:0]};
//				busdata_out <= {8'b0,gpioport[0][23:0]};
			if((busaddress_r >= 'h1004) && (busaddress_r < 'h1008))
				busdata_out <= {8'b0,io_read_data[1][11:0],io_read_data[0][35:24]};
//				busdata_out <= {8'b0,gpioport[1][11:0],gpioport[0][35:24]};
			if((busaddress_r >= 'h1008) && (busaddress_r < 'h100c))
				busdata_out <= {8'b0,io_read_data[1][35:12]};
//				busdata_out <= {8'b0,gpioport[1][35:12]};
		end
		else if (ddr_read) begin busdata_out <= ddr_reg[local_address_r[2:0]]; end
//		else if (mux_read) begin busdata_out <= mux_reg[mux_reg_addr][mux_reg_byte]; end
		else if (od_read) begin busdata_out <=  od_reg[local_address_r[2:0]]; end
		else begin
			busdata_out <= busdata_fromhm2;
		end
	end

endmodule

