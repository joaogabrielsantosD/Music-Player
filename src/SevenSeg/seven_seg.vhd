LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity seven_seg is
   port ( 
      clk      : in  std_logic;
      data_in  : in  std_logic_vector(15 downto 0);
      dig      : out std_logic_vector(3 downto 0);
      seg      : out std_logic_vector(7 downto 0)
   );
end seven_seg;

architecture bhv of seven_seg is 
	signal temp_value_unsigned : std_logic_vector(7 downto 0);
	signal temp_value_signed   : std_logic_vector(7 downto 0);
	
	signal negative : std_logic := '0';
	
	signal digit_hundred : integer range 0 to 9 := 0;
	signal digit_tens    : integer range 0 to 9 := 0;
	signal digit_units   : integer range 0 to 9 := 0;
	
	-- Frequency divider
   constant Freq_In_c   : integer := 50000000; -- 	FPGA Clock (50 MHz)
   constant Freq_Out_c  : integer := 10000;    -- Desired frequency -> 10 KHz
   constant NumPulsos_c : integer := Freq_In_c / (Freq_Out_c * 2);
   constant Overflow_c  : integer := NumPulsos_c - 1;
	
   -- Multiplexer
   signal Toggle_s : std_logic := '0';
   signal seletor  : integer range 0 to 3 := 0; -- flag for the displays

	function decode(digit : integer) return std_logic_vector is
		variable seg_v : std_logic_vector(7 downto 0);
	begin
		case digit is
		when 0 => seg_v := "11000000";
		when 1 => seg_v := "11111001";
		when 2 => seg_v := "10100100";
		when 3 => seg_v := "10110000";
		when 4 => seg_v := "10011001";
		when 5 => seg_v := "10010010";
		when 6 => seg_v := "10000010";
		when 7 => seg_v := "11111000";
		when 8 => seg_v := "10000000";
		when 9 => seg_v := "10011000";
		when others => seg_v := "11000000";
		end case;
		
		return seg_v;
	end function;
	
BEGIN
	temp_value_unsigned <= std_logic_vector(to_unsigned(to_integer(unsigned(data_in(14 downto 7))), 8));
	temp_value_signed   <= std_logic_vector(abs(to_signed(to_integer(signed(data_in(14 downto 7))), 8)));

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
   begin
      if rising_edge(Toggle_s) then
         if seletor < 3 then
            seletor <= seletor + 1;
         else
            seletor <= 0;
         end if;
			
			if data_in(15) = '1' then 				-- negative value
				negative <= '1'; 						-- active the point
				digit_hundred <= to_integer(unsigned(temp_value_signed)) / 100;
				digit_tens    <= (to_integer(unsigned(temp_value_signed)) / 10) mod 10;
				digit_units   <= to_integer(unsigned(temp_value_signed)) mod 10;			
			else
				negative <= '0';
				digit_hundred <= to_integer(unsigned(temp_value_unsigned)) / 100;
				digit_tens    <= (to_integer(unsigned(temp_value_unsigned)) / 10) mod 10;
				digit_units   <= to_integer(unsigned(temp_value_unsigned)) mod 10; 
			end if;

         case seletor is
            when 0 => 
					dig <= "0111";
					seg <= "1" & (not negative) & "111111"; 

				when 1 =>
               dig <= "1011";
					seg <= decode(digit_hundred);

            when 2 =>
               dig <= "1101";
					seg <= decode(digit_tens);

            when 3 =>
               dig <= "1110";
					seg <= decode(digit_units);
         end case;
      end if;
   end process;
	
end bhv;

