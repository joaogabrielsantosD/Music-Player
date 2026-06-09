library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
   port (
      clock  : in  std_logic;
      rst_n  : in  std_logic;
		
      key    : in  std_logic;
      button : in  std_logic_vector(3 downto 1);
		
      mute        : out std_logic;		
      music_sel   : out std_logic_vector(1 downto 0);  -- 00..11 -> músicas 1..4
      music_state : out std_logic_vector(1 downto 0);
      -- "00"=STOP  "01"=PLAY  "10"=PAUSE  "11"=ERROR
		
		cnt_enable : out std_logic;
		cnt_clear  : out std_logic;
		
      debug : out std_logic_vector(3 downto 0)
   );
end entity fsm;

architecture bhv of fsm is

	signal btn_play_pause_db : std_logic;
   signal btn_select_db     : std_logic;
   signal btn_stop_db       : std_logic;

	signal btn_pp_prev   : std_logic := '0';
	signal btn_sel_prev  : std_logic := '0';
	signal btn_stop_prev : std_logic := '0';

	signal btn_play_pause : std_logic;
	signal btn_select     : std_logic;
	signal btn_stop_btn   : std_logic;

	--signal music_stop  : std_logic;
   --signal music_play  : std_logic;
   --signal music_pause : std_logic;

   type control_state_t is (ST_STOP, ST_PLAY, ST_PAUSE);

   signal current_state : control_state_t := ST_STOP;
   signal next_state    : control_state_t := ST_STOP;

   signal music_sel_int : std_logic_vector(1 downto 0) := "00";

begin

   db1 : entity work.debounce
		generic map (freq => 10)
      port map (
         clock     => clock,
         key_in    => button(1),
         f_key_out => btn_play_pause_db
      );

   db2 : entity work.debounce
      generic map (freq => 10)
		port map (
         clock     => clock,
         key_in    => button(2),
         f_key_out => btn_select_db
      );

   db3 : entity work.debounce
      generic map (freq => 10)
		port map (
         clock     => clock,
         key_in    => button(3),
         f_key_out => btn_stop_db
      );

	process(clock, rst_n)
	begin
		if rst_n = '0' then
			btn_pp_prev   <= '0';
			btn_sel_prev  <= '0';
			btn_stop_prev <= '0';
		elsif rising_edge(clock) then
			btn_pp_prev   <= btn_play_pause_db;
			btn_sel_prev  <= btn_select_db;
			btn_stop_prev <= btn_stop_db;
		end if;
	end process;
	
	btn_play_pause <= btn_play_pause_db and not btn_pp_prev;
   btn_select     <= btn_select_db     and not btn_sel_prev;
   btn_stop_btn   <= btn_stop_db       and not btn_stop_prev;
	
   process(clock, rst_n)
   begin
    	if rst_n = '0' then
        	current_state <= ST_STOP;
    	elsif rising_edge(clock) then
			current_state <= next_state;
    	end if;
   end process;

   process(current_state, btn_play_pause, btn_stop_btn)
	begin
      next_state <= current_state;
		
		if btn_stop_btn = '1' then
			next_state <= ST_STOP;
		elsif btn_play_pause = '1' then
			case current_state is
				when ST_STOP  => next_state <= ST_PLAY;
				when ST_PLAY  => next_state <= ST_PAUSE;
				when ST_PAUSE => next_state <= ST_PLAY;
				--when others => next_state <= ST_PLAY;
			end case;
		end if;
   end process;

 	process(clock, rst_n)
   begin
      if rst_n = '0' then
			music_sel_int <= "00";
      elsif rising_edge(clock) then
         if btn_select = '1' and current_state = ST_STOP then
            case music_sel_int is
               when "00"   => music_sel_int <= "01";
               when "01"   => music_sel_int <= "10";
               when "10"   => music_sel_int <= "11";
               when "11"   => music_sel_int <= "00";
               when others => music_sel_int <= "00";
            end case;
         end if;
      end if;
   end process;

   --music_stop  <= '1' when current_state = ST_STOP  else '0';
   --music_play  <= '1' when current_state = ST_PLAY  else '0';
   --music_pause <= '1' when current_state = ST_PAUSE else '0';

   music_sel   <= music_sel_int;

   cnt_enable  <= '1' when current_state = ST_PLAY else '0';
   cnt_clear   <= '1' when current_state = ST_STOP else '0';

   mute <= not key;

   with current_state select
      music_state <= "00" when ST_STOP,
                     "01" when ST_PLAY,
                     "10" when ST_PAUSE,
                     "11" when others;

   -- LED1=stop | LED2=play | LED3=pause | LED4=error
   debug(0) <= '0' when current_state = ST_STOP  else '1';
   debug(1) <= '0' when current_state = ST_PLAY  else '1';
   debug(2) <= '0' when current_state = ST_PAUSE else '1';
   --debug(3) <= not key;
	debug(3) <= '0' when current_state /= ST_PAUSE and current_state /= ST_PLAY and current_state /= ST_STOP  else '1';

end architecture bhv;