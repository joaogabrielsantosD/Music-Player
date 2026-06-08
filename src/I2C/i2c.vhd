library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c is
   port (
      clk   : in    std_logic;                    -- main FPGA clock 50MHz  
		rst_n : in    std_logic;                    -- Asynchronous reset (active-low) 
      scl   : out   std_logic;                    -- SCL (I2C bus clock)  
      sda   : inout std_logic;                    -- SDA (I2C data bus)  
      data  : out   std_logic_vector(15 downto 0) -- Temperature data  
   );
end entity i2c;

architecture Behavioral of i2c is

   -- Register Declarations
   signal data_r    : std_logic_vector(15 downto 0); -- Temperature data register
   signal sda_r     : std_logic;                     -- SDA register 
   signal sda_link  : std_logic;                     -- SDA direction flag (in/out)
   signal scl_cnt   : unsigned(7 downto 0);          -- Counter to generate SCL clock
   signal cnt       : unsigned(2 downto 0);          -- Auxiliary counter for SCL clock
   signal timer_cnt : unsigned(25 downto 0);         -- Timer to read temperature every 1s  
   signal data_cnt  : unsigned(3 downto 0);          -- Serial-to-parallel conversion register
   signal addr_reg  : std_logic_vector(7 downto 0);  -- I2C device address
   signal state     : std_logic_vector(8 downto 0);  -- State register

   -- Constants equivalent to Verilog defines
   constant CNT_OVER       : unsigned(7 downto 0)  := to_unsigned(199, 8);
   constant TIMER_OVER     : unsigned(25 downto 0) := to_unsigned(49999999, 26);
   constant DEVICE_ADDRESS : std_logic_vector(7 downto 0) := "10010001";

   -- FSM Constants (one-hot format)
   constant IDLE    : std_logic_vector(8 downto 0) := "000000000";  
   constant START   : std_logic_vector(8 downto 0) := "000000010"; -- start communication
   constant ADDRESS : std_logic_vector(8 downto 0) := "000000100"; -- send address 
   constant ACK1    : std_logic_vector(8 downto 0) := "000001000"; -- slave acknowledgment 
   constant READ1   : std_logic_vector(8 downto 0) := "000010000"; -- read 1-byte MSB 
   constant ACK2    : std_logic_vector(8 downto 0) := "000100000"; -- master acknowledgment 
   constant READ2   : std_logic_vector(8 downto 0) := "001000000"; -- read 1-byte LSB
   constant NACK    : std_logic_vector(8 downto 0) := "010000000"; -- master does not acknowledge
   constant STOP    : std_logic_vector(8 downto 0) := "100000000"; -- end communication

   -- Logical signals for SCL transitions
   signal SCL_HIG : boolean;
   signal SCL_NEG : boolean;
   signal SCL_LOW : boolean;
   signal SCL_POS : boolean;

