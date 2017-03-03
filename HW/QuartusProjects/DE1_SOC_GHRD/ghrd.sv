// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================

`define ENABLE_HPS

module ghrd(


      ///////// ADC /////////
//      inout              ADC_CS_N,
      output             ADC_CS_N,
      output             ADC_DIN,
      input               ADC_DOUT,
      output             ADC_SCLK,

      ///////// AUD /////////
      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output           AUD_DACDAT,
      inout              AUD_DACLRCK,
      output           AUD_XCK,

      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      input              CLOCK4_50,

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// DRAM /////////
      output      [12:0] DRAM_ADDR,
      output      [1:0]  DRAM_BA,
      output             DRAM_CAS_N,
      output             DRAM_CKE,
      output             DRAM_CLK,
      output             DRAM_CS_N,
      inout       [15:0] DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_RAS_N,
      output             DRAM_UDQM,
      output             DRAM_WE_N,

      ///////// FAN /////////
      output             FAN_CTRL,

      ///////// FPGA /////////
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,

      ///////// GPIO /////////
//      inout     [35:0]         GPIO_0,
//      inout     [35:0]         GPIO_1,
      inout       [35:0] GPIO[1:0],


      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,

      ///////// HEX2 /////////
      output      [6:0]  HEX2,

      ///////// HEX3 /////////
      output      [6:0]  HEX3,

      ///////// HEX4 /////////
      output      [6:0]  HEX4,

      ///////// HEX5 /////////
      output      [6:0]  HEX5,

`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

      ///////// IRDA /////////
      input              IRDA_RXD,
      output             IRDA_TXD,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// PS2 /////////
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// TD /////////
      input              TD_CLK27,
      input      [7:0]  TD_DATA,
      input             TD_HS,
      output             TD_RESET_N,
      input             TD_VS,


      ///////// VGA /////////
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
import boardtype::*;
parameter NumIOAddrReg = 6;

// touchsense
parameter num_segs = 6;

wire [3:0] seg_num[num_segs];
wire [6:0] seg_data[num_segs];

wire [3:0]touched;

wire [11:0] calibval_0;
wire [13:0] counts_0;

assign seg_num[0] = calibval_0[3:0];
assign seg_num[1] = calibval_0[7:4];
assign seg_num[2] = calibval_0[11:9];
assign seg_num[3] = counts_0[3:0];
assign seg_num[4] = counts_0[7:4];
assign seg_num[5] = counts_0[11:9];

//assign HEX0  = ~0;
assign HEX0  = seg_data[0];
assign HEX1  = seg_data[1];
assign HEX2  = seg_data[2];
assign HEX3  = seg_data[3];
assign HEX4  = seg_data[4];
assign HEX5  = seg_data[5];

assign LEDR[9:8]		= touched[1:0];

genvar i;
generate
	for(i=0;i<num_segs;i=i+1) begin : segloop
		hexto7segment hexto7segment_inst
		(
			.x(seg_num[i]) ,	// input [3:0] x_sig
			.z(seg_data[i]) 	// output [6:0] z_sig
		);
	end
endgenerate	


// ----------------------------- //


wire  hps_fpga_reset_n;
  wire [3:0] fpga_debounced_buttons;
  wire [6:0]  fpga_led_internal;
  wire [2:0]  hps_reset_req;
  wire        hps_cold_reset;
  wire        hps_warm_reset;
  wire        hps_debug_reset;
  wire [27:0] stm_hw_events;

  wire fpga_clk_50;
  assign fpga_clk_50 = CLOCK2_50;

