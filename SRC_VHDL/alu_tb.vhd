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
    start <= '1';
    OPT <= "00100";
    C <= "0100000000000000";
    A <= "0000000000101011";
    B <= "0000000000000011";
    wait for 100 ns;
    rst <= '0';
    if OPT = "00010" or OPT = "00011" or OPT = "00100" then
        while READY = '0' loop
            wait for clk_period;
        end loop;
    end if;        
    
        
    wait;
    end process;

end Behavioral;
