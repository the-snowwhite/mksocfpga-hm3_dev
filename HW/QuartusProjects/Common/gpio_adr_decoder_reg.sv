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
	input													chip_sel,
	input													write_reg,
	input													read_reg,
//	input	[MuxLedWidth-1:0]							leds_sig[NumGPIO-1:0],
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
parameter NumIOReg			= 6;
//parameter MuxLedWidth 	= 2;
parameter NumGPIO 			= 2;

// local param
parameter AdcOutShift		= 1;
parameter ReadInShift		= 2;
parameter WriteInShift		= 2;
parameter CsInShift			= 4;
parameter PortNumWidth		= 8;
parameter NumPinsPrIOReg	= 4;
parameter Mux_regPrIOReg	= 6;
parameter TotalNumregs 		= Mux_regPrIOReg * NumIOReg * NumPinsPrIOReg;

	wire reset_in = ~reset_reg_N;
	wire [GPIOWidth-1:0] io_read_data[NumGPIO-1:0];

	reg reset_in_r;
	reg [5:0] 						chip_sel_r;
	reg [ReadInShift:0]			read_reg_r;
	reg [WriteInShift:0]			write_reg_r;
//	reg [MuxLedWidth-1:0]		leds_sig_r[NumGPIO-1:0];
	reg [AddrWidth-1:0]			busaddress_r;
	reg [BusWidth-1:0]			busdata_in_r;
	reg [MuxGPIOIOWidth-1:0]	iodatafromhm3_r[NumGPIO-1:0];
	reg [BusWidth-1:0]			busdata_fromhm2_r;

	reg [AddrWidth-4:0]			local_address_r;

	reg [BusWidth-1:0]			ddr_reg[NumIOReg-1:0];
	reg [BusWidth-1:0]			odrain_reg[NumIOReg-1:0];
	reg [BusWidth-1:0]			mux_reg[NumIOReg-1:0][Mux_regPrIOReg-1:0];
	reg [PortNumWidth-1:0]		portselnum[TotalNumregs-1:0];


	wire [PortNumWidth-3:0]		mux_reg_index;
	wire [1:0] 						reg_muxindex;

	wire [GPIOWidth-1:0]			oe[NumGPIO-1:0];
	wire [GPIOWidth-1:0]			od[NumGPIO-1:0];

	wire [PortNumWidth-1:0]		portnumsel[NumGPIO-1:0][GPIOWidth-1:0];

	wire valid_address;
	wire write_address_valid;
	wire read_address 			= read_reg_r[ReadInShift];
	wire read_adc_address 		= read_reg_r[0];
	wire read_adc_out		 		= read_reg_r[AdcOutShift];
	wire write_address 			= write_reg_r[WriteInShift];
	wire adc_cs 					= chip_sel_r[CsInShift];
	wire mux_address_valid;

// ADC module:
	wire adc_address_valid = ( (busaddress_r == 'h0010) || (busaddress_r == 'h0014)) ? 1'b1 : 1'b0;
//	wire adc_address_valid = ( busaddress_r <= 'h0000) ? 1'b1 : 1'b0;
	wire [31:0]adc_data_out;
//	wire adc_chipsel = (adc_address_valid && adc_cs) ? 1'b1 : 1'b0;
	wire adc_read = (adc_address_valid && read_adc_address) ?  1'b1 : 1'b0;
	wire adc_write = (adc_address_valid && write_address) ?  1'b1 : 1'b0;


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
			chip_sel_r			<= 0;
			read_reg_r			<= 0;
			write_reg_r			<= 0;
//			leds_sig_r			<= '{NumGPIO{~0}};
			busaddress_r		<= 0;
			busdata_in_r		<= 0;
			iodatafromhm3_r	<= '{NumGPIO{~0}};
			busdata_fromhm2_r	<= 0;
		end else begin
			reset_in_r							<= reset_in;
			chip_sel_r[CsInShift:1]			<= chip_sel_r[CsInShift-1:0];
			chip_sel_r[0]						<= chip_sel;
			read_reg_r[ReadInShift:1]		<= read_reg_r[ReadInShift-1:0];
			read_reg_r[0]						<= read_reg;
			write_reg_r[WriteInShift:1]	<= write_reg_r[WriteInShift-1:0];
			write_reg_r[0]						<= write_reg;
