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
	input										CLOCK,
	input										reset_reg_N,
	input										data_ready,
	input	[AddrWidth-1:0]				address,
	input	[BusWidth-1:0]					data_in,

	output 	reg							read_write ,
	output 	reg							write_dataenable,
	output 	reg	[NumReg-1:0]      gpio_sel,
	output 	reg	[GPIOWidth-1:0]	gpio_io_reg[NumReg-1:0]
);

parameter AddrWidth     = 14;
parameter BusWidth		= 32;
parameter GPIOWidth 		= 36;
parameter NumReg			= 6;

	wire reset_reg = ~reset_reg_N;
	reg syx_data_rdy_r[3:0];
	reg [AddrWidth-1:0] address_reg;
	reg [BusWidth-1:0] data_in_reg;


	always @(posedge CLOCK or posedge reset_reg)begin
		if (reset_reg)begin
			address_reg <= 0;
			data_in_reg <= 0;
		end
		else begin
			address_reg <= address;
			data_in_reg <= data_in;
			syx_data_rdy_r[0] <= data_ready;
			syx_data_rdy_r[1] <= syx_data_rdy_r[0];
			syx_data_rdy_r[2] <= syx_data_rdy_r[1];
			syx_data_rdy_r[3] <= syx_data_rdy_r[2];
			read_write  <= syx_data_rdy_r[2];
			write_dataenable  <= syx_data_rdy_r[3] || syx_data_rdy_r[2];
		end
	end
	
	always @(posedge reset_reg or posedge syx_data_rdy_r[1])begin
		if (reset_reg)begin
				gpio_sel <= 0;
		end
		else begin
			case (address_reg)
				14'h1100 : begin gpio_sel[0] <= 1'b1; gpio_sel[5:1] <= 5'b0; end
				14'h1104 : begin gpio_sel[1] <= 1'b1;{gpio_sel[5:2],gpio_sel[0]} <= 0; end
				14'h1108 : begin gpio_sel[2] <= 1'b1;{gpio_sel[5:3],gpio_sel[1:0]} <= 5'b0; end
				14'h110C : begin gpio_sel[3] <= 1'b1;{gpio_sel[5:4],gpio_sel[2:0]} <= 5'b0; end
				14'h1110 : begin gpio_sel[4] <= 1'b1;{gpio_sel[5],gpio_sel[3:0]} <= 5'b0; end
				14'h1114 : begin gpio_sel[5] <= 1'b1; gpio_sel[4:0] <= 5'b0; end
				default: begin gpio_sel <= 6'b0; end
			endcase
		end
	end

	always@(negedge write_dataenable)begin
		case(gpio_sel)
				6'b000001 : begin gpio_io_reg[0] <= data_in_reg; end
				6'b000010 : begin gpio_io_reg[1] <= data_in_reg; end
				6'b000100 : begin gpio_io_reg[2] <= data_in_reg; end
				6'b001000 : begin gpio_io_reg[3] <= data_in_reg; end
				6'b010000 : begin gpio_io_reg[4] <= data_in_reg; end
				6'b100000 : begin gpio_io_reg[5] <= data_in_reg; end
			default: begin
				gpio_io_reg[0] <= 0; gpio_io_reg[1] <= 0; gpio_io_reg[2] <= 0;
				gpio_io_reg[3] <= 0; gpio_io_reg[4] <= 0; gpio_io_reg[5] <= 0;
			end
		endcase

	end

endmodule

