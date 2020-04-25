
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nbits_ALU is
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
end nbits_ALU;

architecture Behavioral of nbits_ALU is


-- output signals
signal adder_output : STD_LOGIC_VECTOR(N - 1 downto 0);
signal multiplier_output : signed(N - 1 downto 0);
signal substractor_output : STD_LOGIC_VECTOR(N - 1 downto 0);
signal divider_output : signed(N - 1 downto 0);
signal modulo_output : signed(N - 1 downto 0);
signal shift_left_output : STD_LOGIC_VECTOR(N - 1 downto 0);
signal shift_right_output : STD_LOGIC_VECTOR(N - 1 downto 0);
-- comparators output signals --
signal EQ_1 : STD_LOGIC;
signal GT_1 : STD_LOGIC;
signal LT_1 : STD_LOGIC;
signal EQZ_1 : STD_LOGIC;
-- overflow signals
signal adder_overflow : STD_LOGIC;
signal substractor_overflow : STD_LOGIC;
signal multiplier_overflow : STD_LOGIC;
-- others
--signal adder_carry : STD_LOGIC;
--signal substractor_carry : STD_LOGIC;
signal divide_by_zero_1 : STD_LOGIC;
signal divide_by_zero_2 : STD_LOGIC;
signal b_neg : signed(N - 1 downto 0);
-- ready signals 
signal ready_multiplier : STD_LOGIC;
signal ready_divider : STD_LOGIC;
signal ready_modulo : STD_LOGIC;

component nbits_adder
port (  CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        EN : in STD_LOGIC;
        A : in STD_LOGIC_VECTOR (N - 1 downto 0);
        B : in STD_LOGIC_VECTOR (N - 1 downto 0);
        --- utilit� ici? ---
        C : in STD_LOGIC;
        OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0);
        OVERFLOW : out STD_LOGIC);
end component;

component nbits_multiplier
Port ( CLK : in std_logic;
        RST : in std_logic;
        EN : in std_logic;
        START : in std_logic;
        A : in signed(N - 1 downto 0);
        B : in signed(N - 1 downto 0);
        OUTPUT : inout signed(N - 1 downto 0);
        OVERFLOW : out std_logic;
        READY : out std_logic);
end component;

Component nbits_comparator
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
end component;

component nbits_shift_right
port (
    CLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    EN : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR (N - 1 downto 0);
    B : in STD_LOGIC_VECTOR (N - 1 downto 0);
    OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0));
end component;

component nbits_shift_left
port (
    CLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    EN : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR (N - 1 downto 0);
    B : in STD_LOGIC_VECTOR (N - 1 downto 0);
    OUTPUT : out STD_LOGIC_VECTOR (N - 1 downto 0));
end component;

component nbits_divider
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

component nbits_modulo
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
    
begin
    adder_inst_1: nbits_adder
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        A => A,
        B => B,
        C => '0',
        OUTPUT => adder_output,
        OVERFLOW => adder_overflow      
    );
    
    b_neg <= signed(unsigned(not(B))+1);
    adder_inst_2: nbits_adder
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        A => A,
        B => std_logic_vector(b_neg),
        C => '0',
        OUTPUT => substractor_output,
        OVERFLOW => substractor_overflow     
    );
    comparator_inst_1: nbits_comparator
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        A => A,
        B => B,
        EQ => EQ_1,
        LT => LT_1,
        GT => GT_1,
        EQZ => EQZ_1
    );
    
    multiplier_inst_1: nbits_multiplier
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        START => START,
        A => signed(A),
        B => signed(B),
        OUTPUT => multiplier_output,
        OVERFLOW => multiplier_overflow,
        READY => ready_multiplier
    );
    
    nbits_shift_right_inst_1: nbits_shift_right
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        A => A,
        B => B,
        OUTPUT => shift_right_output
    );
    nbits_shift_left_inst_1: nbits_shift_left
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        A => A,
        B => B,
        OUTPUT => shift_left_output
    );
    nbits_divider_inst_1: nbits_divider
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        START => START,
        A => signed(A),
        B => signed(B),
        OUTPUT => divider_output,
        ERROR => divide_by_zero_1,
        READY => ready_divider
    );
    nbits_modulo_inst_1: nbits_modulo
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN,
        START => START,
        A => signed(A),
        B => signed(B),
        OUTPUT => modulo_output,
        ERROR => divide_by_zero_2,
        READY => ready_modulo
    );
    
    alu_process : process (CLK, RST, EN)
    begin
        if RST = '1' then
            OUTPUT <= (others => '0');
            OVERFLOW <= '0';
            DIVIDE_BY_ZERO <= '0';
            BRANCH <= '0';
           
            
        elsif (clk'event and clk = '1' and en = '1') then
            case OPT is
                when "00000" =>
                    OUTPUT <= adder_output;
                    OVERFLOW <= adder_overflow;
                when "00001" =>
                    OUTPUT <= substractor_output;
                    OVERFLOW <= substractor_overflow;
                when "00010" =>
                    OUTPUT <= std_logic_vector(multiplier_output);
                    OVERFLOW <= multiplier_overflow;
                    READY <= ready_multiplier;
                when "00011" =>
                    OUTPUT <= std_logic_vector(divider_output);
                    DIVIDE_BY_ZERO <= divide_by_zero_1;
                    READY <= ready_divider;
                when "00100" =>
                    OUTPUT <= std_logic_vector(modulo_output);
                    DIVIDE_BY_ZERO <= divide_by_zero_2;
                    READY <= ready_modulo;
                when "00101" =>
                    OUTPUT <= A and B;
                when "00110" =>
                    OUTPUT <= A or B;
                when "00111" =>
                    OUTPUT <= A xor B;
                when "01000" =>
                    OUTPUT <= not A;
                when "01001" =>                   
                    OUTPUT <= shift_left_output;
                when "01010" =>                   
                    OUTPUT <= shift_right_output;
                when "01011"  =>
                    if EQ_1 = '1' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                    else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;    
                when "01100" =>
                    if EQ_1 = '0' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                     else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;    
                when "01101" =>
                    if LT_1 = '1' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                     else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;    
                when "01110" =>
                    if (LT_1 or EQ_1) = '1' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                     else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;
                when "01111" =>
                    if EQZ_1 = '1' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                     else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;
                when "10000" =>
                    if EQZ_1 = '0' then
                        OUTPUT <= std_logic_vector(C);
                        BRANCH <= '1';
                     else
                        OUTPUT <= (others => '0');
                        BRANCH <= '0';
                    end if;
                when others =>
                    null;                            
            end case;
        end if;
    
    end process;

end Behavioral;