//			leds_sig_r							<= leds_sig;
			busaddress_r						<= {{busaddress[AddrWidth-1:2]},{2'b0}};
			busdata_in_r						<= busdata_in;
			iodatafromhm3_r					<= iodatafromhm3;
			busdata_fromhm2_r					<= busdata_fromhm2;
			local_address_r					<= (busaddress_r - 'h1000);
		end
	end

	generate begin
		if (NumGPIO >= 1) begin
			assign oe[0] = {2'b11,ddr_reg[1][9:0],ddr_reg[0][23:0]};
			assign od[0] = {2'b00,odrain_reg[1][9:0],odrain_reg[0][23:0]};
		end
		if (NumGPIO >= 2) begin
			assign oe[1] = {2'b11,ddr_reg[2][19:0],ddr_reg[1][23:10]};
			assign od[1] = {2'b00,odrain_reg[2][19:0],odrain_reg[1][23:10]};
		end
		if (NumGPIO >= 3) begin
			assign oe[2] = {2'b11,ddr_reg[4][5:0],ddr_reg[3][23:0],ddr_reg[2][23:20]};
			assign od[2] = {2'b00,odrain_reg[4][5:0],odrain_reg[3][23:0],odrain_reg[2][23:20]};
		end
		if (NumGPIO == 4) begin
			assign oe[3] = {2'b11,ddr_reg[5][15:0],ddr_reg[4][23:6]};
			assign od[3] = {2'b00,odrain_reg[5][15:0],odrain_reg[4][23:6]};
		end
	end
	endgenerate


	genvar ni,ps;
	generate for(ni=0;ni<NumIOReg;ni=ni+1) begin : niinitloop
		for(ps=0;ps<Mux_regPrIOReg;ps=ps+1) begin : psinitloop
			always @(posedge reg_clk) begin
				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+0] <= mux_reg[ni][ps][0+:PortNumWidth];
				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+1] <= mux_reg[ni][ps][PortNumWidth+:PortNumWidth];
				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+2] <= mux_reg[ni][ps][(PortNumWidth*2)+:PortNumWidth];
				portselnum[(ps*4)+((Mux_regPrIOReg*4)*ni)+3] <= mux_reg[ni][ps][(PortNumWidth*3)+:PortNumWidth];
		end
		end
	end
	endgenerate


	genvar po;
	generate for(po=0;po<NumGPIO;po=po+1) begin : pnloop
		assign portnumsel[po][MuxGPIOIOWidth-1:0] = portselnum[(po*MuxGPIOIOWidth)+:MuxGPIOIOWidth];
//		assign portnumsel[po][GPIOWidth-1] = 8'(((1+po)*GPIOWidth)-1);
//		assign portnumsel[po][GPIOWidth-2] = 8'(((1+po)+GPIOWidth)-2);
	end
	endgenerate

	assign valid_address = 	((busaddress_r >= 'h1100) && (busaddress_r < 'h1200) ||
									(busaddress_r >= 'h1300) && busaddress_r < 'h1400) ? 1'b1 : 1'b0;

	assign write_address_valid = ((valid_address == 1'b1) && (write_address == 1'b1)) ? 1'b1 : 1'b0;

//	assign mux_address_valid = ((busaddress_r >= 'h1120) && (busaddress_r < 'h1200) && (chip_sel_r[5] == 1'b1)) ? 1'b1 : 1'b0;
	assign mux_address_valid = ((busaddress_r >= 'h1120) && (busaddress_r < 'h1200) && (read_address == 1'b1)) ? 1'b1 : 1'b0;

	genvar l,pl;
	generate for(l=0;l<NumIOReg;l=l+1) begin : reg_initloop
		for(pl=0;pl<Mux_regPrIOReg;pl=pl+1) begin : initpnumloop
			always @(posedge reset_in_r or posedge write_address_valid)begin
				if (reset_in_r)begin
					if(pl == 0) begin ddr_reg[l] <= 0; odrain_reg[l] <= 0; end
					mux_reg[l][pl] <= (((l*24) + (pl*4)) + (((l*24)+((pl*4)+1)) << PortNumWidth) +
					(((l*24)+((pl*4)+2)) << (PortNumWidth * 2)) + (((l*24)+((pl*4)+3)) << (PortNumWidth * 3)));
				end
				else if (write_address_valid) begin
					if(pl == 0) begin
						if (local_address_r == (12'h100+(l*4))) begin ddr_reg[l] <= busdata_in_r; end
						if (local_address_r == (12'h300+(l*4))) begin odrain_reg[l] <= busdata_in_r; end
					end
					if (local_address_r == (12'h120+(l*4))) begin mux_reg[l][pl] <= busdata_in_r; end
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
//         .out_data({leds_sig_r[il],iodatafromhm3_r[il]}) ,  // input [IOIOWidth-1:0] out_data_sig
         .out_data(iodatafromhm3_r[il]) ,  // input [IOIOWidth-1:0] out_data_sig
			.gpioport(gpioport[il]) ,	// inout [IOIOWidth-1:0] gpioport_sig
			.read_data(io_read_data[il]) 	// output [IOIOWidth-1:0] read_data_sig
		);
//		defparam bidir_io_inst[il].IOWidth = GPIOWidth;
//		defparam bidir_io_inst[il].PortNumWidth = PortNumWidth;
	end
	endgenerate

	assign reg_muxindex 	= local_address_r - 12'h120;
	assign mux_reg_index		= ((reg_muxindex < 6)  ? 0 : (reg_muxindex < 12) ? 1 :
									(reg_muxindex < 18) ? 2 : (reg_muxindex < 24) ? 3 :
									(reg_muxindex < 30) ? 4 : 5);


	always @(posedge reset_in_r or posedge mux_address_valid or posedge read_address)begin
		if (reset_in_r)begin
//			busdata_out <= ~ 'bz;
			busdata_out <= 32'b0;
		end
		else if (mux_address_valid) begin
			busdata_out <= mux_reg[mux_reg_index][reg_muxindex];
		end
		else if (adc_address_valid) begin
			busdata_out <= adc_data_out;
		end
		else begin
//			busdata_out <= busdata_fromhm2_r;
			busdata_out <= busdata_fromhm2;
		end
	end

/*
	always @(posedge reset_in or posedge reg_clk )begin
		if (reset_in )begin
//				busdata_out <= ~ 'bz;
			busdata_out <= 0;
		end
		else if (CLOCK) begin
			busdata_out <= busdata_fromhm2;
		end
	end
*/
endmodule

