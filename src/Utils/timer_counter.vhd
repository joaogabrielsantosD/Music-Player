library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_counter is
  port (
		clk     : in  std_logic;
		rst_n   : in  std_logic;
		enable  : in  std_logic;
		clear   : in  std_logic;
		minute  : out std_logic_vector(3 downto 0);
		dez_sec : out std_logic_vector(3 downto 0);
		uni_sec : out std_logic_vector(3 downto 0);
		dec_sec : out std_logic_vector(3 downto 0)
  );
end entity;

architecture bhv of timer_counter is
  constant DEC_SEC_COUNT : integer := 5000000;  -- 50MHz * 0.1s = 5,000,000
  signal cnt_div         : integer range 0 to DEC_SEC_COUNT - 1 := 0;
  signal dec_sec_int     : integer range 0 to 9 := 0;
  signal uni_sec_int     : integer range 0 to 9 := 0;
  signal dez_sec_int     : integer range 0 to 5 := 0;
  signal minute_int      : integer range 0 to 9 := 0;
begin

   process(clk, rst_n)
   begin
		if rst_n = '0' then
			cnt_div      <= 0;
			dec_sec_int  <= 0;
			uni_sec_int  <= 0;
			dez_sec_int  <= 0;
			minute_int   <= 0;
		elsif rising_edge(clk) then
			if clear = '1' then
				cnt_div      <= 0;
				dec_sec_int  <= 0;
				uni_sec_int  <= 0;
				dez_sec_int  <= 0;
				minute_int   <= 0;
			elsif enable = '1' then
				if cnt_div < DEC_SEC_COUNT - 1 then
					cnt_div <= cnt_div + 1;
				else
					cnt_div <= 0;
					-- increments tenths of a second
					if dec_sec_int < 9 then
						dec_sec_int <= dec_sec_int + 1;
					else
						dec_sec_int <= 0;
						-- increments by one second
						if uni_sec_int < 9 then
							uni_sec_int <= uni_sec_int + 1;
						else
							uni_sec_int <= 0;
							-- increments by tens of seconds
							if dez_sec_int < 5 then
								dez_sec_int <= dez_sec_int + 1;
							else
								dez_sec_int <= 0;
								-- increment minute
								if minute_int < 9 then
									minute_int <= minute_int + 1;
								else
									minute_int <= 0;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
   end process;

  minute  <= std_logic_vector(to_unsigned(minute_int, 4));
  dez_sec <= std_logic_vector(to_unsigned(dez_sec_int, 4));
  uni_sec <= std_logic_vector(to_unsigned(uni_sec_int, 4));
  dec_sec <= std_logic_vector(to_unsigned(dec_sec_int, 4));

end bhv;