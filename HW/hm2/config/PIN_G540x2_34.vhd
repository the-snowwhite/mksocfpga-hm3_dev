library IEEE;
use IEEE.std_logic_1164.all;  -- defines std_logic types
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Copyright (C) 2007, Peter C. Wallace, Mesa Electronics
-- http://www.mesanet.com
--
-- This program is is licensed under a disjunctive dual license giving you
-- the choice of one of the two following sets of free software/open source
-- licensing terms:
--
--    * GNU General Public License (GPL), version 2.0 or later
--    * 3-clause BSD License
--
--
-- The GNU GPL License:
--
--     This program is free software; you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation; either version 2 of the License, or
--     (at your option) any later version.
--
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with this program; if not, write to the Free Software
--     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
--
--
-- The 3-clause BSD License:
--
--     Redistribution and use in source and binary forms, with or without
--     modification, are permitted provided that the following conditions
--     are met:
--
--   * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--
--   * Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--
--   * Neither the name of Mesa Electronics nor the names of its
--     contributors may be used to endorse or promote products
--     derived from this software without specific prior written
--     permission.
--
--
-- Disclaimer:
--
--     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--     POSSIBILITY OF SUCH DAMAGE.
--

use work.IDROMConst.all;

package PIN_G540x2_34 is
	constant ModuleID : ModuleIDType :=(
		(WatchDogTag,	x"00",	ClockLowTag,	x"01",	WatchDogTimeAddr&PadT,		WatchDogNumRegs,		x"00",	WatchDogMPBitMask),
		(IOPortTag,		x"00",	ClockLowTag,	x"02",	PortAddr&PadT,				IOPortNumRegs,			x"00",	IOPortMPBitMask),
		(QcountTag,		x"02",	ClockLowTag,	x"02",	QcounterAddr&PadT,			QCounterNumRegs,		x"00",	QCounterMPBitMask),
		(StepGenTag,	x"02",	ClockLowTag,	x"0A",	StepGenRateAddr&PadT,		StepGenNumRegs,			x"00",	StepGenMPBitMask),
		(PWMTag,		x"00",	ClockHighTag,	x"02",	PWMValAddr&PadT,			PWMNumRegs,				x"00",	PWMMPBitMask),
		(LEDTag,		x"00",	ClockLowTag,	x"01",	LEDAddr&PadT,				LEDNumRegs,				x"00",	LEDMPBitMask),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000"),
		(NullTag,		x"00",	NullTag,		x"00",	NullAddr&PadT,				x"00",					x"00",	x"00000000")
		);


	constant PinDesc : PinDescType :=(
-- 	Base func  sec unit sec func 	 sec pin					-- external DB25
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 1		PIN 01	Output 2 just GPIO
	IOPortTag & x"00" & PWMTag & PWMAOutPin,				-- I/O 2		PIN 02	Spindle DAC PWM
	IOPortTag & x"00" & StepGenTag & StepGenStepPin,	-- I/O 3		PIN 03	X Step
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 4		PIN 04	Fault in just GPIO
	IOPortTag & x"00" & StepGenTag & StepGenDirPin,		-- I/O 5		PIN 05	X Dir
	IOPortTag & x"04" & StepGenTag & StepGenStepPin,	-- I/O 6		PIN 06	Charge Pump (16 KHz)
	IOPortTag & x"01" & StepGenTag & StepGenStepPin,	-- I/O 7		PIN 07	Y Step
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 8		PIN 08	Output 1 just GPIO
	IOPortTag & x"01" & StepGenTag & StepGenDirPin,		-- I/O 9		PIN 09	Y Dir
	IOPortTag & x"02" & StepGenTag & StepGenStepPin,	-- I/O 10	PIN 10	Z Step
	IOPortTag & x"02" & StepGenTag & StepGenDirPin,		-- I/O 13	PIN 11	Z Dir
	IOPortTag & x"03" & StepGenTag & StepGenStepPin,	-- I/O 14	PIN 12	A Step
	IOPortTag & x"03" & StepGenTag & StepGenDirPin,		-- I/O 15	PIN 13	A Dir
	IOPortTag & x"00" & QCountTag & QCountQAPin,  		-- I/O 16'	PIN 14	Input 1 (Quad A)
	IOPortTag & x"00" & QCountTag & QCountQBPin,  		-- I/O 17	PIN 15	Input 2 (Quad B)
	IOPortTag & x"00" & QCountTag & QCountIdxPin,    	-- I/O 18	PIN 16	Input 3 (Quad Idx)
	IOPortTag & x"00" & NullTag & NullPin,	 	   		-- I/O 19	PIN 17	Input 4 just GPIO

																	-- 26 HDR	-- IDC DB25
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 20	PIN 18 	Output 2 just GPIO
	IOPortTag & x"01" & PWMTag & PWMAOutPin,				-- I/O 21   PIN 19	Spindle DAC PWM
	IOPortTag & x"05" & StepGenTag & StepGenStepPin,	-- I/O 22   PIN 20	X Step
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 23	PIN 21	Fault in just GPIO
	IOPortTag & x"05" & StepGenTag & StepGenDirPin,		-- I/O 24	PIN 22	X Dir
	IOPortTag & x"09" & StepGenTag & StepGenStepPin,	-- I/O 25	PIN 23	Charge Pump (16 KHz)
	IOPortTag & x"06" & StepGenTag & StepGenStepPin,	-- I/O 26	PIN 24	Y Step
	IOPortTag & x"00" & NullTag & NullPin,					-- I/O 27	PIN 25	Output 1 just GPIO
	IOPortTag & x"06" & StepGenTag & StepGenDirPin,		-- I/O 28	PIN 26	Y Dir
	IOPortTag & x"07" & StepGenTag & StepGenStepPin,	-- I/O 31	PIN 27	Z Step
	IOPortTag & x"07" & StepGenTag & StepGenDirPin,		-- I/O 32	PIN 28	Z Dir
	IOPortTag & x"08" & StepGenTag & StepGenStepPin,	-- I/O 33	PIN 29	A Step
	IOPortTag & x"08" & StepGenTag & StepGenDirPin,		-- I/O 34	PIN 30	A Dir
	IOPortTag & x"01" & QCountTag & QCountQAPin,  		-- I/O 35	PIN 31	Input 1 (Quad A)
	IOPortTag & x"01" & QCountTag & QCountQBPin,  		-- I/O 36	PIN 32	Input 2 (Quad B)
	IOPortTag & x"01" & QCountTag & QCountIdxPin,    	-- I/O 37	PIN 33	Input 3 (Quad Idx)
	IOPortTag & x"00" & NullTag & NullPin,	 	   		-- I/O 38	PIN 34	Input 4 just GPIO


		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin, -- added for 34 pin 5I25
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,


		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin, -- added for IDROM v3
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,

		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,
		emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin,emptypin);

end package PIN_G540x2_34;
