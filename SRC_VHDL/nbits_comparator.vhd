library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbits_comparator is
    generic ( N : integer := 16);
    Port ( 
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N - 1 downto 0);
           B : in STD_LOGIC_VECTOR (N - 1 downto 0);
           EQ : out STD_LOGIC;
           GT: out STD_LOGIC;
           LT : out STD_LOGIC;
           EQZ : out STD_LOGIC);
  
end nbits_comparator;

architecture Behavioral of nbits_comparator is

signal unsigned_bits_a : unsigned(N-2 downto 0);
signal unsigned_bits_b : unsigned(N-2 downto 0);
signal zero_test : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    
begin
    comparator_process : process(CLK,RST,EN) 
    begin
    if RST = '1' then
        EQ <= '0';
        GT <= '0';
        LT <= '0';
        EQZ <= '0';
        
    elsif (clk'event and clk = '1' and en = '1') then
        if A > B then
            GT <= '1';
            EQ <= '0';
            LT <= '0';
        elsif A = B then
            EQ <= '1';
            GT <= '0';
            LT <= '0';
        elsif A < B then
            LT <= '1';
            EQ <= '0';
            GT <= '0';
        else
            LT <= '0';
            EQ <= '0';
            GT <= '0';
        end if;
        if A = zero_test then
            EQZ <= '1';
        end if;
    end if;
    end process;
end Behavioral;
