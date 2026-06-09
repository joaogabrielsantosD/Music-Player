library ieee;
use ieee.std_logic_1164.all;

package music_pkg is

   component music 
      port (
      clock : in std_logic;
      
      stop : in std_logic;
      play : in std_logic;
		
      music_selection : in std_logic_vector (1 downto 0);
		
      mute   : in std_logic;
      buzzer : out std_logic
   );
   end component;

end package;