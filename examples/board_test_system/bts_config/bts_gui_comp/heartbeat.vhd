library ieee;
use ieee.std_logic_1164.all;


						
entity heartbeat is
	port (
		nios_clk: in std_logic; -- system 50MHz nios_clk
		nios_reset_n : in std_logic; -- system nios_reset_n/power on nios_reset_n

	  -- inputs:
		 nios_address : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		 nios_chipselect_n : IN STD_LOGIC;
		 nios_read_n : IN STD_LOGIC;
         nios_write_n : IN STD_LOGIC;
		 nios_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

	  -- outputs:
		 nios_irq : OUT STD_LOGIC;
		 nios_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		 

		--dipsw : in std_logic_vector(0 downto 0);
		
		led : out std_logic -- 
		
		
		
	);
end heartbeat;

architecture rtl of heartbeat is
	
	constant max : integer := 2621439;
	constant step : integer := 15;

	
	signal duty : std_logic_vector(step downto 0);	
	signal counter_100Hz : integer range 0 to max;
	signal count100_duty : integer range 0 to step;	
	signal up : std_logic;
	signal count100 : integer range 0 to step;
	signal holt : std_logic:='0';
	
begin

	 


	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			holt <= '0';
			nios_irq <= '0';
		elsif(nios_clk'event and nios_clk = '1')then
			if(nios_chipselect_n = '0' and nios_read_n = '0')then
				nios_readdata <= x"deadbeef";
				holt <= '0';
				nios_irq <= '0';
			elsif(nios_chipselect_n = '0' and nios_write_n = '0')then
				holt <= nios_writedata(0);
			elsif(count100_duty = step and counter_100Hz = max)then
				holt <= '1';
				nios_irq <= '1';
			end if;
		end if;
	end process;

		 
		 

		 



	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			counter_100Hz <= 0;
		elsif(nios_clk'event and nios_clk = '1')then
			if(holt = '1')then
				counter_100Hz <= counter_100Hz;
			elsif(counter_100Hz = max)then
				counter_100Hz <= 0;
			else
				counter_100Hz <= counter_100Hz + 1;
			end if;
		end if;
	end process;

	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			count100_duty <= 0;
			up <= '0';
		elsif(nios_clk'event and nios_clk = '1')then
			if(holt = '1')then
				count100_duty <= count100_duty;
			elsif(counter_100Hz = max)then
				if(count100_duty = step)then
					count100_duty <= 0;
					up <= not up;
				else
					count100_duty <= count100_duty + 1;
				end if;
			end if;
		end if;
	end process;

	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			duty <= (others => '1');
		elsif(nios_clk'event and nios_clk = '1')then
			if(holt = '1')then
			elsif(up = '0')then
				duty(count100_duty) <= '0';
			else
				duty(count100_duty) <= '1';
			end if;
		end if;
	end process;

	





	
	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			count100 <= 0;
		elsif(nios_clk'event and nios_clk = '1')then
			if(count100 = step)then
				count100 <= 0;
			else
				count100 <= count100 + 1; -- 0 -> 99
			end if;
		end if;
	end process;
	

	process(nios_reset_n, nios_clk)begin
		if(nios_reset_n = '0')then
			led <= '1';
		elsif(nios_clk'event and nios_clk = '1')then
			led <= duty(count100);
		end if;
	end process;
	
	

end rtl;

