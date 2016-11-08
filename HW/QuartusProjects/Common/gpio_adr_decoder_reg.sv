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
	output reg [BusWidth-1:0]						busdata_to_cpu,

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
parameter PortNumWidth		= 8;
parameter NumPinsPrIOAddr	= 4;
parameter Mux_regPrIOReg	= 6;
parameter TotalNumregs 		= Mux_regPrIOReg * NumIOAddrReg * NumPinsPrIOAddr;

	wire reset_in = ~reset_reg_N;
	wire [GPIOWidth-1:0] gpio_input_data[NumGPIO-1:0];

	reg reset_in_r;
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

	wire [GPIOWidth-1:0]			out_ena[NumGPIO-1:0];
	wire [GPIOWidth-1:0]			od[NumGPIO-1:0];

	wire [PortNumWidth-1:0]		portnumsel[NumGPIO-1:0][GPIOWidth-1:0];

	wire read_address 			= read_reg_r[ReadInShift];
	wire read_adc_address 		= read_reg_r[1];
	wire read_adc_out		 		= read_reg_r[AdcOutShift];
	reg write_address;

	wire adc_address_valid = ( (busaddress_r == 16'h0300) || (busaddress_r == 16'h0304)) ? 1'b1 : 1'b0;
//	wire io_address_valid = ((busaddress_r >= 16'h1000) && (busaddress_r < 16'h1020)) ? 1'b1 : 1'b0;
//	wire ddr_address_valid = ((busaddress_r >= 16'h1100) && (busaddress_r < 16'h1120)) ? 1'b1 : 1'b0;
//	wire mux_address_valid = ((busaddress_r >= 16'h1120) && (busaddress_r < 16'h1200)) ? 1'b1 : 1'b0;
//	wire od_address_valid = ((busaddress_r >= 16'h1300) && (busaddress_r < 16'h1320)) ? 1'b1 : 1'b0;

	wire adc_read_valid = (adc_address_valid && read_adc_address) ?  1'b1 : 1'b0;
//	wire io_read_valid = (io_address_valid && read_address) ?  1'b1 : 1'b0;
//	wire ddr_read_valid = (ddr_address_valid && read_address) ?  1'b1 : 1'b0;
//	wire mux_read_valid = (mux_address_valid && read_address) ?  1'b1 : 1'b0;
//	wire od_read_valid = (od_address_valid && read_address) ?  1'b1 : 1'b0;

	wire adc_write_valid = (adc_address_valid && write_address) ?  1'b1 : 1'b0;
//	wire io_write_valid = (io_address_valid && write_address) ?  1'b1 : 1'b0;
//	wire ddr_write_valid = (ddr_address_valid && write_address) ?  1'b1 : 1'b0;
//	wire mux_write_valid = (mux_address_valid && write_address) ?  1'b1 : 1'b0;
//	wire od_write_valid = (od_address_valid && write_address) ?  1'b1 : 1'b0;

// ADC module:
	wire [31:0]adc_data_out;


