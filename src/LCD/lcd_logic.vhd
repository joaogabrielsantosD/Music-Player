LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.lcd_vhdl_package.ALL;

ENTITY lcd_logic IS
  GENERIC(
	    	musica_teste  : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
			minuto_teste  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001"; -- Dígito 1
         dez_seg_teste : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; -- Dígito 2
         uni_seg_teste : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011"; -- Dígito 3
        	dec_seg_teste : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100"  -- Dígito 4
  		);
  
  PORT( 	clk      : IN  STD_LOGIC;  -- Clock principal			
			lcd_busy : IN  STD_LOGIC;  -- Feedback do controlador (1)ocupado/(0)disponível
			
			musica   : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); -- Para quatro música
			minuto   : IN  STD_LOGIC_VECTOR (3 DOWNTO 0); -- Sinais de tempo
			dez_seg  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			uni_seg  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			dec_seg  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			
			fsm_state : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); -- Botões
			
			lcd_e 	: OUT STD_LOGIC;  -- Retem os dados no controlador LCD
			lcd_bar	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)  -- (9) rs (8) rw (7..0) dado char
		);
END entity;

ARCHITECTURE bhv OF lcd_logic IS
	-- Registradores
	SIGNAL lcd_enable : STD_LOGIC;
	SIGNAL lcd_bus    : STD_LOGIC_VECTOR (9 DOWNTO 0);
	-- Barramento de dados do display
	SIGNAL L1 : STD_LOGIC_VECTOR (127 DOWNTO 0);
	SIGNAL L2 : STD_LOGIC_VECTOR (127 DOWNTO 0);
	
	-- Constantes com nomes das músicas (linha 1) - 16 caracteres               
	CONSTANT musica_1 : STD_LOGIC_VECTOR (127 DOWNTO 0) := to_std_logic_vector("   TAKE ON ME   ");
	CONSTANT musica_2 : STD_LOGIC_VECTOR (127 DOWNTO 0) := to_std_logic_vector(" CERULEAN THEME ");
	CONSTANT musica_3 : STD_LOGIC_VECTOR (127 DOWNTO 0) := to_std_logic_vector("     MY WAY     ");
	CONSTANT musica_4 : STD_LOGIC_VECTOR (127 DOWNTO 0) := to_std_logic_vector("   LOST WOODS   ");
	
	-- Constantes com nomes dos compositores (linha 2) - 7 caracteres
	CONSTANT compositor_1 : STD_LOGIC_VECTOR (55 DOWNTO 0) := to_std_logic_vector(" A-HA  ");
	CONSTANT compositor_2 : STD_LOGIC_VECTOR (55 DOWNTO 0) := to_std_logic_vector("POKEMON");
	CONSTANT compositor_3 : STD_LOGIC_VECTOR (55 DOWNTO 0) := to_std_logic_vector("SINATRA");
	CONSTANT compositor_4 : STD_LOGIC_VECTOR (55 DOWNTO 0) := to_std_logic_vector(" ZELDA ");
	
	CONSTANT dois_pontos  : STD_LOGIC_VECTOR (7 DOWNTO 0)   := x"3A";         -- ASCII para ':'
	CONSTANT play         : STD_LOGIC_VECTOR (15 DOWNTO 0)  := x"3E" & x"20"; -- ASCII para '>'
	CONSTANT pause        : STD_LOGIC_VECTOR (15 DOWNTO 0)  := x"FF" & x"20"; -- bloco cheio
	CONSTANT stop         : STD_LOGIC_VECTOR (15 DOWNTO 0)  := x"3D" & x"20"; -- '='
	--CONSTANT controles    : STD_LOGIC_VECTOR (23 DOWNTO 0) := play & pause & stop;
	SIGNAL tempo          : STD_LOGIC_VECTOR (55 DOWNTO 0);
	SIGNAL estado_atual   : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	SIGNAL control_status : STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	
