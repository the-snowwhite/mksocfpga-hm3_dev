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
	input											CLOCK,
	input											reset_reg_N,
	input											write_reg,
//	input											read_reg,
	input	[AddrWidth-3:0]					busaddress,
	input	[BusWidth-1:0]						busdata_in,
//	input	[MuxGPIOIOWidth-1:0]				iodatafromhm3,
//
	output	[MuxGPIOIOWidth-1:0]			oe
// 	output 	reg								write_dataenable,
//	output 	reg	[NumIOReg-1:0]			gpio_sel,
//	output	[MuxGPIOIOWidth-1:0]			iodatatohm3
//	output 	reg	[BusWidth-1:0]			busdata_out
);

parameter AddrWidth     	= 14;
parameter BusWidth			= 32;
parameter MuxGPIOIOWidth	= 34;
parameter NumIOReg			= 6;

	wire reset_reg = ~reset_reg_N;
	reg [AddrWidth-1:0] busaddr;
	reg [23:0] busdata_in_reg;
	reg [23:0]	ddr_reg[NumIOReg-1:0];
	
	assign oe = {ddr_reg[1][9:0],ddr_reg[0]};

//	assign busaddr = {busaddress,2'b0};
//	reg syx_data_rdy_r[3:0];
	reg [1:0] write_r;
//	reg [1:0]read_r;
//	reg [BusWidth-1:0]	ddr_reg[NumIOReg-1:0];
//	reg [BusWidth-1:0]	odrain_reg[NumIOReg-1:0];

//	wire [MuxGPIOIOWidth-1:0]	oe_sig;
//	wire [MuxGPIOIOWidth-1:0]	od_sig;
//	tri [MuxGPIOIOWidth-1:0]	iodatafromhm3_sig;
//
//	wire [23:0] oe_sig_24 [NumIOReg-1:0];
//	wire [23:0] od_sig_24 [NumIOReg-1:0];
//
////	wire [MuxGPIOIOWidth-1:0] iodata;
//	wire [MuxGPIOIOWidth-1:0] oddata;

//	wire [MuxGPIOIOWidth-1:0] tohm2data;
	
//	assign oe_sig_24[23:0] = ddr_reg[23:0];
////	assign od_sig_24[23:0] = odrain_reg[23:0];
//
//	assign oe_sig = {oe_sig_24[1][9:0],oe_sig_24[0]};
//	assign od_sig = {od_sig_24[1][9:0],od_sig_24[0]};


//	genvar i;
//	generate for(i = 0; i<MuxGPIOIOWidth-1; i = i+1)
//		begin : gen_opendrains
//			assign oddata[i] = (iodatafromhm3[i] == 1'b1) ? 1'bz :  1'b0;
//			assign iodata[i] = od_sig[i] ? oddata[i] : iodatafromhm3[i];
////			assign iodata[i] = oe_sig[i] ? iodatafromhm3[i] : 1'bz;
////			assign dataio[i] = od_sig[i] ? oddata[i] : iodata[i];
//		end
//	endgenerate


//
//gpio_buf	gpio_buf_inst (
//	.datain ( iodatafromhm3 ),
//	.oe ( oe_sig ),
//	.dataio ( dataio ),
//	.dataout ( iodatatohm3 )
//	);
//
//	genvar j;
//	generate 
//		for(j = 0; j<MuxGPIOIOWidth; j = j+1) begin : gen_input
//			assign tohm2data[j] = oe_sig[j] ? 1'b0 : dataio[j];
//		end
//	endgenerate

	always @(posedge CLOCK or posedge reset_reg)begin
		if (reset_reg)begin
			busaddr <= 0;
			busdata_in_reg <= 0;
//			iodatatohm3 <= 0;
			write_r <= 0;
//			read_r <= 'b0;
//			iodatatohm3 <= 0;
		end
		else begin
			busaddr <= {busaddress,2'b0};
			busdata_in_reg <= busdata_in[23:0];
			write_r[0] <= write_reg;
			write_r[1] <= write_r[0];
//			read_r[0] <= read_reg;
//			read_r[1] <= read_r[0];
//			iodatatohm3 <= tohm2data;
		end
	end
	
	always @(posedge reset_reg or posedge write_r[1])begin
		if (reset_reg)begin
			ddr_reg[0] <= 0; ddr_reg[1] <= 0; ddr_reg[2] <= 0;
			ddr_reg[3] <= 0; ddr_reg[4] <= 0; ddr_reg[5] <= 0;
		end
		else begin
			case (busaddr)
				14'h1100 : begin ddr_reg[0] <= busdata_in_reg; end
				14'h1104 : begin ddr_reg[1] <= busdata_in_reg; end
				14'h1108 : begin ddr_reg[2] <= busdata_in_reg; end
				14'h110C : begin ddr_reg[3] <= busdata_in_reg; end
				14'h1110 : begin ddr_reg[4] <= busdata_in_reg; end
				14'h1114 : begin ddr_reg[5] <= busdata_in_reg; end
//				14'h1300 : begin odrain_reg[0] <= busdata_in; end
//				14'h1304 : begin odrain_reg[1] <= busdata_in; end
//				14'h1308 : begin odrain_reg[2] <= busdata_in; end
//				14'h130C : begin odrain_reg[3] <= busdata_in; end
//				14'h1310 : begin odrain_reg[4] <= busdata_in; end
//				14'h1314 : begin odrain_reg[5] <= busdata_in; end
			endcase
		end
	end

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

