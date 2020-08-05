LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY test_usart IS

END test_usart;

ARCHITECTURE test OF test_usart IS

	COMPONENT usart IS

			GENERIC (  
				Queue_is_Empty_or_full 					: INTEGER RANGE 0 TO 9 := 6; --  0 : Empty , 1 : Full
				write_in_Queue_In_the_form_of_serial 	: INTEGER RANGE 0 TO 9 := 5 	
			);
			
			PORT(
				clk				: IN STD_LOGIC;
				reset			: IN STD_LOGIC;
				cs   			: IN STD_LOGIC;
				wr   			: IN STD_LOGIC;
				rd   			: IN STD_LOGIC;	
				address_bus 	: IN INTEGER RANGE 0 TO 16; 
				data_bus 		: IN STD_LOGIC_VECTOR(7 DOWNTO 0 );
				data_bus_test 	: BUFFER  STD_LOGIC_VECTOR(7 DOWNTO 0 );
				transmit 		: OUT  STD_LOGIC_VECTOR(9 DOWNTO 0 );
				transmit_out 	: BUFFER STD_LOGIC
					
			);
			
	END COMPONENT;

-- Signal
	-- * Inputs :
	SIGNAL clk				: STD_LOGIC := '0';
	SIGNAL reset			: STD_LOGIC := '0';
	SIGNAL cs   			: STD_LOGIC := '1';
	SIGNAL wr   			: STD_LOGIC := '1';
	SIGNAL rd   			: STD_LOGIC := '1';	
	SIGNAL address_bus 		: INTEGER RANGE 0 TO 16 := 0; 
	-- * Inputs/Output :
	SIGNAL data_bus 		: STD_LOGIC_VECTOR(7 DOWNTO 0 ) := (OTHERS => '0');
	-- * Outputs :
	SIGNAL data_bus_test 	: STD_LOGIC_VECTOR(7 DOWNTO 0 );
	SIGNAL transmit 		: STD_LOGIC_VECTOR(9 DOWNTO 0 );
	SIGNAL transmit_out 	: STD_LOGIC;
	-- * Clock Period :
	CONSTANT clk_period : TIME := 10 NS;

BEGIN
	UUT: usart PORT MAP 
			 (
				clk				=> clk,
				reset			=> reset,
				cs   			=> cs,
				wr   			=> wr,
				rd   			=> rd,
				address_bus 	=> address_bus,
				data_bus 		=> data_bus,
				data_bus_test 	=> data_bus_test,
				transmit 		=> transmit,
				transmit_out 	=> transmit_out
					
			);

	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;

	--cs 				<= '0', '1' AFTER 500 NS;
	--wr 				<= '0', '1' AFTER 300 NS;
	--rd 				<= '1', '0' AFTER 300 NS;
	--address_bus 	<= 9, 10 AFTER 100 NS, 11 AFTER 200 NS, 11 AFTER 400 NS;
	--data_bus		<= "11110001", "00110001" AFTER 100 NS, "10000001" AFTER 200 NS;
	
	sim : PROCESS
	BEGIN
		cs <= '0';
		wr <= '0';
		address_bus <= 9;
		data_bus <= "11110001";
		WAIT FOR 100 NS;
		address_bus <= 10;
		data_bus <= "00110001";
		WAIT FOR 100 NS;
		address_bus <= 11;
		data_bus <= "10000001";
		WAIT FOR 100 NS;
		rd<='0';
		wr<='0';
		WAIT FOR 100 NS;
		address_bus <= 9;
		WAIT FOR 100 NS;
		cs <= '1';
		WAIT FOR 100 NS;
		cs <= '0';
		WAIT FOR 100 NS;
		WAIT;
	END PROCESS;
END test;