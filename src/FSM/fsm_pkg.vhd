LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
package fsm_pkg is

component fsm
	port (
        clock  : in  std_logic;
        rst_n  : in  std_logic;

        key    : in  std_logic;
        button : in  std_logic_vector(3 downto 1);
		
        mute        : out std_logic;		
        music_sel   : out std_logic_vector(1 downto 0);  -- 00..11 -> músicas 1..4
        music_state : out std_logic_vector(1 downto 0);
        -- "00"=STOP  "01"=PLAY  "10"=PAUSE  "11"=ERROR

        debug : out std_logic_vector(3 downto 0)
	);
end component;

end package;