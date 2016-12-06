module bidir_io
#(parameter IOWidth=36, parameter PortNumWidth=8)
(
//	input [PortNumWidth-1:0] portselnum [IOWidth-1:0],
	input		clk,
	input 	[IOWidth-1:0] out_ena,
	input 	[IOWidth-1:0] od,
	input 	[IOWidth-1:0] out_data,
	inout 	[IOWidth-1:0] gpioport,
	output	[IOWidth-1:0] gpio_in_data
);

reg  [IOWidth-1:0] io_data_in;
reg  [IOWidth-1:0] out_data_reg;

genvar loop;
generate
	for(loop=0;loop<IOWidth;loop=loop+1) begin : iogenloop
		assign od_data[loop] = (od[loop] ? ((out_data[loop] == 1'b1) ? 1'b0 : 1'bz) : out_data[loop]);
		assign gpioport[loop]  = out_ena[loop] ? od_data[loop] : 1'bZ;
		assign gpio_in_data[loop]  = io_data_in[loop];

		always @ (posedge clk)
		begin
			io_data_in[loop] <= gpioport[loop];
			out_data_reg[loop] <= out_data[loop];
		end
	end
endgenerate


	wire [IOWidth-1:0] od_data;
//	wire [IOWidth-1:0] muxindata;
//	wire [IOWidth-1:0] muxdata [IOWidth-1:0];
//	reg  [IOWidth-1:0] muxoutdata;
//	reg  [IOWidth-1:0] io_data_in
//
//	// If we are using the bidir as an output and opendrain is 0, assign it an output value,
//	// otherwise assign it high-impedence
//	genvar i;
//	generate for(i = 0; i < IOWidth; i = i + 1) begin : ioloop
//		assign od_data[i] = (od[i] ? ((out_data[i] == 1'b1) ? 1'b0 : 1'bz) :  out_data[i]);
//		assign muxindata[i] = (out_ena[i] ? od_data[i] : 1'bz);
//		assign gpioport[i] = muxoutdata[i];
//	end
//	endgenerate
//
//	genvar j;
//	generate for (j=0;j<IOWidth;j=j+1) begin : dataloop
//		assign muxdata[j] = muxindata[j] ? {IOWidth{1'b1}} : 0;
//		assign muxoutdata[j] = muxdata[portselnum[j]];
//	end
//	endgenerate
//
//
//	// Read in the current value of the bidir port, which comes either
//	// from the input or from the previous assignment.
//	assign gpio_in_data = gpioport;
//

endmodule
