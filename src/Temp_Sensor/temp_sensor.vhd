LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY temp_sensor IS
	PORT
	(
		clock : IN STD_LOGIC;
		
		data : OUT INTEGER
	);
END ENTITY;

ARCHITECTURE temperature_sensor OF temp_sensor IS

END temperature_sensor;