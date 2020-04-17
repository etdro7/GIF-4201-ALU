----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2020 02:08:44 PM
-- Design Name: 
-- Module Name: register_nbits - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_nbits is
    generic ( N : integer := 16);
    port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           D : in STD_LOGIC_VECTOR (N - 1 downto 0);
           Q : out STD_LOGIC_VECTOR (N - 1 downto 0));
end register_nbits;

architecture Behavioral of register_nbits is

begin

process (CLK, RST, EN)
begin
    if RST = '1' then
        Q <= (others => '0');
    elsif CLK'event and CLK = '1' then
        if EN = '1' then
            Q <= D;
        end if;
    end if;
end process; 

end Behavioral;
