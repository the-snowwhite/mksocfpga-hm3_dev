
library IEEE;
use IEEE.std_logic_1164.all;  -- defines std_logic types
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

-- Copyright 2016 - 2017 (C)  Michael Brown Holotronic
-- holotronic.dk

-- This file is created for Machinekit intended use
library pins;
use work.PIN_G540x2_34.all;
use work.IDROMConst.all;

use work.oneofndecode.all;

entity MakeStepgens is
--  		PWMRateAddr : std_Logic_Vector(7 downto 0) := PWMRateAddr;
--  		PDMRateAddr : std_Logic_Vector(7 downto 0) := PDMRateAddr;
--  		PWMEnasAddr : std_Logic_Vector(7 downto 0) := PWMEnasAddr;
--  		PWMValAddr : std_Logic_Vector(7 downto 0) := PWMValAddr;
--  		PWMCRAddr : std_Logic_Vector(7 downto 0) := PWMCRAddr;
--  		PWMRefWidth : integer := 13;
--  		QCounterAddr : std_Logic_Vector(7 downto 0) := QCounterAddr;
--  		QCounterCCRAddr : std_Logic_Vector(7 downto 0) := QCounterCCRAddr;
--  		UseProbe : boolean := false;
-- 		TSDivAddr : std_Logic_Vector(7 downto 0) := TSDivAddr
-- 	);
-- 	port (
-- 	ibus : in std_logic_vector(buswidth -1 downto 0);
-- 	obus : out std_logic_vector(buswidth -1 downto 0);
-- 	addr : in std_logic_vector(AddrWidth -1 downto 2);
-- 	clklow : in std_logic;
-- 	clkmed : in std_logic;
-- 	clkhigh : in std_logic;
-- 	readstb : in std_logic;
-- 	writestb : in std_logic;
-- 	Probe : inout std_logic
-- 	);
	generic (
		ThePinDesc: PinDescType := PinDesc;
  		ClockHigh: integer;
  		ClockMed: integer;
  		ClockLow: integer;
		BusWidth: integer;
		AddrWidth: integer;
		IOWidth: integer;
		STEPGENs: integer;
		StepGenTableWidth: integer;
		UseStepGenPreScaler: boolean;
		UseStepgenIndex: boolean;
		UseStepgenProbe: boolean;
		timersize: integer;			-- = ~480 usec at 33 MHz, ~320 at 50 Mhz
		asize: integer;
		rsize: integer;
		PWMGens: integer;
		PWMRefWidth  : integer;
  		UsePWMEnas : boolean;
		QCounters: integer;
		UseProbe: boolean);
	Port (
		ibus : in std_logic_vector(BusWidth -1 downto 0) := (others => 'Z');
		obus : out std_logic_vector(BusWidth -1 downto 0) := (others => 'Z');
		A : in std_logic_vector(AddrWidth -1 downto 2);
		readstb : in std_logic;
		writestb : in std_logic;
		AltData :  inout std_logic_vector(iowidth-1 downto 0) := (others => '0');
		IOBits :  inout std_logic_vector(iowidth-1 downto 0) := (others => '0');
		clklow : in std_logic;
		clkmed : in std_logic;
		clkhigh : in std_logic;
		Probe : inout std_logic);

end MakeStepgens;


architecture dataflow of MakeStepgens is

-- Signals

-- I/O port related signals
	signal RefCountBus : std_logic_vector(PWMRefWidth-1 downto 0);

	begin
	makeSTEPGENs: if STEPGENs >0 generate
	signal LoadStepGenRate: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenRate: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenAccum: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenAccum: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenMode: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenMode: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenDSUTime: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenDSUTime: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenDHLDTime: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenDHLDTime: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenPulseATime: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenPulseATime: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenPulseITime: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenPulseITime: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenTableMax: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenTableMax: std_logic_vector(STEPGENs -1 downto 0);
	signal LoadStepGenTable: std_logic_vector(STEPGENs -1 downto 0);
	signal ReadStepGenTable: std_logic_vector(STEPGENs -1 downto 0);
	type StepGenOutType is array(STEPGENs-1 downto 0) of std_logic_vector(StepGenTableWidth-1 downto 0);
	signal StepGenOut : StepGenOutType;
	signal StepGenIndex: std_logic_vector(STEPGENs -1 downto 0);
-- Step generator related signals

	signal StepGenRateSel: std_logic;
	signal StepGenAccumSel: std_logic;
	signal StepGenModeSel: std_logic;
	signal StepGenDSUTimeSel: std_logic;
	signal StepGenDHLDTimeSel: std_logic;
	signal StepGenPulseATimeSel: std_logic;
	signal StepGenPulseITimeSel: std_logic;
	signal StepGenTableMaxSel: std_logic;
	signal StepGenTableSel: std_logic;