begin

   -- Continuous assignments
   sda  <= sda_r when sda_link = '1' else 'Z'; -- infers tri-state
   data <= data_r;                             -- updates output with read data

   -- Mapping of SCL clock conditions
   SCL_HIG <= (cnt = to_unsigned(1, 3)); -- SCL high level (1us)
   SCL_NEG <= (cnt = to_unsigned(2, 3)); -- SCL falling edge (2us) 
   SCL_LOW <= (cnt = to_unsigned(3, 3)); -- SCL low level (3us)
   SCL_POS <= (cnt = to_unsigned(0, 3)); -- SCL rising edge (4us) 

   -- BEGIN: B1 - Clock generation for SCL bus
   B1_PROCESS : process(clk, rst_n)
   begin
      if rst_n = '0' then
         scl_cnt <= (others => '0');
      elsif rising_edge(clk) then
         if scl_cnt = CNT_OVER then -- 4us (min 2.5ns)
            scl_cnt <= (others => '0');
         else
            scl_cnt <= scl_cnt + 1;
         end if;
      end if;
   end process B1_PROCESS;

   -- BEGIN: B2 - Defines transitions and levels of SCL clock
   B2_PROCESS : process(clk, rst_n)
   begin
      if rst_n = '0' then
         cnt <= to_unsigned(4, 3);
      elsif rising_edge(clk) then
         case scl_cnt is
            when to_unsigned(49, 8)  => cnt <= to_unsigned(1, 3); -- SCL high level  (1us)
            when to_unsigned(99, 8)  => cnt <= to_unsigned(2, 3); -- falling edge (2us)
            when to_unsigned(149, 8) => cnt <= to_unsigned(3, 3); -- SCL low level  (3us)
            when to_unsigned(199, 8) => cnt <= to_unsigned(0, 3); -- rising edge (4us)
            when others              => cnt <= to_unsigned(4, 3); -- undefined SCL
         end case;
      end if;
   end process B2_PROCESS;

   -- BEGIN: B3 - Produces the clock signal on SCL output
   B3_PROCESS : process(clk, rst_n)
   begin
      if rst_n = '0' then
         scl <= '0';
      elsif rising_edge(clk) then
         if SCL_POS then
            scl <= '1'; -- after rising edge, scl high
         elsif SCL_NEG then
            scl <= '0'; -- after falling edge, scl low
         end if;
      end if;
   end process B3_PROCESS;

   -- BEGIN: B4 - Timer for reading every 1s
   B4_PROCESS : process(clk, rst_n)
   begin
      if rst_n = '0' then
         timer_cnt <= (others => '0');
      elsif rising_edge(clk) then
         if timer_cnt = TIMER_OVER then
            timer_cnt <= (others => '0');
         else
            timer_cnt <= timer_cnt + 1;
         end if;
      end if;
   end process B4_PROCESS;

   -- BEGIN: B5 - I2C FSM
   B5_PROCESS : process(clk, rst_n)
   begin
      if rst_n = '0' then
			data_r   <= (others => '0');
         sda_r    <= '1';
         sda_link <= '1';
         state   <= IDLE;
         addr_reg <= (others => '0');
         data_cnt <= (others => '0');
      elsif rising_edge(clk) then
         case state is
            when IDLE =>
               sda_r    <= '1';
               sda_link <= '1';
               if timer_cnt = TIMER_OVER then
                   state <= START;
               else
                   state <= IDLE;
               end if;

            when START =>
               if SCL_HIG then
                   sda_r    <= '0';
                   sda_link <= '1';
                   addr_reg <= DEVICE_ADDRESS;
                   state   <= ADDRESS;
                   data_cnt <= (others => '0');
               else
                   state <= START;
               end if;

            when ADDRESS =>
               if SCL_LOW then
                  if data_cnt = 8 then
                      state   <= ACK1;
                      data_cnt <= (others => '0');
                      sda_r    <= '1';
                      sda_link <= '0'; -- SDA high impedance (read mode)
                  else
                      state   <= ADDRESS;
                      data_cnt <= data_cnt + 1;
                      case data_cnt is
                          when "0000" => sda_r <= addr_reg(7);
                          when "0001" => sda_r <= addr_reg(6);
                          when "0010" => sda_r <= addr_reg(5);
                          when "0011" => sda_r <= addr_reg(4);
                          when "0100" => sda_r <= addr_reg(3);
                          when "0101" => sda_r <= addr_reg(2);
                          when "0110" => sda_r <= addr_reg(1);
                          when "0111" => sda_r <= addr_reg(0);
                          when others => null;
                      end case;
                  end if;
               else
                   state <= ADDRESS;
               end if;

            when ACK1 =>
               if (sda = '0' and SCL_HIG) or SCL_NEG then
                   state <= READ1;
               else
                   state <= ACK1;
               end if;

            when READ1 =>
               if SCL_LOW and (data_cnt = 8) then
                   state   <= ACK2;
                   data_cnt <= (others => '0');
                   sda_r    <= '1';
                   sda_link <= '1';
               elsif SCL_HIG then
                   data_cnt <= data_cnt + 1;
                   case data_cnt is
                       when "0000" => data_r(15) <= sda;
                       when "0001" => data_r(14) <= sda;
                       when "0010" => data_r(13) <= sda;
                       when "0011" => data_r(12) <= sda;
                       when "0100" => data_r(11) <= sda;
                       when "0101" => data_r(10) <= sda;
                       when "0110" => data_r(9)  <= sda;
                       when "0111" => data_r(8)  <= sda;
                       when others => null;
                   end case;
               else
                   state <= READ1;
               end if;

            when ACK2 =>
               if SCL_LOW then
                   sda_r <= '0';
               elsif SCL_NEG then
                   sda_r    <= '1';
                   sda_link <= '0';
                   state   <= READ2;
               else
                   state <= ACK2;
               end if;

            when READ2 =>
               if SCL_LOW and (data_cnt = 8) then
                   state   <= NACK;
                   data_cnt <= (others => '0');
                   sda_r    <= '1';
                   sda_link <= '1';
               elsif SCL_HIG then
                   data_cnt <= data_cnt + 1;
                   case data_cnt is
                       when "0000" => data_r(7) <= sda;
                       when "0001" => data_r(6) <= sda;
                       when "0010" => data_r(5) <= sda;
                       when "0011" => data_r(4) <= sda;
                       when "0100" => data_r(3) <= sda;
                       when "0101" => data_r(2) <= sda;
                       when "0110" => data_r(1) <= sda;
                       when "0111" => data_r(0) <= sda;
                       when others => null;
                   end case;
               else
                   state <= READ2;
               end if;

                when NACK =>
                    if SCL_LOW then
                        state <= STOP;
                        sda_r  <= '0';
                    else
                        state <= NACK;
                    end if;

            when STOP =>
               if SCL_HIG then
                   state <= IDLE;
                   sda_r  <= '1';
               else
                   state <= STOP;
               end if;

            when others =>
						state <= IDLE;
         end case;
      end if;
   end process B5_PROCESS;
	
end architecture Behavioral;