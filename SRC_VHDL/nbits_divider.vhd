----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2020 09:34:01 AM
-- Design Name: 
-- Module Name: nbits_divider - Behavioral
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

entity nbits_divider is
    generic ( N : integer := 16);
    Port ( 
    CLK : in std_logic;
    RST : in std_logic;
    EN : in std_logic;
    START : in std_logic;
    A : in signed(N - 1 downto 0);
    B : in signed(N - 1 downto 0);
    OUTPUT : inout signed(N - 1 downto 0);
    ERROR : out std_logic;
    READY : out std_logic);
end nbits_divider;

architecture Behavioral of nbits_divider is

type divid_state_type is (idle, comparaison, soustraction, decallage, fin,erreur);
signal divid_state : divid_state_type := idle;
signal operation_counter : unsigned(N - 1 downto 0);
signal a_buffer : unsigned(N*2 - 2 downto 0);
signal b_buffer : unsigned(N*2 - 2 downto 0);
signal b_buffer_no_touch : unsigned(N - 1 downto 0);
signal a_neg,b_neg : std_logic := '0';
signal zero : signed(N - 1 downto 0);

begin

zero <= (others => '0');

process(CLK, RST, EN)
begin
    if RST = '1' then 
        READY <= '0';
        divid_state <= idle;
    elsif CLK'event and CLK = '1' and en = '1' then
        case divid_state is
            when idle =>
                READY <= '0';
                ERROR <= '0';
                operation_counter <= (others => '0');
                if START = '1' then
                    a_buffer(a_buffer'length - 1 downto N) <= (others => '0');
                    if(A(A'length-1) = '1') then
                        a_buffer(N - 1 downto 0) <= not(unsigned(A))+1;
                        a_neg <= '1';
                    else
                        a_buffer(N - 1 downto 0) <= unsigned(A);
                        a_neg <= '0';
                    end if;
                    
                    b_buffer(N - 2 downto 0) <= (others => '0');
                    if(B(B'length-1) = '1') then
                        b_buffer(b_buffer'length - 1 downto N - 1) <= not(unsigned(B))+1;
                        b_buffer_no_touch <= not(unsigned(B))+1;
                        b_neg <= '1';
                    else
                        b_buffer(b_buffer'length - 1 downto N - 1) <= unsigned(B);
                        b_buffer_no_touch <= unsigned(B);
                        b_neg <= '0';
                    end if;
                    OUTPUT <= (others => '0');
                    if B = zero then
                        divid_state <= erreur;
                    else
                        divid_state <= comparaison;
                    end if;
                end if;
            when comparaison =>
                if b_buffer_no_touch <= a_buffer(a_buffer'length - 1 downto N - 1) then
                    OUTPUT(0) <= '1';
                    divid_state <= soustraction;
                else
                    divid_state <= decallage;
                end if;
            when soustraction =>
                a_buffer <= a_buffer - b_buffer;
                divid_state <= decallage;
            when decallage =>
                operation_counter <= operation_counter + 1;
                if operation_counter = N - 1 then
                    divid_state <= fin;
                    if(a_neg xor b_neg)='1' then
                        OUTPUT <= not(OUTPUT)+1;
                    end if;
                else
                    OUTPUT <= OUTPUT(OUTPUT'length - 2 downto 0) & "0";
                    a_buffer <= a_buffer(a_buffer'length - 2 downto 0) & "0";
                    divid_state <= comparaison;    
                end if;
                
            when fin =>
                READY <= '1';
                divid_state <= idle;
            when erreur =>
                READY <= '1';
                ERROR <= '1';
                divid_state <= idle;
            when others =>
                divid_state <= idle;
        end case;
    end if;
end process;


end Behavioral;
