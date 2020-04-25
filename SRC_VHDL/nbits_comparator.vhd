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
    unsigned_bits_a <= unsigned(A(N-2 downto 0));
    unsigned_bits_b <= unsigned(B(N-2 downto 0));
        if A(N-1) = '0' and B(N-1) = '1' then
            GT <= '1';
            
        elsif A(N-1) = '1' and B(N-1) = '0' then
            LT <= '1';
            
        elsif A(N-1) = B(N-1) then
            if unsigned_bits_a > unsigned_bits_b then
                GT <= '1';
            elsif unsigned_bits_a = unsigned_bits_b then
                EQ <= '1';
            elsif unsigned_bits_a < unsigned_bits_b then
                LT <= '1';
            end if;
                                    
        end if;
        if A = zero_test then
            EQZ <= '1';
        end if;
    end if;
    end process;
end Behavioral;
