library ieee;
use ieee.std_logic_1164.all;

entity lcd_controller is
  generic (
		clk_freq       :  integer    := 50;    -- main clock in MHz
		display_lines  :  std_logic  := '1';   -- number of display lines (0 = one line, 1 = two lines)
		character_font :  std_logic  := '0';   -- font (0 = 5x8 dots, 1 = 5x10 dots)
		display_on_off :  std_logic  := '1';   -- display on/off (0 = off, 1 = on)
		cursor         :  std_logic  := '0';   -- cursor on/off (0 = off, 1 = on)
		blink          :  std_logic  := '0';   -- blink on/off (0 = off, 1 = on)
		inc_dec        :  std_logic  := '1';   -- increment/decrement (0 = decrement, 1 = increment)
		shift          :  std_logic  := '0'    -- shift on/off (0 = off, 1 = on)
	);
  
	port(
		clk        : in   std_logic; 						  -- main clock
		reset_n    : in   std_logic;                     -- active-low, resets the LCD
		lcd_enable : in   std_logic;                     -- holds data in the LCD controller
		lcd_bus    : in   std_logic_vector(9 downto 0);  -- (9) rs (8) rw (7..0) char data
		busy       : out  std_logic := '1';              -- controller feedback (1)busy/(0)available
		rw, rs, e  : out  std_logic;                     -- read/write, instruction/data, active-high LCD enable
		lcd_data   : out  std_logic_vector(7 downto 0)   -- data signal (char) to the LCD
	);
end entity;

architecture bhv of lcd_controller is
	--FSM state_t declaration
	type state_t is (POWER, INIT, READY, SEND);
	signal  state  : state_t;
begin
	--FSM
	process(clk)
		variable clk_count : integer := 0; --counter for event timing
	begin
		if rising_edge(clk) then
			--reset the FSM
			if (reset_n = '0') then
				state <= POWER;
			end if;
			
			case state is
         -- waits 50ms to ensure LCD power stabilization
			when POWER =>
				busy <= '1';
				if (clk_count < (50000 * clk_freq)) then    --wait 50 ms
					clk_count := clk_count + 1;
					state <= POWER;
				else                                       --power-up complete
					clk_count := 0;
					rs <= '0';
					rw <= '0';
					lcd_data <= "00110000"; --8-bits 1L*16 5*8 function_set
					state <= INIT;
				end if;
			--LCD display initialization sequence  
			when INIT =>
				busy <= '1'; --LCD busy
				clk_count := clk_count + 1;
				if (clk_count < (10 * clk_freq)) then       --function set
					lcd_data <= "0011" & display_lines & character_font & "00";
					e <= '1'; --enable LCD (execute command)
					state <= INIT;
				elsif (clk_count < (60 * clk_freq)) then    --wait 50 us
					lcd_data <= "00000000"; --no new instruction, just wait
					e <= '0'; --disable LCD
					state <= INIT;
				elsif (clk_count < (70 * clk_freq)) then    --display on/off control
					lcd_data <= "00001" & display_on_off & cursor & blink;
					e <= '1'; --enable LCD (execute command)
					state <= INIT;
				elsif (clk_count < (120 * clk_freq)) then   --wait 50 us
					lcd_data <= "00000000";
					e <= '0';
					state <= INIT;
				elsif (clk_count < (130 * clk_freq)) then   --display clear
					lcd_data <= "00000001";
					e <= '1'; --enable LCD (execute command)
					state <= INIT;
				elsif (clk_count < (2130 * clk_freq)) then  --wait 2 ms
					lcd_data <= "00000000";
					e <= '0';
					state <= INIT;
				elsif (clk_count < (2140 * clk_freq)) then  --entry mode set
					lcd_data <= "000001" & inc_dec & shift;
					e <= '1'; --enable LCD (execute command)
					state <= INIT;
				elsif (clk_count < (2200 * clk_freq)) then  --wait 60 us
					lcd_data <= "00000000";
					e <= '0';
					state <= INIT;
				else                                       --initialization complete
					clk_count := 0;
					busy <= '0';
					state <= READY;
				end if;    
			--wait for the enable signal and then latch the instruction
			when READY =>
				if (lcd_enable = '1') then
					busy <= '1';
					rs <= lcd_bus(9);
					rw <= lcd_bus(8);
					lcd_data <= lcd_bus(7 downto 0);
					clk_count := 0;            
					state <= SEND;
				else
					busy <= '0';
					rs <= '0';
					rw <= '0';
					lcd_data <= "00000000";
					clk_count := 0;
					state <= READY;
				end if;			
			--send instruction to the LCD
			when SEND =>
				busy <= '1'; --LCD busy
				if (clk_count < (50 * clk_freq)) then       --wait 50 us
					if (clk_count < clk_freq) then            --negative enable
						e <= '0'; --disable LCD
					elsif (clk_count < (14 * clk_freq)) then  --positive enable in half cycle (25us)
						e <= '1'; --enable LCD (execute command)
					elsif (clk_count < (27 * clk_freq)) then  --negative enable in the other half cycle (25us)
						e <= '0'; --disable LCD
					end if;
					clk_count := clk_count + 1;
					state <= SEND;
				else
					clk_count := 0;
					state <= READY;
				end if;	
			end case;        
		end if;
	end process;
end bhv;