// connection of internal logics
  assign LEDR[5:1] = fpga_led_internal;
  assign stm_hw_events    = {{4{1'b0}}, SW, fpga_led_internal, fpga_debounced_buttons};

// hm2
	wire [AddrWidth-3:0]	hm_address;
	wire [31:0] 			hm_datao;
	wire [31:0] 			hm_datai;
	wire [31:0] 			busdata_out;
	wire       				hm_read;
	wire 						hm_write;
	wire [3:0]				hm_chipsel;
	wire						hm_clk_med;
	wire						hm_clk_high;
	wire						adc_clk_40;
	wire 						clklow_sig;
	wire 						clkmed_sig;
	wire 						clkhigh_sig;

// Mesa I/O Signals:
	wire [LEDCount-1:0]			hm2_leds_sig;
	wire [IOWidth-1:0]			hm2_bitsout_sig;
	wire [IOWidth-1:0]			hm2_bitsin_sig;

	wire [MuxLedWidth-1:0]		io_leds_sig[NumGPIO-1:0];
	wire [MuxGPIOIOWidth-1:0] 	io_bitsout_sig[NumGPIO-1:0];
	wire [MuxGPIOIOWidth-1:0] 	io_bitsin_sig[NumGPIO-1:0];

	//irq:
	wire int_sig;

//=======================================================
//  Structural coding
//=======================================================
soc_system u0 (
	.clk_clk                               (CLOCK_50),                             //                clk.clk
	.reset_reset_n                         (1'b1),                                 //                reset.reset_n
	//HPS ddr3
	.memory_mem_a                          ( HPS_DDR3_ADDR),                       //                memory.mem_a
	.memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
	.memory_mem_ck                         ( HPS_DDR3_CK_P),                       //                .mem_ck
	.memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
	.memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
	.memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
	.memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
	.memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
	.memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
	.memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
	.memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
	.memory_mem_dqs                        ( HPS_DDR3_DQS_P),                      //                .mem_dqs
	.memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
	.memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
	.memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
	.memory_oct_rzqin                      ( HPS_DDR3_RZQ),                        //                .oct_rzqin
	//HPS ethernet
	.hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK),       //                             hps_0_hps_io.hps_io_emac1_inst_TX_CLK
	.hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //                             .hps_io_emac1_inst_TXD0
	.hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //                             .hps_io_emac1_inst_TXD1
	.hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //                             .hps_io_emac1_inst_TXD2
	.hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //                             .hps_io_emac1_inst_TXD3
	.hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //                             .hps_io_emac1_inst_RXD0
	.hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),         //                             .hps_io_emac1_inst_MDIO
	.hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC  ),         //                             .hps_io_emac1_inst_MDC
	.hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV),         //                             .hps_io_emac1_inst_RX_CTL
	.hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN),         //                             .hps_io_emac1_inst_TX_CTL
	.hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK),        //                             .hps_io_emac1_inst_RX_CLK
	.hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //                             .hps_io_emac1_inst_RXD1
	.hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //                             .hps_io_emac1_inst_RXD2
	.hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //                             .hps_io_emac1_inst_RXD3
	//HPS QSPI
	.hps_0_hps_io_hps_io_qspi_inst_IO0     ( HPS_FLASH_DATA[0]    ),     //                               .hps_io_qspi_inst_IO0
	.hps_0_hps_io_hps_io_qspi_inst_IO1     ( HPS_FLASH_DATA[1]    ),     //                               .hps_io_qspi_inst_IO1
	.hps_0_hps_io_hps_io_qspi_inst_IO2     ( HPS_FLASH_DATA[2]    ),     //                               .hps_io_qspi_inst_IO2
	.hps_0_hps_io_hps_io_qspi_inst_IO3     ( HPS_FLASH_DATA[3]    ),     //                               .hps_io_qspi_inst_IO3
	.hps_0_hps_io_hps_io_qspi_inst_SS0     ( HPS_FLASH_NCSO    ),        //                               .hps_io_qspi_inst_SS0
	.hps_0_hps_io_hps_io_qspi_inst_CLK     ( HPS_FLASH_DCLK    ),        //                               .hps_io_qspi_inst_CLK
	//HPS SD card
	.hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD    ),           //                               .hps_io_sdio_inst_CMD
	.hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
	.hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
	.hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK   ),            //                               .hps_io_sdio_inst_CLK
	.hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
	.hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
	//HPS USB
	.hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
	.hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
	.hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
	.hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
	.hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
	.hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
	.hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
	.hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
	.hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT    ),       //                               .hps_io_usb1_inst_CLK
	.hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP    ),          //                               .hps_io_usb1_inst_STP
	.hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR    ),          //                               .hps_io_usb1_inst_DIR
	.hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT    ),          //                               .hps_io_usb1_inst_NXT
	//HPS SPI
	.hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),           //                               .hps_io_spim1_inst_CLK
	.hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),           //                               .hps_io_spim1_inst_MOSI
	.hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),           //                               .hps_io_spim1_inst_MISO
	.hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS ),             //                               .hps_io_spim1_inst_SS0
	//HPS UART
	.hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX    ),          //                               .hps_io_uart0_inst_RX
	.hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX    ),          //                               .hps_io_uart0_inst_TX
	//HPS I2C1
	.hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT    ),        //                               .hps_io_i2c0_inst_SDA
	.hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK    ),        //                               .hps_io_i2c0_inst_SCL
	//HPS I2C2
	.hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT    ),        //                               .hps_io_i2c1_inst_SDA
	.hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK    ),        //                               .hps_io_i2c1_inst_SCL
	//HPS GPIO
	.hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N),           //                               .hps_io_gpio_inst_GPIO09
	.hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N),           //                               .hps_io_gpio_inst_GPIO35
	.hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO),              //                               .hps_io_gpio_inst_GPIO40
	//.hps_0_hps_io_hps_io_gpio_inst_GPIO41  ( HPS_GPIO[1]),              //                               .hps_io_gpio_inst_GPIO41
	.hps_0_hps_io_hps_io_gpio_inst_GPIO48  ( HPS_I2C_CONTROL),          //                               .hps_io_gpio_inst_GPIO48
	.hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED),                  //                               .hps_io_gpio_inst_GPIO53
	.hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY),                  //                               .hps_io_gpio_inst_GPIO54
	.hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT),          //                               .hps_io_gpio_inst_GPIO61
	//HPS reset output
	.led_pio_external_connection_export    ( fpga_led_internal 	),    //    led_pio_external_connection.export
	.dipsw_pio_external_connection_export  ( SW	),  //  dipsw_pio_external_connection.export
	.button_pio_external_connection_export ( fpga_debounced_buttons	), // button_pio_external_connection.export
	.hps_0_h2f_reset_reset_n               ( hps_fpga_reset_n ),                //                hps_0_h2f_reset.reset_n
	.hps_0_f2h_cold_reset_req_reset_n      (~hps_cold_reset ),      //       hps_0_f2h_cold_reset_req.reset_n
	.hps_0_f2h_debug_reset_req_reset_n     (~hps_debug_reset ),     //      hps_0_f2h_debug_reset_req.reset_n
	.hps_0_f2h_stm_hw_events_stm_hwevents  (stm_hw_events ),  //        hps_0_f2h_stm_hw_events.stm_hwevents
	.hps_0_f2h_warm_reset_req_reset_n      (~hps_warm_reset ),      //       hps_0_f2h_warm_reset_req.reset_n
	// Mesa HM2
	.mk_io_hm2_datain                  		(busdata_out),             			//				.hm2_datain
	.mk_io_hm2_dataout                 	  	(hm_datai),                		//				hm2reg.hm2_dataout
	.mk_io_hm2_address                 	  	(hm_address),          				//				.hm2_address
	.mk_io_hm2_write                   		(hm_write),           				//				.hm2_write
	.mk_io_hm2_read                    		(hm_read),                       //				.hm2_read
	.mk_io_hm2_chipsel            			(hm_chipsel),                    // 			.hm2_chipsel
	.mk_io_hm2_int_in            				(int_sig),								//				.int_sig
	.clk_100mhz_out_clk                    (hm_clk_med),                    //				clk_100mhz_out.clk
	.clk_200mhz_out_clk                    (hm_clk_high),            			//				clk_100mhz_out.clk
   .adc_clk_40mhz_clk                     (adc_clk_40)                  //             adc_clk_40mhz.clk
);

