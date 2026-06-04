LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.i2c_pkg.ALL;
USE IEEE.seven_seg_pkg.ALL;

entity top is
	port (
		clock : in    std_logic;
		rst_n : in    std_logic;
		
		scl   : out   std_logic;
		sda   : inout std_logic;
		
		dig 	: out std_logic_vector(3 downto 0);
		seg 	: out std_logic_vector(7 downto 0)	
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
	
	display7 : seven_seg port map (
		clk => clock,
		data_in => temp_data,
		dig => dig,
		seg => seg
	);

end top_level;