module bidir_io 
#(parameter IOWidth=36, parameter PortNumWidth=8)
(
	input [PortNumWidth-1:0] portselnum [IOWidth-1:0],
	input [IOWidth-1:0] oe,
	input [IOWidth-1:0] od,
	input [IOWidth-1:0] out_data,
	inout [IOWidth-1:0] ioport,
	output [IOWidth-1:0] read_data
);

	wire [IOWidth-1:0] od_data;
	wire [IOWidth-1:0] muxindata;
	wire [IOWidth-1:0] muxdata [IOWidth-1:0];
	reg  [IOWidth-1:0] muxoutdata;

	// If we are using the bidir as an output and opendrain is 0, assign it an output value,
	// otherwise assign it high-impedence
	genvar i;
	generate for(i = 0; i < IOWidth; i = i + 1) begin : ioloop
		assign od_data[i] = (od[i] ? ((out_data[i] == 1'b1) ? 1'b0 : 1'bz) :  out_data[i]);
		assign muxindata[i] = (oe[i] ? od_data[i] : 1'bz);
		assign ioport[i] = muxoutdata[i];
	end
	endgenerate


	// Read in the current value of the bidir port, which comes either
	// from the input or from the previous assignment.
	assign read_data = ioport;


	genvar j;
	generate for (j=0;j<IOWidth;j=j+1) begin : dataloop
		assign muxdata[j] = muxindata[j] ? {IOWidth{1'b1}} : 0;
		assign muxoutdata[j] = muxdata[portselnum[j]];
	end
	endgenerate

endmodule
