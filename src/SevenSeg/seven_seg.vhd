library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg is
	--generic (example : std_logic_vector(15 downto 0) := b"0111110100000000"); -- +125.0°C
	--generic (example : std_logic_vector(15 downto 0) := b"0001100100000000"); -- +25.0°C
	--generic (example : std_logic_vector(15 downto 0) := b"0000000010000000"); -- +0.5°C
	--generic (example : std_logic_vector(15 downto 0) := b"1111111110000000"); -- -0.5°C
	--generic (example : std_logic_vector(15 downto 0) := b"1110011100000000"); -- -25.0°C
	--generic (example : std_logic_vector(15 downto 0) := b"1100100100000000"); -- -55.0°C
   port ( 
      clk      : in  std_logic;
      data_in  : in  std_logic_vector(15 downto 0);
      dig      : out std_logic_vector(3 downto 0);
      seg      : out std_logic_vector(7 downto 0)
   );
end entity;

architecture bhv of seven_seg is 
	signal temp_raw_signed   : signed(8 downto 0);
	signal temp_raw_unsigned : unsigned(8 downto 0);
	
	signal negative : std_logic := '0';
	
	-- Frequency divider
   constant Freq_In_c   : integer := 50000000; -- 	FPGA Clock (50 MHz)
   constant Freq_Out_c  : integer := 10000;    -- Desired frequency -> 10 KHz
   constant NumPulsos_c : integer := Freq_In_c / (Freq_Out_c * 2);
   constant Overflow_c  : integer := NumPulsos_c - 1;
	
   -- Multiplexer
   signal Toggle_s : std_logic := '0';
   signal selector : integer range 0 to 3 := 0; -- flag for the displays

	function decode(digit : integer) return std_logic_vector is
		variable seg_v : std_logic_vector(6 downto 0);
	begin
		case digit is
		when 0 => seg_v := "1000000";
		when 1 => seg_v := "1111001";
		when 2 => seg_v := "0100100";
		when 3 => seg_v := "0110000";
		when 4 => seg_v := "0011001";
		when 5 => seg_v := "0010010";
		when 6 => seg_v := "0000010";
		when 7 => seg_v := "1111000";
		when 8 => seg_v := "0000000";
		when 9 => seg_v := "0011000";
		when others => seg_v := "1000000";
		end case;
		
		return seg_v;
	end function;
	
begin
	negative <= data_in(15);
	temp_raw_signed   <= signed(data_in(15 downto 7));
	temp_raw_unsigned <= unsigned(data_in(15 downto 7));

   -- Frequency divider
   process(clk)
      variable Cnt_v : integer range 0 to Overflow_c := 0;	
	begin
		if rising_edge(clk) then
			if Cnt_v = Overflow_c then
				Cnt_v := 0; -- restart
				Toggle_s <= not Toggle_s; -- toggle
			else
				Cnt_v := Cnt_v + 1; -- increment
				Toggle_s <= Toggle_s;
			end if;
		end if;
   end process;
	
   process(Toggle_s)
		variable temp_abs  : integer range -32768 to 32767 := 0;
		variable temp 		 : integer range -32768 to 32767 := 0;
		variable temp_frac : integer range -32768 to 32767 := 0;
		
		variable digit_h : integer range 0 to 9 := 0;
		variable digit_t : integer range 0 to 9 := 0;
		variable digit_u : integer range 0 to 9 := 0;
		variable digit_f : integer range 0 to 9 := 0;
   begin
      if rising_edge(Toggle_s) then
         if selector < 3 then
            selector <= selector + 1;
         else
            selector <= 0;
         end if;
			
			if negative = '1' then
				temp_abs := to_integer(abs(temp_raw_signed));
			else
				temp_abs := to_integer(temp_raw_unsigned);
			end if;
			
			temp := temp_abs / 2;
			temp_frac := temp_abs mod 2; -- flag
			
			digit_h := temp / 100;
			digit_t := (temp / 10) mod 10;
			digit_u := temp mod 10;
			digit_f := temp_frac * 5; -- LM75A resolution (0.5°C)
			
         case selector is
            when 0 => 
					dig <= "0111";
					seg <= (not negative) & decode(digit_h);
					
				when 1 =>
               dig <= "1011";
					seg <= "1" & decode(digit_t);
					
            when 2 =>
               dig <= "1101";
					seg <= "0" & decode(digit_u);
					
            when 3 =>
               dig <= "1110";
					seg <= "1" & decode(digit_f);
         end case;
      end if;
   end process;

end bhv;