-- Step generators master rate related signals

	signal LoadStepGenBasicRate: std_logic;
	signal ReadStepGenBasicRate: std_logic;
	signal StepGenBasicRate: std_logic;
	begin
		makeStepGenPreScaler:  if UseStepGenPreScaler generate
			StepRategen : entity work.RateGen port map(
				ibus => ibus,
				obus => obus,
				loadbasicrate => LoadStepGenBasicRate,
				readbasicrate => ReadStepGenBasicRate,
				hold => '0',
				basicrate => StepGenBasicRate,
				clk => clklow);
			end generate;

		generateSTEPGENs: for i in 0 to STEPGENs-1 generate
			usg: if UseStepGenPreScaler and not(UseStepgenIndex or UseStepgenProbe) generate
		   stepgenx: entity work.stepgen
			generic map (
				buswidth => BusWidth,
				timersize => 14,			-- = ~480 usec at 33 MHz, ~320 at 50 Mhz
				tablewidth => StepGenTableWidth,
				asize => 48,
				rsize => 32
				)
			port map (
				clk => clklow,
				ibus => ibus,
				obus 	=>	 obus,
				loadsteprate => LoadStepGenRate(i),
				loadaccum => LoadStepGenAccum(i),
				loadstepmode => LoadStepGenMode(i),
				loaddirsetuptime => LoadStepGenDSUTime(i),
				loaddirholdtime => LoadStepGenDHLDTime(i),
				loadpulseactivetime => LoadStepGenPulseATime(i),
				loadpulseidletime => LoadStepGenPulseITime(i),
				loadtable => LoadStepGenTable(i),
				loadtablemax => LoadStepGenTableMax(i),
				readsteprate => ReadStepGenRate(i),
				readaccum => ReadStepGenAccum(i),
				readstepmode => ReadStepGenMode(i),
				readdirsetuptime => ReadStepGenDSUTime(i),
				readdirholdtime => ReadStepGenDHLDTime(i),
				readpulseactivetime => ReadStepGenPulseATime(i),
				readpulseidletime => ReadStepGenPulseITime(i),
				readtable => ReadStepGenTable(i),
				readtablemax => ReadStepGenTableMax(i),
				basicrate => StepGenBasicRate,
				hold => '0',
				stout => StepGenOut(i)
				);
			end generate usg;

			nusg: if not UseStepGenPreScaler and not(UseStepgenIndex or UseStepgenProbe) generate
			stepgenx: entity work.stepgen
			generic map (
				buswidth => BusWidth,
				timersize => 14,			-- = ~480 usec at 33 MHz, ~320 at 50 Mhz
				tablewidth => StepGenTableWidth,
				asize => 48,
				rsize => 32
				)
			port map (
				clk => clklow,
				ibus => ibus,
				obus 	=>	 obus,
				loadsteprate => LoadStepGenRate(i),
				loadaccum => LoadStepGenAccum(i),
				loadstepmode => LoadStepGenMode(i),
				loaddirsetuptime => LoadStepGenDSUTime(i),
				loaddirholdtime => LoadStepGenDHLDTime(i),
				loadpulseactivetime => LoadStepGenPulseATime(i),
				loadpulseidletime => LoadStepGenPulseITime(i),
				loadtable => LoadStepGenTable(i),
				loadtablemax => LoadStepGenTableMax(i),
				readsteprate => ReadStepGenRate(i),
				readaccum => ReadStepGenAccum(i),
				readstepmode => ReadStepGenMode(i),
				readdirsetuptime => ReadStepGenDSUTime(i),
				readdirholdtime => ReadStepGenDHLDTime(i),
				readpulseactivetime => ReadStepGenPulseATime(i),
				readpulseidletime => ReadStepGenPulseITime(i),
				readtable => ReadStepGenTable(i),
				readtablemax => ReadStepGenTableMax(i),
				basicrate => '1',
				hold => '0',
				stout => StepGenOut(i)  -- densely packed starting with I/O bit 0
				);
			end generate nusg;

			usgi: if UseStepGenPreScaler and (UseStepgenIndex or UseStepgenProbe) generate
		   stepgenx: entity work.stepgeni
			generic map (
				buswidth => BusWidth,
				timersize => 14,			-- = ~480 usec at 33 MHz, ~320 at 50 Mhz
				tablewidth => StepGenTableWidth,
				asize => 48,
				rsize => 32,
				lsize =>16
				)
			port map (
				clk => clklow,
				ibus => ibus,
				obus 	=>	 obus,
				loadsteprate => LoadStepGenRate(i),
				loadaccum => LoadStepGenAccum(i),
				loadstepmode => LoadStepGenMode(i),
				loaddirsetuptime => LoadStepGenDSUTime(i),
				loaddirholdtime => LoadStepGenDHLDTime(i),
				loadpulseactivetime => LoadStepGenPulseATime(i),
				loadpulseidletime => LoadStepGenPulseITime(i),
				loadtable => LoadStepGenTable(i),
				loadtablemax => LoadStepGenTableMax(i),
				readsteprate => ReadStepGenRate(i),
				readaccum => ReadStepGenAccum(i),
				readstepmode => ReadStepGenMode(i),
				readdirsetuptime => ReadStepGenDSUTime(i),
				readdirholdtime => ReadStepGenDHLDTime(i),
				readpulseactivetime => ReadStepGenPulseATime(i),
				readpulseidletime => ReadStepGenPulseITime(i),
				readtable => ReadStepGenTable(i),
				readtablemax => ReadStepGenTableMax(i),
				basicrate => StepGenBasicRate,
				hold => '0',
				stout => StepGenOut(i),
				index => StepGenIndex(i),
				probe => probe
				);
			end generate usgi;

			nusgi: if not UseStepGenPreScaler and not(UseStepgenIndex or UseStepgenProbe) generate
			stepgenx: entity work.stepgeni
			generic map (
				buswidth => BusWidth,
				timersize => 14,			-- = ~480 usec at 33 MHz, ~320 at 50 Mhz
				tablewidth => StepGenTableWidth,
				asize => 48,
				rsize => 32,
				lsize =>16
				)
			port map (
				clk => clklow,
				ibus => ibus,
				obus 	=>	 obus,
				loadsteprate => LoadStepGenRate(i),
				loadaccum => LoadStepGenAccum(i),
				loadstepmode => LoadStepGenMode(i),
				loaddirsetuptime => LoadStepGenDSUTime(i),
				loaddirholdtime => LoadStepGenDHLDTime(i),
				loadpulseactivetime => LoadStepGenPulseATime(i),
				loadpulseidletime => LoadStepGenPulseITime(i),
				loadtable => LoadStepGenTable(i),
				loadtablemax => LoadStepGenTableMax(i),
				readsteprate => ReadStepGenRate(i),
				readaccum => ReadStepGenAccum(i),
				readstepmode => ReadStepGenMode(i),
				readdirsetuptime => ReadStepGenDSUTime(i),
				readdirholdtime => ReadStepGenDHLDTime(i),
				readpulseactivetime => ReadStepGenPulseATime(i),
				readpulseidletime => ReadStepGenPulseITime(i),
				readtable => ReadStepGenTable(i),
				readtablemax => ReadStepGenTableMax(i),
				basicrate => '1',
				hold => '0',
				stout => StepGenOut(i),  -- densely packed starting with I/O bit 0
				index => StepGenIndex(i),
				probe => probe
				);
			end generate nusgi;
		end generate generateSTEPGENs;

		StepGenDecodeProcess : process (A,readstb,writestb,StepGenRateSel, StepGenAccumSel, StepGenModeSel,
                                 			StepGenDSUTimeSel, StepGenDHLDTimeSel, StepGenPulseATimeSel,
			                                 StepGenPulseITimeSel, StepGenTableSel, StepGenTableMaxSel)
		begin
			if A(15 downto 8) = StepGenRateAddr then	 --  stepgen rate register select
				StepGenRateSel <= '1';
			else
				StepGenRateSel <= '0';
			end if;
			if A(15 downto 8) = StepGenAccumAddr then	 --  stepgen Accumumlator low select
				StepGenAccumSel <= '1';
			else
				StepGenAccumSel <= '0';
			end if;
			if A(15 downto 8) = StepGenModeAddr then	 --  stepgen mode register select
				StepGenModeSel <= '1';
			else
				StepGenModeSel <= '0';
			end if;
			if A(15 downto 8) = StepGenDSUTimeAddr then	 --  stepgen Dir setup time register select
				StepGenDSUTimeSel <= '1';
			else
				StepGenDSUTimeSel <= '0';
			end if;
			if A(15 downto 8) =StepGenDHLDTimeAddr then	 --  stepgen Dir hold time register select
				StepGenDHLDTimeSel <= '1';
			else
				StepGenDHLDTimeSel <= '0';
			end if;
			if A(15 downto 8) = StepGenPulseATimeAddr then	 --  stepgen pulse width register select
				StepGenPulseATimeSel <= '1';
			else
				StepGenPulseATimeSel <= '0';
			end if;
			if A(15 downto 8) = StepGenPulseITimeAddr then	 --  stepgen pulse width register select
				StepGenPulseITimeSel <= '1';
			else
				StepGenPulseITimeSel <= '0';
			end if;
			if A(15 downto 8) = StepGenTableAddr then	 --  stepgen pulse width register select
				StepGenTableSel <= '1';
			else
				StepGenTableSel <= '0';
			end if;
			if A(15 downto 8) = StepGenTableMaxAddr then	 --  stepgen pulse width register select
				StepGenTableMaxSel <= '1';
			else
				StepGenTableMaxSel <= '0';
			end if;
			if A(15 downto 8) = StepGenBasicRateAddr and writestb = '1' then	 --
				LoadStepGenBasicRate <= '1';
			else
				LoadStepGenBasicRate <= '0';
			end if;
			if A(15 downto 8) = StepGenBasicRateAddr and readstb = '1' then	 --
				ReadStepGenBasicRate <= '1';
			else
				ReadStepGenBasicRate <= '0';
			end if;
			LoadStepGenRate <= OneOfNDecode(STEPGENs,StepGenRateSel,writestb,A(7 downto 2)); 	-- 64 max
			ReadStepGenRate <= OneOfNDecode(STEPGENs,StepGenRateSel,readstb,A(7 downto 2)); 		-- Note: all the reads are decoded here
			LoadStepGenAccum <= OneOfNDecode(STEPGENs,StepGenAccumSel,writestb,A(7 downto 2));	-- but most are commented out in the
			ReadStepGenAccum <= OneOfNDecode(STEPGENs,StepGenAccumSel,readstb,A(7 downto 2));	-- stepgen module hardware for space reasons
			LoadStepGenMode <= OneOfNDecode(STEPGENs,StepGenModeSel,writestb,A(7 downto 2));
			ReadStepGenMode <= OneOfNDecode(STEPGENs,StepGenModeSel,Readstb,A(7 downto 2));
			LoadStepGenDSUTime <= OneOfNDecode(STEPGENs,StepGenDSUTimeSel,writestb,A(7 downto 2));
			ReadStepGenDSUTime <= OneOfNDecode(STEPGENs,StepGenDSUTimeSel,Readstb,A(7 downto 2));
			LoadStepGenDHLDTime <= OneOfNDecode(STEPGENs,StepGenDHLDTimeSel,writestb,A(7 downto 2));
			ReadStepGenDHLDTime <= OneOfNDecode(STEPGENs,StepGenDHLDTimeSel,Readstb,A(7 downto 2));
			LoadStepGenPulseATime <= OneOfNDecode(STEPGENs,StepGenPulseATimeSel,writestb,A(7 downto 2));
			ReadStepGenPulseATime <= OneOfNDecode(STEPGENs,StepGenPulseATimeSel,Readstb,A(7 downto 2));
			LoadStepGenPulseITime <= OneOfNDecode(STEPGENs,StepGenPulseITimeSel,writestb,A(7 downto 2));
			ReadStepGenPulseITime <= OneOfNDecode(STEPGENs,StepGenPulseITimeSel,Readstb,A(7 downto 2));
			LoadStepGenTable <= OneOfNDecode(STEPGENs,StepGenTableSel,writestb,A(7 downto 2));
			ReadStepGenTable <= OneOfNDecode(STEPGENs,StepGenTableSel,Readstb,A(7 downto 2));
			LoadStepGenTableMax <= OneOfNDecode(STEPGENs,StepGenTableMaxSel,writestb,A(7 downto 2));
			ReadStepGenTableMax <= OneOfNDecode(STEPGENs,StepGenTableMaxSel,Readstb,A(7 downto 2));
		end process StepGenDecodeProcess;

		DoStepgenPins: process(IOBits,StepGenOut)
		begin
			for i in 0 to IOWidth -1 loop				-- loop through all the external I/O pins
				if ThePinDesc(i)(15 downto 8) = StepGenTag then
					if (ThePinDesc(i)(7 downto 0) and x"80") /= 0 then -- only for outputs
						AltData(i) <= StepGenOut(conv_integer(ThePinDesc(i)(23 downto 16)))(conv_integer(ThePinDesc(i)(6 downto 0))-1);
					end if;
					case (ThePinDesc(i)(7 downto 0)) is	--secondary pin function
						when StepGenIndexPin =>
							StepGenIndex(conv_integer(ThePinDesc(i)(23 downto 16))) <= IOBits(i);
						when StepGenProbePin =>
							Probe <= IOBits(i);	-- only 1 please!
						when others => null;
					end case;
				end if;
			end loop;
		end process;

	end generate makestepgens;


end dataflow;
