
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbits_shift_right is
    generic ( N : integer := 16);
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N - 1 downto 0);
           B : in STD_LOGIC_VECTOR (N - 1 downto 0);
           OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0)); 
end nbits_shift_right;

architecture Behavioral of nbits_shift_right is

signal shift_right_output : unsigned(N - 1 downto 0);

begin
    shift_right_process: process(CLK, RST, EN)
    begin
    if RST = '1' then
        OUTPUT <= (others => '0');
        
        
    elsif (clk'event and clk = '1' and en = '1') then
        shift_right_output <= shift_right(unsigned(A),to_integer(unsigned(B)));
        OUTPUT <= std_logic_vector(shift_right_output);
    end if;

    
    end process;

end Behavioral;
