library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity music_controller is
	port (
		clk_out, pop : out std_logic := '0';

		clk_in, duration, stop_in, play_in : in std_logic;
		
		temp_out, freq_out : out std_logic_vector(27 downto 0);
		
		selection : in std_logic_vector(1 downto 0)
	);
end entity;

architecture arc of music_controller is
  
	-- Application of time and frequency
	procedure note(constant ov_f : in integer; constant ov_t : in integer ) is
	begin
		temp_out <= std_logic_vector(to_unsigned(ov_t,temp_out'LENGTH)); -- duration			
		freq_out <= std_logic_vector(to_unsigned(ov_f,freq_out'LENGTH)); -- frequency
		pop <= '1';  -- triggers the temp next note	
	end note;

	-- main board clock
	constant clk_FPGA : integer := 50000000; --50MHz
	-- overflow for frequencies (50MHz)
   -- Formula: Overflow = (50MHz / (2*f)) - 1
	constant PAUSE : integer := 0; -- buzzer stopped
 
	constant C3 : integer := 95555; -- 261.63 Hz (Dó3)
	constant D3 : integer := 85132; -- 293.66 Hz (Ré3)
	constant E3 : integer := 75842; -- 329.63 Hz (Mi3)
	constant F3 : integer := 71586; -- 349.23 Hz (Fá3)
	constant G3 : integer := 63775; -- 392.00 Hz (Sol3)
	constant A3 : integer := 56818; -- 440.00 Hz (Lá3)
	constant B3 : integer := 50619; -- 493.88 Hz (Si3)
	constant Cs3 : integer := 90194; -- 277.18 Hz (Dó#3/Réb3)
	constant Ds3 : integer := 80352; -- 311.13 Hz (Ré#3/Mib3)
	constant Fs3 : integer := 67569; -- 369.99 Hz (Fá#3/Solb3)
	constant Gs3 : integer := 60197; -- 415.30 Hz (Sol#3/Láb3)
	constant As3 : integer := 53629; -- 466.16 Hz (Lá#3/Sib3)

	constant C4 : integer := 47778; -- 523.25 Hz (Dó4)
	constant D4 : integer := 42565; -- 587.33 Hz (Ré4)
	constant E4 : integer := 37921; -- 659.25 Hz (Mi4)
	constant F4 : integer := 35793; -- 698.46 Hz (Fá4)
	constant G4 : integer := 31888; -- 783.99 Hz (Sol4)
	constant A4 : integer := 28401; -- 880.00 Hz (Lá4)
	constant B4 : integer := 25309; -- 987.77 Hz (Si4)
	constant Cs4 : integer := 45096; -- 554.37 Hz (Dó#4/Réb4)
	constant Ds4 : integer := 40176; -- 622.25 Hz (Ré#4/Mib4)
	constant Fs4 : integer := 33784; -- 739.99 Hz (Fá#4/Solb4)
	constant Gs4 : integer := 30098; -- 830.61 Hz (Sol#4/Láb4)
	constant As4 : integer := 26814; -- 932.33 Hz (Lá#4/Sib4)

	constant C5 : integer := 23889; -- 1046.50 Hz (Dó5)
	constant D5 : integer := 21282; -- 1174.66 Hz (Ré5)
	constant E5 : integer := 18960; -- 1318.51 Hz (Mi5)
	constant F5 : integer := 17896; -- 1396.91 Hz (Fá5)
	constant G5 : integer := 15943; -- 1567.98 Hz (Sol5)
	constant A5 : integer := 14204; -- 1760.00 Hz (Lá5)
	constant B5 : integer := 12654; -- 1975.53 Hz (Si5)
	constant Cs5 : integer := 22548; -- 1108.73 Hz (Dó#5/Réb5)
	constant Ds5 : integer := 20088; -- 1244.51 Hz (Ré#5/Mib5)
	constant Fs5 : integer := 16892; -- 1479.98 Hz (Fá#5/Solb5)
	constant Gs5 : integer := 15049; -- 1661.22 Hz (Sol#5/Láb5)
	constant As5 : integer := 13407; -- 1864.66 Hz (Lá#5/Sib5)
	
	-- Zelda constants
	constant BPM1 : integer := 190; 
	constant BPS1 : integer := BPM1 / 60; 
	constant ov1_t4 : integer := (4 * clk_FPGA) / BPS1; 
	constant ov1_t3 : integer := (3 * clk_FPGA) / BPS1; 
	constant ov1_t2 : integer := (2 * clk_FPGA) / BPS1; 
	constant ov1_t1 : integer := clk_FPGA / BPS1; 
	constant ov1_t1_2 : integer := (clk_FPGA / 2) / BPS1; 
	constant ov1_t1_4	: integer := (clk_FPGA / 4) / BPS1;
	
	-- Take On Me constants
	constant BPM2 : integer := 200; 
	constant BPS2 : integer := BPM2 / 60; 
	constant ov2_t4 : integer := (4 * clk_FPGA) / BPS2; 
	constant ov2_t3 : integer := (3 * clk_FPGA) / BPS2; 
	constant ov2_t2 : integer := (2 * clk_FPGA) / BPS2; 
	constant ov2_t1 : integer := clk_FPGA / BPS2; 
	constant ov2_t1_2 : integer := (clk_FPGA / 2) / BPS2; 
	constant ov2_t1_4	: integer := (clk_FPGA / 4) / BPS2;
	
	-- Pokémon constants
	constant BPM3 : integer := 125; 
	constant BPS3 : integer := BPM3 / 60; 
	constant ov3_t4 : integer := (4 * clk_FPGA) / BPS3; 
	constant ov3_t3 : integer := (3 * clk_FPGA) / BPS3; 
	constant ov3_t2 : integer := (2 * clk_FPGA) / BPS3; 
	constant ov3_t1 : integer := clk_FPGA / BPS3; 
	constant ov3_t1_2 : integer := (clk_FPGA / 2) / BPS3; 
	constant ov3_t1_4	: integer := (clk_FPGA / 4) / BPS3;
	
	-- My Way constants
	constant BPM4 : integer := 80; 
	constant BPS4 : integer := BPM4 / 60; 
	constant ov4_t4 : integer := (4 * clk_FPGA) / BPS4; 
	constant ov4_t3 : integer := (3 * clk_FPGA) / BPS4; 
	constant ov4_t2 : integer := (2 * clk_FPGA) / BPS4; 
	constant ov4_t1 : integer := clk_FPGA / BPS4; 
	constant ov4_t1_2 : integer := (clk_FPGA / 2) / BPS4; 
	constant ov4_t1_4	: integer := (clk_FPGA / 4) / BPS4;
	
	-- Scores 
	type score is record
		note : integer;
		time_t : integer;
	end record;

	type vetor_zelda is array (0 to 41) of score;    -- Zelda - Lost Woods        (42)
	type vetor_takeonme is array (0 to 32) of score; -- A-ha - Take On Me         (33)
	type vetor_pokemon is array (0 to 56) of score;  -- Pokemon - Cerulean Theme  (56)
	type vetor_myway is array (0 to 54) of score;    -- Frank Sinatra - My Way    (54)
	
	--Take On Me
	constant music1 : vetor_takeonme := (
		(note => PAUSE, time_t => ov2_t1_2),
		(note => Fs4, time_t => ov2_t1_2), (note => Fs4, time_t => ov2_t1_2), (note => D4,  time_t => ov2_t1_2), 
		(note => B3,  time_t => ov2_t1_2), (note => PAUSE, time_t => ov2_t1_2), (note => B3,  time_t => ov2_t1_2), 
		(note => PAUSE, time_t => ov2_t1_2), (note => E4,  time_t => ov2_t1_2), (note => PAUSE, time_t => ov2_t1_2),
		(note => E4,  time_t => ov2_t1_2), (note => PAUSE, time_t => ov2_t1_2), (note => E4,  time_t => ov2_t1_2),
		(note => Gs4, time_t => ov2_t1_2), (note => Gs4, time_t => ov2_t1_2), (note => A4,  time_t => ov2_t1_2), 
		(note => B4,  time_t => ov2_t1_2), (note => A4,  time_t => ov2_t1_2), (note => A4,  time_t => ov2_t1_2),
		(note => A4,  time_t => ov2_t1_2), (note => E4,  time_t => ov2_t1_2), (note => PAUSE, time_t => ov2_t1_2),
		(note => D4,  time_t => ov2_t1_2), 
		(note => PAUSE, time_t => ov2_t1_2),
		(note => Fs4, time_t => ov2_t1_2), (note => PAUSE, time_t => ov2_t1_2), (note => Fs4, time_t => ov2_t1_2),
		(note => PAUSE, time_t => ov2_t1_2), (note => Fs4, time_t => ov2_t1_2), (note => E4,  time_t => ov2_t1_2),
		(note => E4,  time_t => ov2_t1_2), (note => Fs4, time_t => ov2_t1_2), (note => E4,  time_t => ov2_t1_2)
	);

	--Pokemon
	constant music2 : vetor_pokemon := (
		(note => E4,  time_t => ov3_t1_2), (note => Ds4, time_t => ov3_t1_2), (note => Cs4, time_t => ov3_t1_2),
		(note => B3,  time_t => ov3_t1_2), (note => A3,  time_t => ov3_t1_2), (note => B3,  time_t => ov3_t1_2),
		(note => Cs4, time_t => ov3_t1_2), (note => Ds4, time_t => ov3_t1_2), (note => E4,  time_t => ov3_t1),
		(note => E4,  time_t => ov3_t1_4), (note => B3,  time_t => ov3_t1_4), (note => Cs4, time_t => ov3_t1_2),
		(note => Ds4, time_t => ov3_t1_2), (note => E4,  time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t1_4),
		(note => Gs4, time_t => ov3_t1_4), (note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1),
		(note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t2),
		(note => E4,  time_t => ov3_t1_4), (note => B3,  time_t => ov3_t1_4), (note => Cs4, time_t => ov3_t1_2),
		(note => Ds4, time_t => ov3_t1_2), (note => E4,  time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t1_4),
		(note => Gs4, time_t => ov3_t1_4), (note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1),
		(note => E4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1_4), (note => B4,  time_t => ov3_t2),
		(note => E4,  time_t => ov3_t1_4), (note => B3,  time_t => ov3_t1_4), (note => Cs4, time_t => ov3_t1_2),
		(note => Ds4, time_t => ov3_t1_2), (note => E4,  time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t1_4),
		(note => Gs4, time_t => ov3_t1_4), (note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1),
		(note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t2),
		(note => E4,  time_t => ov3_t1_4), (note => B3,  time_t => ov3_t1_4), (note => Cs4, time_t => ov3_t1_2), 
		(note => Ds4, time_t => ov3_t1_2), (note => E4,  time_t => ov3_t1_4), (note => Fs4, time_t => ov3_t1_4), 
		(note => Gs4, time_t => ov3_t1_4), (note => A4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1), 
		(note => E4,  time_t => ov3_t1_4), (note => Gs4, time_t => ov3_t1_4), (note => B4,  time_t => ov3_t1)
	);

	-- My Way
	constant music3 : vetor_myway := (
		(note => Fs4, time_t => ov4_t1), (note => G4,  time_t => ov4_t1), 
		(note => A4,  time_t => ov4_t1), (note => A4,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => B4,  time_t => ov4_t1), (note => A4,  time_t => ov4_t1), 
		(note => Gs4, time_t => ov4_t1), (note => A4,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => A4,  time_t => ov4_t1), (note => A4,  time_t => ov4_t1), 
		(note => B4,  time_t => ov4_t1), (note => B4,  time_t => ov4_t2),
		(note => PAUSE, time_t => ov4_t1),
		(note => C5,  time_t => ov4_t1), (note => B4,  time_t => ov4_t1), 
		(note => A4,  time_t => ov4_t1), (note => B4,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => B4,  time_t => ov4_t1), (note => Cs5, time_t => ov4_t1), 
		(note => D5,  time_t => ov4_t1), (note => D5,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => B4,  time_t => ov4_t1), (note => D5,  time_t => ov4_t1), 
		(note => B4,  time_t => ov4_t1), (note => Cs5, time_t => ov4_t2),
		(note => PAUSE, time_t => ov4_t1),
		(note => Cs5, time_t => ov4_t1), (note => D5,  time_t => ov4_t1), 
		(note => E5,  time_t => ov4_t1), (note => E5,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => Fs5, time_t => ov4_t1), (note => Cs5, time_t => ov4_t1),
		(note => E5,  time_t => ov4_t1), (note => D5,  time_t => ov4_t2), 
		(note => PAUSE, time_t => ov4_t1),
		(note => B4,  time_t => ov4_t1), (note => Cs4, time_t => ov4_t1), 
		(note => D5,  time_t => ov4_t1), (note => D5,  time_t => ov4_t2),
		(note => PAUSE, time_t => ov4_t1),
		(note => B4,  time_t => ov4_t1), (note => D5,  time_t => ov4_t1), 
		(note => B4,  time_t => ov4_t1), (note => Cs5, time_t => ov4_t1), 
		(note => PAUSE, time_t => ov4_t1),
		(note => Cs5, time_t => ov4_t1), (note => D5,  time_t => ov4_t1),
		(note => E5,  time_t => ov4_t1), (note => E5,  time_t => ov4_t2), 
		(note => D5,  time_t => ov4_t2)
	);

	--Zelda
	constant music4 : vetor_zelda := (
		(note => PAUSE, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1), 
		(note => E5, time_t => ov1_t1), (note => D5, time_t => ov1_t1), (note => B4, time_t => ov1_t1), 
		(note => C5, time_t => ov1_t1), (note => B4, time_t => ov1_t1), (note => G4, time_t => ov1_t2), 
		(note => E4, time_t => ov1_t1), (note => D4, time_t => ov1_t1), (note => E4, time_t => ov1_t1), 
		(note => G4, time_t => ov1_t2), (note => E4, time_t => ov1_t1_2), 
		(note => PAUSE, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1),
		(note => F4, time_t => ov1_t1), (note => A4, time_t => ov1_t1), (note => B4, time_t => ov1_t1), 
		(note => E5, time_t => ov1_t1), (note => D5, time_t => ov1_t1), (note => B4, time_t => ov1_t1), 
		(note => C5, time_t => ov1_t1), (note => E5, time_t => ov1_t1), (note => B4, time_t => ov1_t2), 
		(note => G4, time_t => ov1_t1), (note => B4, time_t => ov1_t1), (note => G4, time_t => ov1_t1), 
		(note => D4, time_t => ov1_t2), (note => E4, time_t => ov1_t1)
	);
	--FSM
	signal current_state : integer range 0 to 41 := 0; --Zelda - Lost Woods
	signal next1         : integer range 0 to 32 := 0; --A-ha - Take On Me
	signal current_music : std_logic_vector(1 downto 0) := "00";
	
begin
	L1: process(clk_in)
	begin
		if rising_edge(clk_in) then 
			current_state <= next1;
			current_music <= selection;
		end if;
	end process L1;
	
	L2: process(current_state, duration, stop_in, play_in, selection, current_music)
 	variable limit : integer;
 	begin
  		-- Select the vector limit according to the music.
  		case selection is
    		when "00" => limit := 32; -- A-ha - Take On Me
    		when "01" => limit := 56; -- Pokemon - Cerulean Theme
    		when "10" => limit := 54; -- Frank Sinatra - My Way
    		when "11" => limit := 41; -- Zelda - Lost Woods
		end case;
	
		if selection /= current_music then
  			next1 <= 0;
  		elsif stop_in = '1' then
  			next1 <= 0;
  		else
  			if (duration = '0' and play_in = '1') then
  				if (current_state = limit) then
  					next1 <= 0; 
  				else
  					next1 <= current_state + 1; 
  				end if;
  			else
  				next1 <= current_state; 
  			end if;
  		end if;
	end process L2;
 
	L3: process (clk_in)
	begin
		if rising_edge(clk_in) then
			if play_in = '0' then
			 	note(PAUSE, 0);  -- buzzer stopped
			else
				case selection is
				when "00" =>
				    note(music1(current_state).note, music1(current_state).time_t);
				when "01" =>
				    note(music2(current_state).note, music2(current_state).time_t);
				when "10" =>
				    note(music3(current_state).note, music3(current_state).time_t);
				when OTHERS =>
				    note(music4(current_state).note, music4(current_state).time_t);
				end case;
			end if;
		end if;
	end process L3;

	clk_out <= duration and clk_in;
  
end arc;