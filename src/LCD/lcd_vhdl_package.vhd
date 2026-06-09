library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

package lcd_vhdl_package is

	function to_std_logic_vector( s : string ) return std_logic_vector; 
	function reverse( s : string ) return string;	
	
	component lcd_controller is
    port (
      clk        : in  std_logic; 						  -- main clock
      reset_n    : in  std_logic; 						  -- active-low resets the LCD
      lcd_enable : in  std_logic; 						  -- (1) sends data to the LCD controller
      lcd_bus    : in  std_logic_vector(9 downto 0); -- instruction (9)rs, (8)rw and (7..0)char
      busy       : out std_logic; 						  -- LCD controller feedback (1)busy (0)available
      rw, rs, e  : out std_logic;                    -- read/write, instruction/data, LCD enable
      lcd_data   : out std_logic_vector(7 downto 0)  -- char sent to the LCD(D7..D0)
	); 
   end component;
	
	component lcd_logic
	port (
		clk      : in  std_logic;  -- Main clock			
		lcd_busy : in  std_logic;  -- Controller feedback (1)busy/(0)available
		
		musica   : in  std_logic_vector (1 downto 0); -- For four songs
		minuto   : in  std_logic_vector (3 downto 0); -- Time signals
		dez_seg  : in  std_logic_vector (3 downto 0);
		uni_seg  : in  std_logic_vector (3 downto 0);
		dec_seg  : in  std_logic_vector (3 downto 0);
		
		fsm_state : in  std_logic_vector (1 downto 0);
		
		lcd_e 	: out std_logic;  -- Holds data in the LCD controller
		lcd_bar	: out std_logic_vector (9 downto 0)  -- (9) rs (8) rw (7..0) char data
	);
end component;
	
end package lcd_vhdl_package;

package body lcd_vhdl_package is
	--converts a string into an array of 8-bit vectors
	function to_std_logic_vector( s : string ) return std_logic_vector  is 
		variable r : std_logic_vector( 0 to s'length * 8 - 1); --auxiliary variable for temporary storage
	begin
		for i in 1 to s'high loop --iterates through all string characters
			--converts each character into an 8-bit vector 
			--and stores it in the auxiliary variable in ascending order
			r((i - 1) * 8  to i * 8 - 1) := std_logic_vector( to_unsigned( character'POS(s(i)) , 8 ) ) ;
		end loop ;
		return r ; --returns the array of 8-bit vectors
	end function ;

	--reverses the character sequence in a string
	function reverse( s : string ) return string  is
		variable r : string(s'high downto s'low); --auxiliary variable for temporary storage
	begin
		for i in 1 to s'high loop --iterates through all string characters
			--reverses the position of each character 
			--e.g. 8bits r(7) := s(0) and r(0):= s(7)
			r(s'high + 1 - i) := s(i) ;
		end loop ;
		return r ;
	end function ;
	
end package body lcd_vhdl_package;