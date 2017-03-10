
interface uio_bus   #(parameter AddrWidth = 15, parameter BusWidth = 32)
                                (input logic clkhigh, clkmed, clklow, clkadc, irq, resetN);
    logic    [AddrWidth-1:0]    address;
    logic    [BusWidth-1:0]     busdatain;
    logic    [BusWidth-1:0]     busdataout;
    logic                                 write;
    logic                                 read;
    logic    [3:0]                      cs;
endinterface : uio_bus

interface spi_bus;
    logic                                 cs_n;
    logic                                 mosi;
    logic                                 miso;
    logic                                 sclk;
endinterface : spi_bus

