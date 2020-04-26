library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library std; 
use std.textio.all; 

entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is
    component nbits_alu
    generic ( N : integer := 16);
     port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (N - 1 downto 0);
           B : in STD_LOGIC_VECTOR (N - 1 downto 0);
           C : unsigned (N - 1 downto 0);
           OPT : in STD_LOGIC_VECTOR (4 downto 0);
           START : in STD_LOGIC;
           READY : out STD_LOGIC;
           OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0);
           OVERFLOW : out STD_LOGIC;
           DIVIDE_BY_ZERO : out STD_LOGIC;
           BRANCH : out STD_LOGIC );
    end component;
    
    signal RST : std_logic := '0';
    signal CLK : std_logic := '0';
    signal EN : std_logic := '0';
    signal START : std_logic := '0';
    constant N : integer := 16;
    signal A : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal OPT :STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal C : unsigned(N-1 downto 0) := (others => '0');
    signal B : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal OUTPUT : STD_LOGIC_VECTOR(15 downto 0);
    signal OVERFLOW : std_logic;
    signal DIVIDE_BY_ZERO : std_logic;
    signal BRANCH : std_logic;
    signal READY : std_logic;
    
    signal unsigned_OPT : unsigned(4 downto 0) := (others => '0');
    -- clock period definitions
   constant clk_period : time := 100 ns;
   

begin
unit_under_test: nbits_alu
port map (
    RST => RST,
    CLK => CLK,
    EN => EN,
    START => START,
    OPT => OPT,
    A => A,
    B => B,
    C => C,
    OUTPUT => OUTPUT,
    OVERFLOW => OVERFLOW,
    DIVIDE_BY_ZERO => DIVIDE_BY_ZERO,
    BRANCH => BRANCH,
    READY => READY
);
-- clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

