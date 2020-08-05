LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY usart IS

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
		
END usart;

ARCHITECTURE project OF usart IS

-- Type
	TYPE RAM IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE MYRAM IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
	TYPE MICRO_INTERFACE IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE CONTROL_REGISTER IS ARRAY (0 TO 7) OF STD_LOGIC;
	
-- Signal
	--SIGNAL output_data 		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	--SIGNAL micro_to_fifo 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL mic_inter		: micro_interface;
	SIGNAL tran				: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL connect 			: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

-- Process with optional label : mic_int
	micro_int : PROCESS(clk) IS
	
	-- Variable
		VARIABLE address 						: INTEGER RANGE 0 TO 16 :=0;	
		VARIABLE control						: CONTROL_REGISTER;
		VARIABLE flag_of_number_data_in_micro 	: INTEGER RANGE 0 TO 16 := 0;
		VARIABLE flag_of_number_data_in_fifo	: INTEGER RANGE 0 TO 16 := 0;
		
	BEGIN
		IF(clk'EVENT AND clk = '1') THEN
			IF(cs = '0' AND wr = '0' AND reset = '0') THEN
				IF(flag_of_number_data_in_micro /= 16) THEN
					mic_inter(address_bus) <= data_bus;
					flag_of_number_data_in_micro := flag_of_number_data_in_micro + 1;
				ELSIF(flag_of_number_data_in_micro = 16) THEN
					-- NOTHING
				END IF;
			
			ELSIF(cs = '0' AND rd = '0') THEN
				data_bus_test <= mic_inter(address_bus);
				flag_of_number_data_in_micro := flag_of_number_data_in_micro - 1;
			END IF;
		
		ELSIF(reset = '1') THEN
			flag_of_number_data_in_micro := 0;
		END IF;
		
	END PROCESS;
	
	-- Process with optional label : controler
	controler : PROCESS(clk) IS
	
	-- Variable
		VARIABLE con_reg 						: CONTROL_REGISTER := "00000000";
		VARIABLE FIFO	 						: RAM;
		VARIABLE myfifo 						: RAM;
		VARIABLE mic_int 						: MICRO_INTERFACE ;
		VARIABLE trans_out 						: STD_LOGIC_VECTOR(9 DOWNTO 0);
		VARIABLE flag_of_number_data_in_micro 	: INTEGER RANGE 0 TO 16 := 0;
		VARIABLE flag_of_number_data_in_fifo	: INTEGER RANGE 0 TO 16 := 0;
		VARIABLE temp 							: STD_LOGIC;
		VARIABLE flag 							: STD_LOGIC := '0';
		VARIABLE memory 						: MYRAM;
		VARIABLE count 							: INTEGER RANGE 0 TO 10 := 0; 
		VARIABLE a 								: STD_LOGIC_VECTOR(4 DOWNTO 0) := "10101";
		VARIABLE counter_out 					: INTEGER RANGE 0 TO 9; 
		
	BEGIN
		IF(clk'EVENT AND clk = '1') THEN
		
			IF(cs = '1') THEN
				IF(con_reg(Queue_is_Empty_or_full) = '0') THEN
					FIFO(flag_of_number_data_in_fifo) := connect;
					flag_of_number_data_in_fifo := flag_of_number_data_in_fifo + 1;
					transmit(7 DOWNTO 0) <= mic_inter(flag_of_number_data_in_fifo);
				END IF;
				
				IF(flag_of_number_data_in_fifo = 16) THEN
					con_reg(Queue_is_Empty_or_full) := '1';
				ELSIF(flag_of_number_data_in_fifo /= 16) THEN
					con_reg(Queue_is_Empty_or_full) := '0';
				END IF;

			END IF; -- End Of "IF(cs = '1')"

			IF(con_reg(Queue_is_Empty_or_full) = '0') THEN
				FOR i IN 0 TO 15 LOOP
					IF(con_reg(write_in_Queue_In_the_form_of_serial) = '0') THEN
						trans_out(0) := '0';
						trans_out(9) := '1';
						trans_out(8 DOWNTO 1) := FIFO(0)(7 DOWNTO 0 );
						memory(i)(9 DOWNTO 0):= trans_out(9 DOWNTO 0);
						flag := '1';
						transmit <=	trans_out;
					END IF;
				END LOOP;
			END IF; -- End Of "IF(con_reg(Queue_is_Empty_or_full) = '0')"
			flag_of_number_data_in_fifo := 0;
		END IF; -- End Of "IF(clk'EVENT AND clk = '1')"
		
		IF(flag = '1') THEN
				FOR p IN 0 TO 1 LOOP
					FOR j IN 0 TO 9 LOOP
						temp := memory(p)(j);
						tran <= trans_out;
						count := count + 1;
					END LOOP;
					count := 0;
				END LOOP;
				flag := '0';
				transmit_out<=tran(counter_out);
				counter_out := counter_out + 1;
				IF(counter_out = 9) THEN
					counter_out := 9;
					transmit_out<='X';
				END IF;
				
		END IF; -- End Of "IF(flag := '1')"
		
	END PROCESS;
	
END project;