adc_ltc2308_fifo adc_ltc2308_fifo_inst
(
	.clock(CLOCK) ,	// input  clock_sig
	.reset_n(reset_reg_N) ,	// input  reset_n_sig
	.addr(busaddress_r[2]) ,	// input  addr_sig
	.read(adc_read_valid) ,	// input  read_sig
	.reg_outdata(read_adc_out) ,	// input  read_sig
	.write(adc_write_valid) ,	// input  write_sig
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
			read_reg_r			<= 0;
			write_reg_r			<= 0;
			busaddress_r		<= 0;
			busdata_in_r		<= 0;
			iodatafromhm3_r	<= '{NumGPIO{~0}};
			busdata_fromhm2_r	<= 0;
		end else begin
			reset_in_r							<= reset_in;
			read_reg_r[ReadInShift:1]		<= read_reg_r[ReadInShift-1:0];
			read_reg_r[0]						<= read_reg;
			write_address 						<= write_reg_r[WriteInShift-1];
			write_reg_r[WriteInShift:1]	<= write_reg_r[WriteInShift-1:0];
			write_reg_r[0]						<= write_reg;
			busaddress_r						<= {{busaddress[AddrWidth-1:2]},{2'b0}};
			busdata_in_r						<= busdata_in;
			iodatafromhm3_r					<= iodatafromhm3;
			busdata_fromhm2_r					<= busdata_fromhm2;
			local_address_r					<= busaddress;
		end
	end

//	genvar numio, numgio;
	generate
		if (NumGPIO >= 1) begin
			assign io_reg_gpio[0] = {io_reg[1][11:0],io_reg[0][23:0]};
			assign out_ena[0] = {ddr_reg[1][11:0],ddr_reg[0][23:0]};
			assign od[0] = {od_reg[1][11:0],od_reg[0][23:0]};
		end
		if (NumGPIO >= 2) begin
			assign io_reg_gpio[1] = {io_reg[2][23:0],io_reg[1][23:12]};
			assign out_ena[1] = {ddr_reg[2][23:0],ddr_reg[1][23:12]};
			assign od[1] = {od_reg[2][23:0],od_reg[1][23:12]};
		end
		if (NumGPIO >= 3) begin
			assign io_reg_gpio[2] = {io_reg[4][11:0],io_reg[3][23:0]};
			assign out_ena[2] = {ddr_reg[4][11:0],ddr_reg[3][23:0]};
			assign od[2] = {od_reg[4][11:0],od_reg[3][23:0]};
		end
		if (NumGPIO == 4) begin
			assign io_reg_gpio[3] = {io_reg[5][23:0],io_reg[4][23:12]};
			assign out_ena[3] = {ddr_reg[5][23:0],ddr_reg[4][23:12]};
			assign od[3] = {od_reg[5][23:0],od_reg[4][23:12]};
		end

//		for(numgio=0;numio<NumGPIO;numgio++)begin : gioloop
////			for(numio=0;numio<GPIOWidth;numio++)begin : gportloop
////				assign gpioport[numgio][numio] = out_ena[numgio][numio] ? io_reg_gpio[numgio][numio] : 1'bz;
//			assign gpioport[numgio] = out_ena[numgio] ? io_reg_gpio[numgio] : '{NumGPIO{1'bz}};
//			assign io_data_in[numgio] = gpioport[numgio];
////			end
//		end
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
//	genvar il, pl, ili;
//	generate
//		for(il=0;il<NumIOAddrReg;il=il+1) begin : reg_initloop
//		for(pl=0;pl<NumPinsPrIOAddr;pl=pl+1) begin : initpnumloop
//			always @(posedge reset_in_r or posedge io_write_valid or posedge ddr_write_valid or posedge od_write_valid or posedge write_address)begin

			always @( posedge reset_in_r or posedge write_address) begin
				if (reset_in_r) begin
					io_reg[0] <= 0; ddr_reg[0] <= 0; od_reg[0] <= 0;
					io_reg[1] <= 0; ddr_reg[1] <= 0; od_reg[1] <= 0;
					io_reg[2] <= 0; ddr_reg[2] <= 0; od_reg[2] <= 0;
					io_reg[3] <= 0; ddr_reg[3] <= 0; od_reg[3] <= 0;
					io_reg[4] <= 0; ddr_reg[4] <= 0; od_reg[4] <= 0;
					io_reg[5] <= 0; ddr_reg[5] <= 0; od_reg[5] <= 0;
				end
//					if(pl == 0) begin io_reg[l] <= 0; ddr_reg[l] <= 0; od_reg[l] <= 0; end
//					mux_reg[l][pl] <= (((l*16) + (pl*4)) + (((l*16)+((pl*4)+1)) << PortNumWidth) +
//					(((l*16)+((pl*4)+2)) << (PortNumWidth * 2)) + (((l*16)+((pl*4)+3)) << (PortNumWidth * 3)));
//				end
				else if ( write_address ) begin
					if (busaddress_r == 16'h1000) begin io_reg[0] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (busaddress_r == 16'h1004) begin io_reg[1] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (busaddress_r == 16'h1008) begin io_reg[2] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (busaddress_r == 16'h100c) begin io_reg[3] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (busaddress_r == 16'h1010) begin io_reg[4] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (busaddress_r == 16'h1014) begin io_reg[5] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1100) begin ddr_reg[0] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1104) begin ddr_reg[1] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1108) begin ddr_reg[2] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h110c) begin ddr_reg[3] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1110) begin ddr_reg[4] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1114) begin ddr_reg[5] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1300) begin od_reg[0] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1304) begin od_reg[1] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1308) begin od_reg[2] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h130c) begin od_reg[3] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1310) begin od_reg[4] <= busdata_in_r[IoRegWidth-1:0]; end
					else if (busaddress_r == 16'h1314) begin od_reg[5] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (ddr_write_valid) begin ddr_reg[local_address_r[2:0]][IoRegWidth-1:0] <= busdata_in_r[IoRegWidth-1:0]; end
//					else if (od_write_valid) begin od_reg[local_address_r[2:0]][IoRegWidth-1:0] <= busdata_in_r[IoRegWidth-1:0]; end
//						else if (mux_address_valid) begin mux_reg[mux_reg_addr][mux_reg_byte] <= busdata_in_r; end
//					else begin iodatatohm3 <= busdata_in_r; end
				end
			end
//		end

	genvar bloop;
	generate
		for(bloop=0;bloop<NumGPIO;bloop=bloop+1) begin : gpiooutloop
			bidir_io #(.IOWidth(GPIOWidth),.PortNumWidth(PortNumWidth)) bidir_io_inst
			(
				.clk(reg_clk),
//				.portselnum(portnumsel[il]),
				.out_ena(out_ena[bloop]) ,	// input  out_ena_sig
//				.od(od[il]) ,	// input  od_sig
				.out_data(iodatafromhm3[bloop]) ,  // input [IOIOWidth-1:0] out_data_sig
				.gpioport(gpioport[bloop]) ,	// inout [IOIOWidth-1:0] gpioport_sig
				.gpio_in_data(gpio_input_data[bloop]) 	// output [IOIOWidth-1:0] read_data_sig
			);
//			defparam bidir_io_inst[il].IOWidth = GPIOWidth;
//			defparam bidir_io_inst[il].PortNumWidth = PortNumWidth;
		end
	endgenerate


	// Read:

	always @(posedge reset_in_r or posedge read_address)begin
		if (reset_in_r)begin
//			busdata_to_cpu <= ~ 'bz;
			busdata_to_cpu <= 32'b0;
		end
		else if (read_address) begin
//			if (adc_address_valid) begin busdata_to_cpu <= adc_data_out;	end
			if ((busaddress_r == 'h0300) || (busaddress_r == 'h0304)) begin busdata_to_cpu <= adc_data_out;	end
			else if(busaddress_r == 'h1000) begin busdata_to_cpu <= {8'b0,gpio_input_data[0][23:0]}; end
			else if(busaddress_r == 'h1004) begin busdata_to_cpu <= {8'b0,gpio_input_data[1][11:0],gpio_input_data[0][35:24]}; end
			else if(busaddress_r == 'h1008) begin busdata_to_cpu <= {8'b0,gpio_input_data[1][35:12]}; end
//			else if(busaddress_r == 'h100c) begin busdata_to_cpu <= {8'b0,gpio_input_data[2][23:0]}; end
//			else if(busaddress_r == 'h1010) begin busdata_to_cpu <= {8'b0,gpio_input_data[3][11:0],gpio_input_data[2][35:24]}; end
//			else if(busaddress_r == 'h1014) begin busdata_to_cpu <= {8'b0,gpio_input_data[3][35:12]}; end
			else if (busaddress_r == 'h1100) begin busdata_to_cpu <= ddr_reg[0]; end
			else if (busaddress_r == 'h1104) begin busdata_to_cpu <= ddr_reg[1]; end
			else if (busaddress_r == 'h1108) begin busdata_to_cpu <= ddr_reg[2]; end
			else if (busaddress_r == 'h110c) begin busdata_to_cpu <= ddr_reg[3]; end
			else if (busaddress_r == 'h1110) begin busdata_to_cpu <= ddr_reg[4]; end
			else if (busaddress_r == 'h1114) begin busdata_to_cpu <= ddr_reg[5]; end
//		else if (mux_read_valid) begin busdata_to_cpu <= mux_reg[mux_reg_addr][mux_reg_byte]; end
			else if (busaddress_r == 'h1300) begin busdata_to_cpu <= od_reg[0]; end
			else if (busaddress_r == 'h1304) begin busdata_to_cpu <= od_reg[0]; end
			else if (busaddress_r == 'h1308) begin busdata_to_cpu <= od_reg[0]; end
			else if (busaddress_r == 'h130c) begin busdata_to_cpu <= od_reg[0]; end
			else if (busaddress_r == 'h1310) begin busdata_to_cpu <= od_reg[0]; end
			else if (busaddress_r == 'h1314) begin busdata_to_cpu <= od_reg[0]; end
			else begin busdata_to_cpu <= busdata_fromhm2; end
		end
	end

endmodule

