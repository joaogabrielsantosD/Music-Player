LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
package seven_seg_pkg is

component seven_seg
	port (
	   clk      : in  std_logic;
      data_in  : in  std_logic_vector(15 DOWNTO 0);
      dig      : out std_logic_vector(3 DOWNTO 0);
      seg      : out std_logic_vector(7 DOWNTO 0)
	);
end component;

end package;