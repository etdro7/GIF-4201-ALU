----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2020 02:05:53 PM
-- Design Name: 
-- Module Name: nbits_adder - Behavioral
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

entity nbits_adder is
    generic ( N : integer := 16);
    port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N - 1 downto 0);
           B : in STD_LOGIC_VECTOR (N - 1 downto 0);
           C : in STD_LOGIC;
           OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0);
           OVERFLOW : out STD_LOGIC);
end nbits_adder;

architecture Behavioral of nbits_adder is

component full_adder
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Ci : in STD_LOGIC;
           S : out STD_LOGIC;
           C : out STD_LOGIC);
end component;

component register_nbits
    generic ( N : integer := 16);
    port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           D : in STD_LOGIC_VECTOR (N - 1 downto 0);
           Q : out STD_LOGIC_VECTOR (N - 1 downto 0));
end component;

signal inter_a : std_logic_vector(N - 1 downto 0) := (others => '0');
signal inter_b : std_logic_vector(N - 1 downto 0) := (others => '0');
signal inter_carry : std_logic_vector(N downto 0) := (others => '0');
signal inter_out : std_logic_vector(N - 1 downto 0) := (others => '0');
signal debug1 : std_logic;
signal debug2 : std_logic;
signal debug3 : std_logic;
signal debug4 : std_logic;

begin

input_a : register_nbits
    generic map ( N => N)
    port map ( CLK => CLK,
           RST => RST,
           EN => EN,
           D => A,
           Q => inter_a(N-1 downto 0));
           
input_b : register_nbits
   generic map ( N => N)
   port map ( CLK => CLK,
          RST => RST,
          EN => EN,
          D => B,
          Q => inter_b(N-1 downto 0));
          
input_c : register_nbits
     generic map ( N => 1)
     port map ( CLK => CLK,
            RST => RST,
            EN => EN,
            D(0) => C,
            Q => inter_carry(0 downto 0));
            
output_s : register_nbits
     generic map ( N => N)
     port map ( CLK => CLK,
            RST => RST,
            EN => EN,
            D => inter_out,
            Q => OUTPUT);
            
--output_overflow : register_nbits
--    generic map ( N => 1)
--    port map ( CLK => CLK,
--        RST => RST,
--        EN => EN,
--        D => inter_carry(N downto N),
--        Q(0) => Overflow);            
        
OVERFLOW <= '1' when (inter_a(N-1)='0' and inter_b(N-1)='0' and inter_out(N-1)='1') else
            '0' when ((inter_a(N-1)='1' and inter_b(N-1)='0') or (inter_a(N-1)='0' and inter_b(N-1)='1')) else
            '1' when (inter_a(N-1)='1' and inter_b(N-1)='1' and inter_out(N-1)='0') else
            '0';
debug1 <= '1' when (inter_a(N-1)='0' and inter_b(N-1)='0' and inter_out(N-1)='1') else
          '0';
debug2 <= '1' when inter_a(N-1)='0' else '0';
debug3 <= '1' when inter_b(N-1)='0' else '0';
debug4 <= '1' when inter_out(N-1)='1' else '0';

Gen_phase : for I in 0 to N - 1 generate
      
adder :  full_adder
    Port map( A => inter_a(i),
           B => inter_b(i),
           Ci => inter_carry(i),
           S => inter_out(i),
           C => inter_carry(i+1));

end generate Gen_phase;

end Behavioral;
