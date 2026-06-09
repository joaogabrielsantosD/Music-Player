library ieee;
use ieee.std_logic_1164.all;
package i2c_pkg is

component i2c
	port (
		clk   : in    std_logic;
		rst_n : in    std_logic;
		scl   : out   std_logic;
		sda   : inout std_logic;
		data  : out   std_logic_vector(15 downto 0)
	);
end component;

end package;