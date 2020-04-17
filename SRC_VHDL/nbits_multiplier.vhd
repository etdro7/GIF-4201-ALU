----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2020 03:20:57 PM
-- Design Name: 
-- Module Name: nbits_multiplier - Behavioral
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
use ieee.numeric_std.all;
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbits_multiplier is
    generic ( N : integer := 16);
    Port ( 
        CLK : in std_logic;
        RST : in std_logic;
        EN : in std_logic;
        START : in std_logic;
        A : in std_logic_vector(N - 1 downto 0);
        B : in std_logic_vector(N - 1 downto 0);
        OUTPUT : inout std_logic_vector(N*2 - 1 downto 0);
        READY : out std_logic);
end nbits_multiplier;

architecture Behavioral of nbits_multiplier is

type mult_state_type is (idle, comparaison, addition, decallage, fin);
signal mult_state : mult_state_type := idle;
signal operation_counter : unsigned(N - 1 downto 0);
signal a_buffer : unsigned(N - 1 downto 0);
signal b_buffer : unsigned(N - 1 downto 0);

begin

process(CLK, RST, EN)
begin
    if RST = '1' then 
        READY <= '0';
        mult_state <= idle;
    elsif CLK'event and CLK = '1' then
        case mult_state is
            when idle =>
                READY <= '0';
                operation_counter <= (others => '0');
                if START = '1' then
                    a_buffer <= unsigned(A);
                    b_buffer <= unsigned(B);
                    OUTPUT <= (others => '0');
                    mult_state <= comparaison;
                end if;
            when comparaison =>
                if b_buffer(0) = '1' then
                    mult_state <= addition; 
                else
                    mult_state <= decallage;
                end if;
            when addition =>
                OUTPUT <= std_logic_vector(unsigned(OUTPUT) + shift_left(a_buffer,to_integer(operation_counter)));
                mult_state <= decallage;
            when decallage =>
                b_buffer <= shift_right(b_buffer,1);
                operation_counter <= operation_counter + 1;
                if operation_counter >= N then
                    mult_state <= fin;
                else
                    mult_state <= comparaison;
                end if;
            when fin =>
                READY <= '1';
                mult_state <= idle;
        end case;
    end if;
end process;



end Behavioral;
