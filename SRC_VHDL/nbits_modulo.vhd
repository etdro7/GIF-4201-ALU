----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2020 12:39:55 PM
-- Design Name: 
-- Module Name: nbits_modulo - Behavioral
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

entity nbits_modulo is
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
end nbits_modulo;

architecture Behavioral of nbits_modulo is

component nbits_divider is
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
end component;

component nbits_multiplier is
    generic ( N : integer := 16);
    Port ( 
        CLK : in std_logic;
        RST : in std_logic;
        EN : in std_logic;
        START : in std_logic;
        A : in signed(N - 1 downto 0);
        B : in signed(N - 1 downto 0);
        OUTPUT : inout signed(N - 1 downto 0);
        OVERFLOW : out std_logic;
        READY : out std_logic);
end component;

signal output_inter : signed(N - 1 downto 0);
signal output_inter2 : signed(N - 1 downto 0);
signal ready_inter : std_logic;
signal ready_inter2 : std_logic;
signal ready_inter3 : std_logic;
signal a_buffer : signed(N - 1 downto 0);
signal b_buffer : signed(N - 1 downto 0);
signal error_inter : std_logic;

begin

process (CLK,RST,START)
begin
    if RST = '1' then 
        a_buffer <= (others => '0');
        b_buffer <= (others => '0');
    elsif CLK'event and CLK = '1' and en = '1' then
        if START = '1' then
            a_buffer <= A;
            b_buffer <= B;
        end if;
        if ready_inter2 = '1' then
            OUTPUT <= a_buffer - output_inter2;
            READY <= '1';
            ERROR <= '0';
        elsif ready_inter = '1' and error_inter = '1' then
            ERROR <= '1';
            READY <= '1'; 
        else
            READY <= '0';
            ERROR <= '0';
        end if;
        
    end if;
end process;

divider : nbits_divider 
    generic map ( N => N)
    Port map( 
    CLK => CLK,
    RST => RST,
    EN => EN,
    START => START,
    A => A,
    B => B,
    OUTPUT => output_inter,
    ERROR => error_inter,
    READY => ready_inter);
    
ready_inter3 <= '1' when (ready_inter = '1' and error_inter = '0') else '0';
    
multiplier : nbits_multiplier
    generic map ( N => N)
    port map( 
        CLK => CLK,
        RST => RST,
        EN => EN,
        START => ready_inter3,
        A => output_inter,
        B => b_buffer,
        OUTPUT => output_inter2,
        READY => ready_inter2);
        
    
        

end Behavioral;
