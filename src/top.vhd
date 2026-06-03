LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.i2c_pkg.ALL;

entity top is
	port (
		clock : in    std_logic;
		rst_n : in    std_logic;
		
		scl   : out   std_logic;
		sda   : inout std_logic
	);
end entity;

architecture top_level of top is
	signal temp_data : std_logic_vector(15 downto 0);

begin
	temperature : i2c port map (
		clk => clock,
		rst_n => rst_n,
		scl => scl,
		sda => sda,
		data => temp_data
	);

end top_level;