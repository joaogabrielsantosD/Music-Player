library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
	port (
		clk_in 	 : in std_logic;
		overflow : in std_logic_vector (27 downto 0);
		clk_out	 : out std_logic := '0'
	);
end entity;

architecture clock of clock_divider is
	signal toggle : std_logic := '0';
	signal cnt    : integer := 0;
begin
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			if cnt < to_integer(unsigned(overflow)) then
				cnt <= cnt + 1; -- increment
				toggle <= toggle;	
			else
				cnt <= 0; -- restart
				toggle <= not toggle; -- toggle							
			end if;
		end if;
	end process;	
	clk_out <= toggle;
end clock;