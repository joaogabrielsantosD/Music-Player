library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	PORT ( 
		clk, pop : in std_logic;
		
		overflow : in std_logic_vector (27 downto 0);	
		
		q : out std_logic := '0'
	);
end entity;

architecture sem_rearme of timer is
	signal cnt : integer := 0;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if (pop = '1' and cnt = 0) then
				cnt <= to_integer(unsigned(overflow)); -- load temp.
			elsif (pop = '0' and cnt = 0) then 
				cnt <= 0; -- retain
			else 
				cnt <= cnt - 1 ; -- decreases
			end if;
		end if;
		
		-- high level during the counting period
		if cnt /= 0 then 
			q <= '1';
		else 
			q <= '0';
		end if;
	end process;
end sem_rearme;