top_io_modules top_io_modules_inst
(
	.clk(clklow_sig) ,	// input  clk_sig
	.reset_n(hps_fpga_reset_n) ,	// input  reset_n_sig
	.button_in(KEY) ,	// input [KEY_WIDTH-1:0] button_in_sig
	.button_out(fpga_debounced_buttons) ,	// output [KEY_WIDTH-1:0] button_out_sig
	.hps_cold_reset(hps_cold_reset) ,	// output  hps_cold_reset_sig
	.hps_warm_reset(hps_warm_reset) ,	// output  hps_warm_reset_sig
	.hps_debug_reset(hps_debug_reset) ,	// output  hps_debug_reset_sig
	.LED(LEDR[0]) 	// output  LED_sig
);

defparam top_io_modules_inst.KEY_WIDTH = 2;

// Mesa code ------------------------------------------------------//

assign clklow_sig = fpga_clk_50;
assign clkhigh_sig = hm_clk_high;
assign clkmed_sig = hm_clk_med;

genvar ig;
generate for(ig=0;ig<NumGPIO;ig=ig+1) begin : iosigloop
//	assign io_leds_sig[ig] = hm2_leds_sig[(ig*MuxLedWidth)+:MuxLedWidth];
	assign io_bitsout_sig[ig] = hm2_bitsout_sig[(ig*MuxGPIOIOWidth)+:MuxGPIOIOWidth];
	assign io_bitsin_sig[ig] = hm2_bitsin_sig[(ig*MuxGPIOIOWidth)+:MuxGPIOIOWidth];
