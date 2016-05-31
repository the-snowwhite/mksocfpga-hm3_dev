module bidir_io 
#(parameter IOWidth=36)
(input oe, input [IOWidth-1:0] out_data, inout [IOWidth-1:0] ioport, output [IOWidth-1:0] read_data);

	// If we are using the bidir as an output, assign it an output value, 
	// otherwise assign it high-impedence
	assign ioport = (oe ? out_data : {IOWidth{1'bz}});

	// Read in the current value of the bidir port, which comes either
	// from the input or from the previous assignment.
	assign read_data = ioport;

endmodule
