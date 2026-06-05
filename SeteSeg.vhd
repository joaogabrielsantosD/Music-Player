LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SeteSeg IS
    PORT ( 
        clk      : IN STD_LOGIC;
        data_in  : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        dig      : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        seg      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END SeteSeg;

ARCHITECTURE bhv OF SeteSeg IS

    -- Sinais para cálculo
    SIGNAL dezena  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL unidade : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
	 -- Divisir de frequência 
    CONSTANT Freq_In_c   : INTEGER := 50000000; -- Clock da FPGA (50 MHz)
    CONSTANT Freq_Out_c  : INTEGER := 10000;    -- Frequência desejada -> 10 KHz
    CONSTANT NumPulsos_c : INTEGER := Freq_In_c / (Freq_Out_c * 2);
    CONSTANT Overflow_c  : INTEGER := NumPulsos_c - 1;
    
    -- Multiplexador
    SIGNAL Toggle_s : STD_LOGIC := '0';
    SIGNAL seletor  : INTEGER RANGE 0 TO 3 := 0; -- flag para os displays

BEGIN
	 -- Processamento da entrada (dezenda + unidade)
    dezena  <= STD_LOGIC_VECTOR(to_unsigned(TO_INTEGER(UNSIGNED(data_in)) / 10, 4));   -- divisão por 10
    unidade <= STD_LOGIC_VECTOR(to_unsigned(TO_INTEGER(UNSIGNED(data_in)) MOD 10, 4)); -- resto da divisão por 10 (mod 10)

    -- Divisor de freq.
    PROCESS(clk)
        VARIABLE Cnt_v : INTEGER RANGE 0 TO Overflow_c := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF Cnt_v = Overflow_c THEN
                Cnt_v := 0; -- reinicia
                Toggle_s <= NOT Toggle_s; -- alterna
            ELSE
                Cnt_v := Cnt_v + 1; -- incrementa
					 Toggle_s <= Toggle_s;
            END IF;
        END IF;
    END PROCESS;
	 
    PROCESS(Toggle_s)
    BEGIN
        IF rising_edge(Toggle_s) THEN
            IF seletor < 3 THEN
                seletor <= seletor + 1;
            ELSE
                seletor <= 0;
            END IF;

            CASE seletor IS
                -- Display 0 (Dezena)
                WHEN 0 => 
                    dig <= "0111";
                    CASE dezena IS
                        WHEN "0000" => seg <= "00000011"; -- 0
                        WHEN "0001" => seg <= "10011111"; -- 1
                        WHEN "0010" => seg <= "00100101"; -- 2
                        WHEN "0011" => seg <= "00001101"; -- 3
                        WHEN "0100" => seg <= "10011001"; -- 4
                        WHEN "0101" => seg <= "01001001"; -- 5
                        WHEN "0110" => seg <= "01000001"; -- 6
                        WHEN "0111" => seg <= "00011111"; -- 7
                        WHEN "1000" => seg <= "00000001"; -- 8
                        WHEN "1001" => seg <= "00011001"; -- 9
                        WHEN OTHERS => seg <= "11111111"; -- Desligado
                    END CASE;

                -- Display 1 (Unidade)
                WHEN 1 =>
                    dig <= "1011";
                    CASE unidade IS
                        WHEN "0000" => seg <= "00000011"; -- 0
                        WHEN "0001" => seg <= "10011111"; -- 1
                        WHEN "0010" => seg <= "00100101"; -- 2
                        WHEN "0011" => seg <= "00001101"; -- 3
                        WHEN "0100" => seg <= "10011001"; -- 4
                        WHEN "0101" => seg <= "01001001"; -- 5
                        WHEN "0110" => seg <= "01000001"; -- 6
                        WHEN "0111" => seg <= "00011111"; -- 7
                        WHEN "1000" => seg <= "00000001"; -- 8
                        WHEN "1001" => seg <= "00011001"; -- 9
                        WHEN OTHERS => seg <= "11111111"; -- Desligado
                    END CASE;

                -- Display 2 (Símbolo de Grau)
                WHEN 2 =>
                    dig <= "1101"; 
                    seg <= "00111001"; -- °

                -- Display 3 (Letra C)
                WHEN 3 =>
                    dig <= "1110"; 
                    seg <= "01100011"; -- C
                    
            END CASE;
        END IF;
    END PROCESS;
             
END bhv;