end
endgenerate

assign LEDR[7:6] = ~hm2_leds_sig[1:0];

gpio_adr_decoder_reg gpio_adr_decoder_reg_inst
(
	.CLOCK(clklow_sig) ,	// input  CLOCK_sig
	.reg_clk(clkhigh_sig) ,	// input  CLOCK_sig
	.reset_reg_N(hps_fpga_reset_n) ,	// input  reset_reg_N_sig
	.chip_sel(hm_chipsel[0]) ,	// input  data_ready_sig
	.write_reg(hm_write) ,	// input  data_ready_sig
	.read_reg(hm_read) ,	// input  data_ready_sig
	.busaddress(hm_address) ,	// input [AddrWidth-1:0] address_sig
	.busdata_in(hm_datai) ,	// input [BusWidth-1:0] data_in_sig
	.iodatafromhm3 ( io_bitsout_sig ),
	.busdata_fromhm2 ( hm_datao ),
	.gpioport( GPIO ),
	.iodatatohm3 ( io_bitsin_sig ),
	.busdata_to_cpu ( busdata_out ),
// ADC
	.adc_clk(adc_clk_40),	// input  adc_clk_sig
	.ADC_CONVST_o(ADC_CS_N),	// output  ADC_CONVST_o_sig
	.ADC_SCK_o(ADC_SCLK),	// output  ADC_SCK_o_sig
	.ADC_SDI_o(ADC_DIN),	// output  ADC_SDI_o_sig
	.ADC_SDO_i(ADC_DOUT),	// input  ADC_SDO_i_sig
// CAP_Sensors
//	.sense({ARDUINO_IO[9],ARDUINO_IO[10],ARDUINO_IO[11],ARDUINO_IO[12]}),
//	.charge(ARDUINO_IO[13]),
	.calibval_0(calibval_0),
	.counts_0(counts_0),
	.touched(touched), 	
	.buttons(fpga_debounced_buttons)
);

