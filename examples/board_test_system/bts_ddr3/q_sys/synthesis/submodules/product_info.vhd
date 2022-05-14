--Legal Notice: (C)2009 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_UNSIGNED.all;

						
entity product_info is
	port (
		clk: in std_logic;
		reset_n : in std_logic;
		
		chipselect_n : in std_logic; -- chip select signal
		read_n : in std_logic; -- output enable
		av_address : in std_logic_vector(1 downto 0);
		av_data_read : out std_logic_vector(31 downto 0)
		
	);
end product_info;

architecture rtl of product_info is
--	constant sof : std_logic_vector(31 downto 0):=x"4750494F"; -- GPIO project
--	constant sof : std_logic_vector(31 downto 0):=x"56494445"; -- VIDE project
--	constant sof : std_logic_vector(31 downto 0):=x"48534D43"; -- HSMC project
--	constant sof : std_logic_vector(31 downto 0):=x"51445232"; -- QDR2 project
--	constant sof : std_logic_vector(31 downto 0):=x"44445233"; -- DDR3 project
--	constant sof : std_logic_vector(31 downto 0):=x"44445232"; -- DDR2 project

				constant sof : std_logic_vector(31 downto 0):=x"44445233"; -- DDR3 project
                constant board : std_logic_vector(31 downto 0):=x"43354758"; 
                constant product : std_logic_vector(31 downto 0):=x"0000A916";  
                constant version : std_logic_vector(31 downto 0):=x"00000001"; 
begin

	process(reset_n, clk)begin
		if(reset_n = '0')then
			av_data_read <= (others => '0');
		elsif(clk'event and clk = '1')then
			if(chipselect_n = '0' and read_n = '0')then
				case av_address is
					when "00" => av_data_read <= product;
					when "01" => av_data_read <= board;
					when "10" => av_data_read <= sof;
					when "11" => av_data_read <= version;
				end case;
			end if;
		end if;
	end process;
end rtl;

