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
	input	[MuxLedWidth-1:0]							leds_sig,
	input	[AddrWidth-3:0]							busaddress,
	input	[BusWidth-1:0]								busdata_in,
	input	[MuxGPIOIOWidth-1:0]						iodatafromhm3,
//
	inout	[GPIOWidth-1:0]							ioport,
	output reg [MuxGPIOIOWidth-1:0]				iodatatohm3
//	output 	reg	[BusWidth-1:0]			busdata_out
);

parameter AddrWidth     	= 16;
parameter BusWidth			= 32;
parameter GPIOWidth			= 36;
parameter MuxGPIOIOWidth	= 34;
parameter NumIOReg			= 6;
parameter MuxLedWidth 		= 2;

	wire reset_reg = ~reset_reg_N;
	wire [GPIOWidth-1:0] io_read_data;

	reg [1:0] write_r;
//	reg [1:0]read_r;
	reg [AddrWidth-1:0]			busaddr;
	reg [23:0]						busdata_in_reg;
	reg [23:0]						ddr_reg[NumIOReg-1:0];
	reg [23:0]						odrain_reg[NumIOReg-1:0];
	reg [MuxLedWidth-1:0]		leds_r;
	reg [MuxGPIOIOWidth-1:0]	iodatafromhm3_r;

	reg [6:0] portselnum[GPIOWidth-1:0];
	
	wire [GPIOWidth-1:0]	oe;
	wire [GPIOWidth-1:0]	od;

	assign oe = {2'b11,ddr_reg[1][9:0],ddr_reg[0]};
	assign od = {2'b0,odrain_reg[1][9:0],odrain_reg[0]};

//	reg syx_data_rdy_r[3:0];

//	wire [MuxGPIOIOWidth-1:0] tohm2data;

	genvar k;
	generate for(k=0;k<GPIOWidth;k=k+1) begin : initloop
		always @(posedge reg_clk) begin
			portselnum[k] <= k;
		end
	end
	endgenerate

	always @(posedge reg_clk or posedge reset_reg)begin
		if (reset_reg)begin
			busaddr <= 0;
			busdata_in_reg <= 0;
			leds_r <= 0;
			iodatafromhm3_r <= 0;
			write_r <= 0;
//			read_r <= 'b0;
//			iodatatohm3 <= 0;			
		end
		else begin
			busaddr <= {busaddress,2'b0};
			busdata_in_reg <= busdata_in[23:0];
			write_r[0] <= write_reg;
			write_r[1] <= write_r[0];
			leds_r <= leds_sig;
			iodatafromhm3_r <= iodatafromhm3;
			iodatatohm3 <= io_read_data[GPIOWidth-MuxLedWidth-1:0];
//			read_r[0] <= read_reg;
//			read_r[1] <= read_r[0];
//			iodatatohm3 <= tohm2data;
		end
	end
	
	always @(posedge reset_reg or posedge write_r[1])begin
		if (reset_reg)begin
			ddr_reg[0] <= 0; ddr_reg[1] <= 0; ddr_reg[2] <= 0;
			ddr_reg[3] <= 0; ddr_reg[4] <= 0; ddr_reg[5] <= 0;
			odrain_reg[0] <= 0; odrain_reg[1] <= 0; odrain_reg[2] <= 0;
			odrain_reg[3] <= 0; odrain_reg[4] <= 0; odrain_reg[5] <= 0;
		end
		else begin
			case (busaddr)
				14'h1100 : begin ddr_reg[0] <= busdata_in_reg; end
				14'h1104 : begin ddr_reg[1] <= busdata_in_reg; end
				14'h1108 : begin ddr_reg[2] <= busdata_in_reg; end
				14'h110C : begin ddr_reg[3] <= busdata_in_reg; end
				14'h1110 : begin ddr_reg[4] <= busdata_in_reg; end
				14'h1114 : begin ddr_reg[5] <= busdata_in_reg; end
				14'h1300 : begin odrain_reg[0] <= busdata_in_reg; end
				14'h1304 : begin odrain_reg[1] <= busdata_in_reg; end
				14'h1308 : begin odrain_reg[2] <= busdata_in_reg; end
				14'h130C : begin odrain_reg[3] <= busdata_in_reg; end
				14'h1310 : begin odrain_reg[4] <= busdata_in_reg; end
				14'h1314 : begin odrain_reg[5] <= busdata_in_reg; end
			endcase
		end
	end

bidir_io bidir_io_inst
(
	.portselnum(portselnum),
	.oe(oe) ,	// input  oe_sig
	.od(od) ,	// input  od_sig
	.out_data({leds_r,iodatafromhm3_r}) ,	// input [IOIOWidth-1:0] out_data_sig
	.ioport(ioport) ,	// inout [IOIOWidth-1:0] ioport_sig
	.read_data(io_read_data) 	// output [IOIOWidth-1:0] read_data_sig
);

defparam bidir_io_inst.IOWidth = GPIOWidth;

//	always @(posedge reset_reg or posedge read_r[1] or posedge CLOCK)begin
//		if (reset_reg)begin
//				busdata_out <= ~ 'bZ;
//			end
//		else if (read_r[1]) begin
//			case (busaddress_reg)
//				14'h1100 : begin busdata_out <= ddr_reg[0]; end
//				14'h1104 : begin busdata_out <= ddr_reg[1]; end
//				14'h1108 : begin busdata_out <= ddr_reg[2]; end
//				14'h110C : begin busdata_out <= ddr_reg[3]; end
//				14'h1110 : begin busdata_out <= ddr_reg[4]; end
//				14'h1114 : begin busdata_out <= ddr_reg[5]; end
//				14'h1300 : begin busdata_out <= odrain_reg[0]; end
//				14'h1304 : begin busdata_out <= odrain_reg[1]; end
//				14'h1308 : begin busdata_out <= odrain_reg[2]; end
//				14'h130C : begin busdata_out <= odrain_reg[3]; end
//				14'h1310 : begin busdata_out <= odrain_reg[4]; end
//				14'h1314 : begin busdata_out <= odrain_reg[5]; end
//				default : begin busdata_out <= 'bz; end
//			endcase
//		end
//		else if (CLOCK) begin
//			busdata_out <= 'bz;
//		end
//	end
endmodule

