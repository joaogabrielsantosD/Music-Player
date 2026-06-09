library ieee;
use ieee.std_logic_1164.all;

entity music is
   port (
      clock : in std_logic;
      
      stop : in std_logic;
      play : in std_logic;
		
      music_selection : in std_logic_vector (1 downto 0);
		
      mute   : in  std_logic;
      buzzer : out std_logic
   );
end entity;

architecture player of music is
   signal beep : std_logic;

   signal t1, t2, t4 : std_logic;
   signal t3, t5 : std_logic_vector (27 downto 0);

begin

   temp : entity work.timer port map (
      clk => clock,
      pop => t2,
      overflow => t3,
      q => t1
   );

   div_clock : entity work.clock_divider port map (
      clk_in => clock,
      overflow => t5,
      clk_out => beep
   );

   mus : entity work.music_controller port map (
      clk_out => t4,
      pop => t2,
      temp_out => t3,
      freq_out => t5,
      clk_in => clock,
      stop_in => stop,
      play_in => play,
      duration => t1,
      selection => music_selection
   );

   buzzer <= beep when mute = '0' else '0'; 

end player;