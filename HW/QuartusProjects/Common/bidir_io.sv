module bidir_io 
#(parameter IOWidth=36)
(input [IOWidth-1:0] oe, input [IOWidth-1:0] od, input [IOWidth-1:0] out_data, inout [IOWidth-1:0] ioport, output [IOWidth-1:0] read_data);

	wire [IOWidth-1:0] od_data;
	// If we are using the bidir as an output and opendrain is 0, assign it an output value,
	// otherwise assign it high-impedence
	genvar i;
	generate for(i = 0; i < IOWidth; i = i + 1) begin : ioloop
		assign od_data[i] = (od[i] ? ((out_data[i] == 1'b1) ? 1'b0 : 1'bz) :  out_data[i]);
		assign ioport[i] = (oe[i] ? od_data[i] : 1'bz);
	end
	endgenerate


	// Read in the current value of the bidir port, which comes either
	// from the input or from the previous assignment.
	assign read_data = ioport;

endmodule
