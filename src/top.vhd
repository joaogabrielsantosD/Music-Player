-- EXAMPLE CODE

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY top IS
	PORT(
		x : IN  integer;
		y : OUT integer 
	);
END ENTITY;

ARCHITECTURE top_level OF top IS
	COMPONENT dff
		PORT(
			d    : IN  std_logic;
			clk  : IN  std_logic;
			clrn : IN  std_logic;
			prn  : IN  std_logic;
			q    : OUT std_logic
		);
	END COMPONENT;
	
	SIGNAL s : integer;
	CONSTANT c : integer := 7;
	SHARED VARIABLE v1 : integer;
	
BEGIN
	PROCESS (x)
		VARIABLE v2 : integer := 3;
	
	BEGIN
		v1 := 5;
		s <= v1 + v2 + c;
	END PROCESS;
	
	y <= s + x;

END top_level;