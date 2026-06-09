library ieee;
use ieee.std_logic_1164.all;
use ieee.fsm_pkg.all;
use ieee.i2c_pkg.all;
use ieee.seven_seg_pkg.all;
use ieee.lcd_vhdl_package.all;

entity top is
	port (
		clock : in  std_logic;
		rst_n : in std_logic;
		
		scl : out   std_logic;
		sda : inout std_logic;
		
		dig : out std_logic_vector(3 downto 0);
		seg : out std_logic_vector(7 downto 0);
		
		lcd_rs : out std_logic;
		lcd_rw : out std_logic;
		lcd_en : out std_logic;
		lcd_d  : out std_logic_vector(7 downto 0);
		
		key : in std_logic_vector(3 downto 0);
		
		led : out std_logic_vector(3 downto 0)
	);
end entity;

architecture top_level of top is
	signal temp_data : std_logic_vector(15 downto 0);
	
	signal music_selection : std_logic_vector(1 downto 0);
	signal music_fsm_state : std_logic_vector(1 downto 0);
	
	signal min  : std_logic_vector(3 downto 0);
	signal dsec : std_logic_vector(3 downto 0);
	signal usec : std_logic_vector(3 downto 0);
	signal msec : std_logic_vector(3 downto 0);
	
	signal lcd_busy : std_logic;
	signal lcd_enable_int : std_logic;
	signal lcd_bus_int    : std_logic_vector(9 downto 0);

begin
	fsm_states : fsm port map (
		clock => clock,
		rst_n => rst_n,
		key => key(0),
		button => key(3 downto 1),
		debug => led,
		music_sel => music_selection,
		music_state => music_fsm_state
	);

	temperature : i2c port map (
		clk => clock,
		rst_n => rst_n,
		scl => scl,
		sda => sda,
		data => temp_data
	);
	
	display7 : seven_seg port map (
		clk => clock,
		data_in => temp_data,
		dig => dig,
		seg => seg
	);
	
	ctrl_lcd : lcd_logic port map (
		clk => clock,
		lcd_busy => lcd_busy,
		musica => music_selection,
		minuto => min,
		dez_seg => dsec,
		uni_seg => usec,
		dec_seg => msec,
		fsm_state => music_fsm_state,
		lcd_e => lcd_enable_int,
		lcd_bar => lcd_bus_int
	);
	
	lcd_hw : lcd_controller port map (
		clk => clock,
		reset_n => rst_n,
		lcd_enable => lcd_enable_int,
		lcd_bus => lcd_bus_int,
		busy => lcd_busy,
		rw => lcd_rw,
		rs => lcd_rs,
		e => lcd_en,
		lcd_data => lcd_d
	);
	
	--led(0) <= temp_data(8);
	--led(1) <= temp_data(9);
	--led(2) <= temp_data(10);
	--led(3) <= temp_data(11);

end top_level;