-- Stimulus process
stim_proc: process
    begin
    rst <= '1';
    en <= '1';
    start <= '0';
    OPT <= "00000";
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"0210";--528
    wait for 100 ns;
    rst <= '0';
    wait for clk_period;
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"0210";--528
    wait for clk_period*3;
    if(OUTPUT = x"0215" and OVERFLOW = '0') then--533
        report "Correct addition 528 + 5 = 533" severity note;
    else
        report "Erreur 528 + 5 = 533" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"7530";--30 000
    B <= x"7530";--30 000
    wait for clk_period*3;
    if(OVERFLOW = '1') then--533
        report "Correct addition 30 000 + 30 000 = overflow" severity note;
    else
        report "Erreur 30 000 + 30 000 = overflow" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"FFC4";-- -60
    B <= x"0005";--5
    wait for clk_period*3;
    if(OUTPUT = x"FFC9" and OVERFLOW = '0') then--533
        report "Correct addition -60 + 5 = -55" severity note;
    else
        report "Erreur -60 + 5 = -55" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"FFC4";-- -60
    wait for clk_period*3;
    if(OUTPUT = x"FFC9" and OVERFLOW = '0') then--533
        report "Correct addition 5 - 60 = -55" severity note;
    else
        report "Erreur 5 - 60 = -55" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"8AD0";-- -30 000
    B <= x"8AD0";-- -30 000
    wait for clk_period*3;
    if(OVERFLOW = '1') then--533
        report "Correct addition -30 000 - 30 000 = overflow" severity note;
    else
        report "Erreur -30 000 - 30 000 = overflow" severity failure;
    end if;
    
    
    --Soustraction
    OPT <= "00001";
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"0210";--528
    wait for clk_period*3;
    if(OUTPUT = x"FDF5" and OVERFLOW = '0') then--533
        report "Correct soustraction 5 - 528 = -523" severity note;
    else
        report "Erreur 528 - 5 = 523" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"8AD0";-- -30 000
    B <= x"7530";-- 30 000
    wait for clk_period*3;
    if(OVERFLOW = '1') then--533
        report "Correct soustraction -30 000 - 30 000 = overflow" severity note;
    else
        report "Erreur -30 000 - 30 000 = overflow" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"FFC4";-- -60
    B <= x"0005";-- 5
    wait for clk_period*3;
    if(OUTPUT = x"FFBF" and OVERFLOW = '0') then--533
        report "Correct soustraction -60 - 5 = -65" severity note;
    else
        report "Erreur -60 - 5 = -65" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"FFC4";-- -60
    wait for clk_period*3;
    if(OUTPUT = x"0041" and OVERFLOW = '0') then--533
        report "Correct soustraction 5 -- 60 = 65" severity note;
    else
        report "Erreur 5 -- 60 = 65" severity failure;
    end if;
    
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"7530";-- 30 000
    B <= x"8AD0";-- -30 000
    wait for clk_period*3;
    if(OVERFLOW = '1') then--533
        report "Correct soustraction 30 000 -- 30 000 = overflow" severity note;
    else
        report "Erreur 30 000 -- 30 000 = overflow" severity failure;
    end if;
    wait for clk_period*3;
    
    
    --Multiplication
    OPT <= "00010";
    wait for clk_period*3;
    C <= x"0000";--0
    A <= x"0005";--5
    B <= x"0005";--5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    if(OUTPUT = x"0019" and OVERFLOW = '0') then--533
        report "Correct multiplication 5 * 5 = 25" severity note;
    else
        report "Erreur multiplication 5 * 5 = 25" severity failure;
    end if;
    wait for clk_period;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"FFF6";-- -10
    B <= x"0005";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"FFCE" and OVERFLOW = '0') then
        report "Correct multiplication -10 * 5 = -50" severity note;
    else
        report "Erreur multiplication 10 * 5 = -50" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"FFF6";-- -10
    B <= x"0005";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"FFCE" and OVERFLOW = '0') then
        report "Correct multiplication -10 * 5 = -50" severity note;
    else
        report "Erreur multiplication 10 * 5 = -50" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"7530";-- 30 000
    B <= x"7530";-- 30 000
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OVERFLOW = '1') then
        report "Correct multiplication 30 000 * 30 000 = Overflow" severity note;
    else
        report "Erreur multiplication 30 000 * 30 000 = Overflow" severity failure;
    end if;
    
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"8AD0";-- 30 000
    B <= x"7530";-- 30 000
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OVERFLOW = '1') then
        report "Correct multiplication -30 000 * 30 000 = Overflow" severity note;
    else
        report "Erreur multiplication -30 000 * 30 000 = Overflow" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"8AD0";-- 30 000
    B <= x"8AD0";-- 30 000
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OVERFLOW = '1') then
        report "Correct multiplication -30 000 * -30 000 = Overflow" severity note;
    else
        report "Erreur multiplication -30 000 * -30 000 = Overflow" severity failure;
    end if;
        
    
    --Division 
    OPT <= "00011";
    wait for clk_period;
    C <= x"0000";--0
    A <= x"8AD0";-- 30 000
    B <= x"8AD0";-- 30 000
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"0001" and DIVIDE_BY_ZERO = '0') then
        report "Correct division 30 000/30 000 = 1" severity note;
    else
        report "Erreur division 30 000/30 000 = 1" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"001E";-- 30
    B <= x"0005";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"0006" and DIVIDE_BY_ZERO = '0') then
        report "Correct division 30/5 = 6" severity note;
    else
        report "Erreur division 30/5 = 6" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"0020";-- 32
    B <= x"0005";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"0006" and DIVIDE_BY_ZERO = '0') then
        report "Correct division 32/5 = 6" severity note;
    else
        report "Erreur division 32/5 = 6" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"FFE0";-- -32
    B <= x"0005";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"FFFA" and DIVIDE_BY_ZERO = '0') then
        report "Correct division 32/5 = 6" severity note;
    else
        report "Erreur division 32/5 = 6" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0000";--0
    A <= x"FFE0";-- -32
    B <= x"0000";-- 5
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(DIVIDE_BY_ZERO = '1') then
        report "Correct division -32/0 = DIVIDE BY ZERO" severity note;
    else
        report "Erreur division -32/0 = DIVIDE BY ZERO" severity failure;
    end if;
        
   
    
    --modulo       
    OPT <= "00100";
     wait for clk_period;
    C <= x"0000";
    A <= x"0009";
    B <= x"0003";
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"0000" and DIVIDE_BY_ZERO = '0') then
        report "Correct modulo 9%3 = 0" severity note;
    else
        report "Erreur modulo 9%3 = 0" severity failure;
    end if;  
    
    wait for clk_period;
    C <= x"0000";
    A <= x"0009";
    B <= x"0004";
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(OUTPUT = x"0001" and DIVIDE_BY_ZERO = '0') then
        report "Correct modulo 9%4 = 1" severity note;
    else
        report "Erreur modulo 9%4 = 1" severity failure;
    end if;  
    
    wait for clk_period;
    C <= x"0000";
    A <= x"0020";
    B <= x"0000";
    wait for clk_period;
    START <= '1';
    wait for clk_period;
    START <= '0';
    wait until READY = '1';
    wait for clk_period;
    if(DIVIDE_BY_ZERO = '1') then
        report "Correct modulo -32/0 = DIVIDE BY ZERO" severity note;
    else
        report "Erreur modulo -32/0 = DIVIDE BY ZERO" severity failure;
    end if;
    
    -- shift right
    OPT <= "01010";
    wait for clk_period;
    C <= x"0001";
    A <= "0000100100100000";
    B <= x"0002";
    wait for clk_period;
    if(OUTPUT = "0000001001001000") then
        report "Correct shift right" severity note;
    else
        report "Erreur shift right" severity failure;
    end if;
    
    -- shift left
    OPT <= "01001";
    wait for clk_period;
    C <= x"0001";
    A <= "0000100100100000";
    B <= x"0002";
    wait for clk_period;
    if(OUTPUT = "0010010010000000") then
        report "Correct shift left" severity note;
    else
        report "Erreur shift left" severity failure;
    end if;
    
    -- equal
    OPT <= "01011";
    wait for clk_period;
    C <= x"0001";
    A <= x"0002";
    B <= x"0002";
    wait for clk_period;
    if(OUTPUT = x"0001" and BRANCH = '1') then
        report "Correct equal actually equal" severity note;
    else
        report "Erreur equal actually equal" severity failure;
    end if;
    
    wait for clk_period;
    C <= x"0001";
    A <= x"0002";
    B <= x"0003";
    wait for clk_period;
    if(OUTPUT = x"0000" and BRANCH = '0') then
        report "Correct equal not actually equal" severity note;
    else
        report "Erreur equal not actually equal" severity failure;
    end if;
    
    if OPT = "00010" or OPT = "00011" or OPT = "00100" then
        while READY = '0' loop
            wait for clk_period;
        end loop;
    end if;
    
    -- not equal
    OPT <= "01100";
    wait for clk_period;
    C <= x"0001";
    A <= x"0002";
    B <= x"0003";
    wait for clk_period;
    if(OUTPUT = x"0001" and BRANCH = '1') then
        report "Correct not equal" severity note;
    else
        report "Erreur not equal" severity failure;
    end if;
    
    -- Less than
    OPT <= "01101";
    wait for clk_period;
    C <= x"0001";
    A <= x"0002";
    B <= x"0003";
    wait for clk_period;
    if(OUTPUT = x"0001" and BRANCH = '1') then
        report "Correct less than" severity note;
    else
        report "Erreur less than" severity failure;
    end if;
    
    -- Less than or equal
    OPT <= "01110";
    wait for clk_period;
    C <= x"0001";
    A <= x"0002";
    B <= x"0003";
    wait for clk_period;
    if(OUTPUT = x"0001" and BRANCH = '1') then
        report "Correct less than or equal" severity note;
    else
        report "Erreur less than or equal" severity failure;
    end if;
    
    -- equal zero
    OPT <= "01111";
    wait for clk_period;
    C <= x"0001";
    A <= x"0000";
    B <= x"0003";
    wait for clk_period;
    if(OUTPUT = x"0001" and BRANCH = '1') then
        report "Correct equal zero" severity note;
    else
        report "Erreur equal zero" severity failure;
    end if;
    
    wait;
    end process;

end Behavioral;
