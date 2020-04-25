
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbits_shift_left is
    generic ( N : integer := 16);
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N - 1 downto 0);
           B : in STD_LOGIC_VECTOR (N - 1 downto 0);
           OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0)); 
end nbits_shift_left;

architecture Behavioral of nbits_shift_left is
signal shift_left_output : unsigned(N - 1 downto 0);

begin
shift_left_process: process(CLK, RST, EN)
    begin
    if RST = '1' then
        OUTPUT <= (others => '0');
        
        
    elsif (clk'event and clk = '1' and en = '1') then
        shift_left_output <= shift_left(unsigned(A),to_integer(unsigned(B)));
        OUTPUT <= std_logic_vector(shift_left_output);
    end if;

    
    end process;

end Behavioral;
