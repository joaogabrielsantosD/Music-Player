library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	generic (freq : integer := 50);
   port (
     clock     : in  std_logic;
     key_in    : in  std_logic;
     f_key_out : out std_logic
   );
end entity;

architecture Behavioral of debounce is

   -- Clock frequency of FPGA
   constant clk_FPGA   : integer := 50000000;

   -- Counter overflow value
   constant overflow_f : integer := clk_FPGA / (freq * 2);

   -- Counter signal
   signal cnt : integer range 0 to overflow_f := 0;

   -- Divided clock (50 Hz)
   signal clk_out : std_logic := '0';

   -- Debounce flip-flops
   signal dff1 : std_logic := '0';
   signal dff2 : std_logic := '0';

begin

   process(clock)
   begin
      if rising_edge(clock) then
			if cnt < overflow_f then
				cnt <= cnt + 1;
			else
				cnt <= 0;
				clk_out <= not clk_out;
			end if;
      end if;
   end process;
	
   process(clk_out)
   begin
		if rising_edge(clk_out) then
			-- Sample inverted key input
			dff1 <= not key_in;
			
			-- Delay one cycle
			dff2 <= dff1;
		end if;
   end process;
	
   f_key_out <= dff1 and (not dff2);

end Behavioral;