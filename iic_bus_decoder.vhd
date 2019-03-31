LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity iic_BUS_Decoder is
	Port (
		Address 			: in Std_logic_vector(31 downto 0) ;
		iic_Select_H 		: in Std_logic ;
		AS_L				: in Std_Logic ;
		
		iic_Enable_H 		: out std_logic 
	);
end ;

Architecture bhvr of iic_BUS_Decoder is
Begin
	process(Address, iic_Select_H, AS_L)
	Begin
		
		iic_Enable_H  	<= '0' ;	-- default is no enable
		
		-- decoder for the IIC chip - 7 registers at locations 0x0040800x 
		-- where 'x' = 0/2/4/6/8/a/c so that they occupy same half of data bus on 
		-- D15-D8

        if (AS_L = '0' and iic_Select_H = '1')then
            if(Address(31 downto 4) = x"0040800")then
                iic_Enable_H <= '1';
            end if;
        end if;  

		-- TODO: design decoder to produce iic_Enable_H for address in range
		-- [00408020 to 0040802F]. Use iic_Select_H input to simplify decoder
		-- IMPORTANT decoder MUST USE AS_L to make sure only 1 clock edge seen by iic controller per read/write

	end process;
END ;
