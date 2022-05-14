library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sc_inf is 
        port (
              -- inputs:
                 nios_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 nios_chipselect_n : IN STD_LOGIC;
                 nios_clk : IN STD_LOGIC;
                 nios_reset_n : IN STD_LOGIC;
                 nios_write_n : IN STD_LOGIC;
                 nios_read_n : IN STD_LOGIC;
                 nios_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 nios_irq : OUT STD_LOGIC;
                 nios_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity sc_inf;


architecture Behavioral of sc_inf is
	signal reg_command : std_logic_vector(31 downto 0);
	signal reg_result : std_logic_vector(31 downto 0);
	signal write_d : std_logic;
	signal irq_int : std_logic;
	type res_reg is array(0 to 63) of std_logic_vector(31 downto 0);
	signal result_regs: res_reg;
	
begin

	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			reg_command <= (others => '0');
			reg_result <= (others => '0');
		elsif(nios_clk'event and nios_clk = '1')then
			if(nios_chipselect_n = '0')then
				if(nios_address = "00000000" and nios_read_n = '0')then -- read for NIOS
					nios_readdata <= reg_command;
				elsif(nios_address = "00000001" and nios_read_n = '0')then -- read for S.C.
					nios_readdata <= reg_result;
				elsif(nios_address = "00000010" and nios_write_n = '0')then -- write for NIOS
					reg_result <= nios_writedata;
				elsif(nios_address = "00000011" and nios_write_n = '0')then -- write for S.C.
					reg_command <= nios_writedata;
--				elsif(nios_address = "0000100" and nios_write_n = '0')then -- write for NIOS
--				elsif(nios_address = "0000101" and nios_read_n = '0')then -- read for S.C.
--				elsif(nios_address = "0000110" and nios_read_n = '0')then -- read for NIOS
				elsif(nios_address = "00000111" and nios_read_n = '0')then -- read for S.C.
					nios_readdata(31 downto 1) <= (others => '0');
					nios_readdata(0) <= irq_int;
				elsif(nios_address(7 downto 6) = "01")then -- 6th bit as 1 means, this is for result register R/W
					if(nios_read_n = '0')then -- SCJ is reading result data
						nios_readdata <= result_regs(conv_integer(unsigned(nios_address(5 downto 0))));
					elsif(nios_write_n = '0')then -- CPU is writing results
						result_regs(conv_integer(unsigned(nios_address(5 downto 0)))) <= nios_writedata;
					end if;
				end if;
			else
			end if;
		end if;
	end process;


	process(nios_clk)begin
		if(nios_clk'event and nios_clk = '1')then
			if(nios_chipselect_n = '0')then
				if(nios_address = "00000011" and nios_write_n = '0')then
					irq_int <= '1';
				elsif(nios_address = "00000111" and nios_write_n = '0')then
					irq_int <= nios_writedata(0);
				end if;
			end if;
		end if;
	end process;
	
	nios_irq <= irq_int;
	
end Behavioral;