BEGIN
	-- atribuição contínua das saídas registradas
	lcd_e <= lcd_enable;
	lcd_bar <= lcd_bus; 
	tempo <= x"20" & "0011" & minuto_teste & dois_pontos & "0011" & dez_seg_teste & "0011" & uni_seg_teste & dois_pontos & "0011" & dec_seg_teste; 
	estado_atual <= fsm_state;
	 
	 WITH estado_atual SELECT
		control_status <= play  WHEN "01",
		                  pause WHEN "10",
						      stop  WHEN OTHERS;
	 
	 PROCESS(musica, control_status, tempo) 
    BEGIN
        CASE musica IS
            WHEN "00" => 
                L1 <= musica_1;
                L2 <= control_status & compositor_1 & tempo;
            WHEN "01" => 
                L1 <= musica_2;
                L2 <= control_status & compositor_2 & tempo;
            WHEN "10" => 
                L1 <= musica_3;
                L2 <= control_status & compositor_3 & tempo;
            WHEN "11" => 
                L1 <= musica_4;
                L2 <= control_status & compositor_4 & tempo;
            WHEN OTHERS => 
                L1 <= (OTHERS => '0');
                L2 <= (OTHERS => '0');
        END CASE;
    END PROCESS;
	 
	--Sequenciamento do envio de cada caractere de L1 e L2
	PROCESS(clk)
		VARIABLE char  :  INTEGER RANGE 0 TO 34 := 0; --6 bits
		BEGIN
			IF rising_edge(clk) THEN
				IF (lcd_busy = '0' AND lcd_enable = '0') THEN
					lcd_enable <= '1'; --habilita o LCD
					IF (char < 34) THEN
						char := char + 1; --incrementa o estado
					ELSE 
						char := 0; --reinicia o estado
					END IF;
					CASE char IS --verifica o estado atual
						WHEN 0  => lcd_bus <= "00" & "10000000"; --inst. linha 1
						WHEN 1  => lcd_bus <= "10" & L1(127 DOWNTO 120); --prim. char da linha 1
						WHEN 2  => lcd_bus <= "10" & L1(119 DOWNTO 112);
						WHEN 3  => lcd_bus <= "10" & L1(111 DOWNTO 104);
						WHEN 4  => lcd_bus <= "10" & L1(103 DOWNTO 96);
						WHEN 5  => lcd_bus <= "10" & L1(95 DOWNTO 88);
						WHEN 6  => lcd_bus <= "10" & L1(87 DOWNTO 80);
						WHEN 7  => lcd_bus <= "10" & L1(79 DOWNTO 72);
						WHEN 8  => lcd_bus <= "10" & L1(71 DOWNTO 64);
						WHEN 9  => lcd_bus <= "10" & L1(63 DOWNTO 56);
						WHEN 10 => lcd_bus <= "10" & L1(55 DOWNTO 48);
						WHEN 11 => lcd_bus <= "10" & L1(47 DOWNTO 40);
						WHEN 12 => lcd_bus <= "10" & L1(39 DOWNTO 32);
						WHEN 13 => lcd_bus <= "10" & L1(31 DOWNTO 24);
						WHEN 14 => lcd_bus <= "10" & L1(23 DOWNTO 16);
						WHEN 15 => lcd_bus <= "10" & L1(15 DOWNTO 8);
						WHEN 16 => lcd_bus <= "10" & L1(7 DOWNTO 0); --ult char da linha 1
						WHEN 17 => lcd_bus <= "00" & "11000000"; --inst. linha 2
						WHEN 18 => lcd_bus <= "10" & L2(127 DOWNTO 120); --prim. char da linha 2
						WHEN 19 => lcd_bus <= "10" & L2(119 DOWNTO 112);
						WHEN 20 => lcd_bus <= "10" & L2(111 DOWNTO 104);
						WHEN 21 => lcd_bus <= "10" & L2(103 DOWNTO 96);
						WHEN 22 => lcd_bus <= "10" & L2(95 DOWNTO 88);
						WHEN 23 => lcd_bus <= "10" & L2(87 DOWNTO 80);
						WHEN 24 => lcd_bus <= "10" & L2(79 DOWNTO 72);
						WHEN 25 => lcd_bus <= "10" & L2(71 DOWNTO 64);
						WHEN 26 => lcd_bus <= "10" & L2(63 DOWNTO 56);
						WHEN 27 => lcd_bus <= "10" & L2(55 DOWNTO 48);
						WHEN 28 => lcd_bus <= "10" & L2(47 DOWNTO 40);
						WHEN 29 => lcd_bus <= "10" & L2(39 DOWNTO 32);
						WHEN 30 => lcd_bus <= "10" & L2(31 DOWNTO 24);
						WHEN 31 => lcd_bus <= "10" & L2(23 DOWNTO 16);
						WHEN 32 => lcd_bus <= "10" & L2(15 DOWNTO 8);
						WHEN 33 => lcd_bus <= "10" & L2(7 DOWNTO 0);--ult. char da linha 2			 
						WHEN OTHERS => lcd_enable <= '0'; --desabilita o LCD
					END CASE;
				ELSE
					lcd_enable <= '0'; --desabilita o LCD
				END IF;
			END IF;
	END PROCESS;
END bhv;