defparam gpio_adr_decoder_reg_inst.AddrWidth = AddrWidth;
defparam gpio_adr_decoder_reg_inst.BusWidth = BusWidth;
defparam gpio_adr_decoder_reg_inst.GPIOWidth = GPIOWidth;
defparam gpio_adr_decoder_reg_inst.MuxGPIOIOWidth = MuxGPIOIOWidth;
defparam gpio_adr_decoder_reg_inst.NumIOAddrReg = NumIOAddrReg;
//defparam gpio_adr_decoder_reg_inst.MuxLedWidth = MuxLedWidth;
defparam gpio_adr_decoder_reg_inst.NumGPIO = NumGPIO;
defparam gpio_adr_decoder_reg_inst.NumSense = 4;


HostMot3_cfg HostMot3_inst
(
	.ibustop(hm_datai) ,	// input [buswidth-1:0] ibus_sig
	.obustop(hm_datao) ,	// output [buswidth-1:0] obus_sig
	.addr(hm_address) ,	// input [addrwidth-1:2] addr_sig	-- addr => A(AddrWidth-1 downto 2),
	.readstb(hm_read ) ,	// input  readstb_sig
	.writestb(hm_write) ,	// input  writestb_sig

	.clklow(clklow_sig) ,	// input  clklow_sig  				-- PCI clock --> all
	.clkmed(clkmed_sig) ,	// input  clkmed_sig  				-- Processor clock --> sserialwa, twiddle
	.clkhigh(clkhigh_sig) ,	// input  clkhigh_sig				-- High speed clock --> most
	.intirq(int_sig) ,	// output  int_sig							--int => LINT, ---> PCI ?
//	.dreq(dreq_sig) ,	// output  dreq_sig
//	.demandmode(demandmode_sig) ,	// output  demandmode_sig
	.iobitsouttop(hm2_bitsout_sig) ,	// inout [IOWidth-1:0] 				--iobits => IOBITS,-- external I/O bits
	.iobitsintop(hm2_bitsin_sig) ,	// inout [IOWidth-1:0] 				--iobits => IOBITS,-- external I/O bits
//	.liobits(liobits_sig) ,	// inout [lIOWidth-1:0] 			--liobits_sig
//	.rates(rates_sig) ,	// output [4:0] rates_sig
	.leds(hm2_leds_sig) 	// output [ledcount-1:0] leds_sig		--leds => LEDS
);

// defparam HostMot3_inst.ThePinDesc = PinDesc;
// defparam HostMot3_inst.TheModuleID =  "ModuleID";
// defparam HostMot3_inst.IDROMType = 3;
defparam HostMot3_inst.SepClocks = SepClocks;
defparam HostMot3_inst.OneWS = OneWS;
// defparam HostMot3_inst.UseIRQLogic = "true";
// defparam HostMot3_inst.PWMRefWidth = 13;
// defparam HostMot3_inst.UseWatchDog = "true";
// defparam HostMot3_inst.OffsetToModules = 64;
// defparam HostMot3_inst.OffsetToPinDesc = 448;
defparam HostMot3_inst.ClockHigh = ClockHigh;
defparam HostMot3_inst.ClockMed = ClockMed;
defparam HostMot3_inst.ClockLow = ClockLow;
defparam HostMot3_inst.BoardNameLow = BoardNameLow;
defparam HostMot3_inst.BoardNameHigh = BoardNameHigh;
defparam HostMot3_inst.FPGASize = FPGASize;
defparam HostMot3_inst.FPGAPins = FPGAPins;
defparam HostMot3_inst.IOPorts = IOPorts;
defparam HostMot3_inst.IOWidth = IOWidth;
defparam HostMot3_inst.PortWidth = PortWidth;
defparam HostMot3_inst.LIOWidth = LIOWidth;
defparam HostMot3_inst.LEDCount = LEDCount;
defparam HostMot3_inst.BusWidth = BusWidth;
defparam HostMot3_inst.AddrWidth = AddrWidth;
// defparam HostMot3_inst.InstStride0 = 4;
// defparam HostMot3_inst.InstStride1 = 64;
// defparam HostMot3_inst.RegStride0 = 256;
// defparam HostMot3_inst.RegStride1 = 256;



endmodule

