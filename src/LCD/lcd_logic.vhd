library ieee;
use ieee.std_logic_1164.all;
use work.lcd_vhdl_package.all;

entity lcd_logic is
--  GENERIC (
--	   music_test   : std_logic_vector (1 downto 0) := "01";
--		minute_test  : std_logic_vector (3 downto 0) := "0001"; -- Digit 1
--      dez_sec_test : std_logic_vector (3 downto 0) := "0010"; -- Digit 2
--      uni_sec_test : std_logic_vector (3 downto 0) := "0011"; -- Digit 3
--      dec_sec_test : std_logic_vector (3 downto 0) := "0100"  -- Digit 4
--  	);
  
  port ( 	
		clk      : in  std_logic;  -- Main clock			
		lcd_busy : in  std_logic;  -- Controller feedback (1)busy/(0)available
		
		music   		: in  std_logic_vector (1 downto 0); -- For four songs
		music_state : in  std_logic_vector (1 downto 0); -- Buttons
		
		minute   : in  std_logic_vector (3 downto 0); -- Current time signals
		dez_sec  : in  std_logic_vector (3 downto 0);
		uni_sec  : in  std_logic_vector (3 downto 0);
		dec_sec  : in  std_logic_vector (3 downto 0);
		
		lcd_e 	: out std_logic;  -- Holds data in the LCD controller
		lcd_bar	: out std_logic_vector (9 downto 0)  -- (9) rs (8) rw (7..0) char data
	);
end entity;

architecture bhv of lcd_logic is
	-- Registers
	signal lcd_enable : std_logic;
	signal lcd_bus    : std_logic_vector (9 downto 0);
	
	-- Display data bus
	signal L1 : std_logic_vector (127 downto 0);
	signal L2 : std_logic_vector (127 downto 0);
	
	-- constants with song names (line 1) - 16 characters               
	constant music_1 : std_logic_vector (127 downto 0) := to_std_logic_vector("   TAKE ON ME   ");
	constant music_2 : std_logic_vector (127 downto 0) := to_std_logic_vector(" CERULEAN THEME ");
	constant music_3 : std_logic_vector (127 downto 0) := to_std_logic_vector("     MY WAY     ");
	constant music_4 : std_logic_vector (127 downto 0) := to_std_logic_vector("   LOST WOODS   ");
	
	-- constants with composer names (line 2) - 7 characters
	constant composer_1 : std_logic_vector (55 downto 0) := to_std_logic_vector(" A-HA  ");
	constant composer_2 : std_logic_vector (55 downto 0) := to_std_logic_vector("POKEMON");
	constant composer_3 : std_logic_vector (55 downto 0) := to_std_logic_vector("SinATRA");
	constant composer_4 : std_logic_vector (55 downto 0) := to_std_logic_vector(" ZELDA ");
	
	constant two_points   : std_logic_vector (7 downto 0)   := x"3A";         -- ASCII for ':'
	constant play         : std_logic_vector (15 downto 0)  := x"3E" & x"20"; -- ASCII for '>'
	constant pause        : std_logic_vector (15 downto 0)  := x"FF" & x"20"; -- full block
	constant stop         : std_logic_vector (15 downto 0)  := x"3D" & x"20"; -- '='
	
	--constant controles    : std_logic_vector (23 downto 0) := play & pause & stop;
	signal current_time   : std_logic_vector (55 downto 0);
	signal control_status : std_logic_vector (15 downto 0);
	
	
begin
	-- Continuous assignment of registered outputs
	lcd_e <= lcd_enable;
	lcd_bar <= lcd_bus; 
	
	current_time <= x"20" & "0011" & minute & two_points & "0011" & dez_sec & "0011" & uni_sec & two_points & "0011" & dec_sec; 
	
	with music_state select
		control_status <= play  when "01",
		                  pause when "10",
						      stop  when others;
	 
	process(music, control_status, current_time) 
   begin
      case music is
         when "00" => 
            L1 <= music_1;
            L2 <= control_status & composer_1 & current_time;
         when "01" => 
            L1 <= music_2;
            L2 <= control_status & composer_2 & current_time;
         when "10" => 
            L1 <= music_3;
            L2 <= control_status & composer_3 & current_time;
         when "11" => 
            L1 <= music_4;
            L2 <= control_status & composer_4 & current_time;
         when others => 
            L1 <= (others => '0');
            L2 <= (others => '0');
      end case;
   end process;
	 
	-- Sequencing of each character transmission from L1 and L2
	process(clk)
		variable char  :  integer range 0 to 34 := 0; --6 bits
		begin
			if rising_edge(clk) then
				if (lcd_busy = '0' and lcd_enable = '0') then
					lcd_enable <= '1'; --enable LCD
					
					if (char < 34) then
						char := char + 1; --increment state
					else 
						char := 0; --reset state
					end if;
					
					case char is --check current state
						when 0  => lcd_bus <= "00" & "10000000"; --line 1 instruction
						when 1  => lcd_bus <= "10" & L1(127 downto 120); --first char of line 1
						when 2  => lcd_bus <= "10" & L1(119 downto 112);
						when 3  => lcd_bus <= "10" & L1(111 downto 104);
						when 4  => lcd_bus <= "10" & L1(103 downto 96);
						when 5  => lcd_bus <= "10" & L1(95 downto 88);
						when 6  => lcd_bus <= "10" & L1(87 downto 80);
						when 7  => lcd_bus <= "10" & L1(79 downto 72);
						when 8  => lcd_bus <= "10" & L1(71 downto 64);
						when 9  => lcd_bus <= "10" & L1(63 downto 56);
						when 10 => lcd_bus <= "10" & L1(55 downto 48);
						when 11 => lcd_bus <= "10" & L1(47 downto 40);
						when 12 => lcd_bus <= "10" & L1(39 downto 32);
						when 13 => lcd_bus <= "10" & L1(31 downto 24);
						when 14 => lcd_bus <= "10" & L1(23 downto 16);
						when 15 => lcd_bus <= "10" & L1(15 downto 8);
						when 16 => lcd_bus <= "10" & L1(7 downto 0); --last char of line 1
						
						when 17 => lcd_bus <= "00" & "11000000"; --line 2 instruction
						
						when 18 => lcd_bus <= "10" & L2(127 downto 120); --first char of line 2
						when 19 => lcd_bus <= "10" & L2(119 downto 112);
						when 20 => lcd_bus <= "10" & L2(111 downto 104);
						when 21 => lcd_bus <= "10" & L2(103 downto 96);
						when 22 => lcd_bus <= "10" & L2(95 downto 88);
						when 23 => lcd_bus <= "10" & L2(87 downto 80);
						when 24 => lcd_bus <= "10" & L2(79 downto 72);
						when 25 => lcd_bus <= "10" & L2(71 downto 64);
						when 26 => lcd_bus <= "10" & L2(63 downto 56);
						when 27 => lcd_bus <= "10" & L2(55 downto 48);
						when 28 => lcd_bus <= "10" & L2(47 downto 40);
						when 29 => lcd_bus <= "10" & L2(39 downto 32);
						when 30 => lcd_bus <= "10" & L2(31 downto 24);
						when 31 => lcd_bus <= "10" & L2(23 downto 16);
						when 32 => lcd_bus <= "10" & L2(15 downto 8);
						when 33 => lcd_bus <= "10" & L2(7 downto 0); --last char of line 2			 
						
						when others => lcd_enable <= '0'; --disable LCD
					end case;
				else
					lcd_enable <= '0'; --disable LCD
				end if;
			end if;
	end process;
end bhv;