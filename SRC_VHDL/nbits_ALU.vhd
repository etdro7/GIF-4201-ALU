library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_nbits is
    generic ( N : integer := 16);
    port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           D : in STD_LOGIC_VECTOR (N - 1 downto 0);
           Q : out STD_LOGIC_VECTOR (N - 1 downto 0));
end register_nbits;

architecture Behavioral of register_nbits is

begin

process (CLK, RST, EN)
begin
    if RST = '1' then
        Q <= (others => '0');
    elsif CLK'event and CLK = '1' then
        if EN = '1' then
            Q <= D;
        end if;
    end if;
end process; 

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Ci : in STD_LOGIC;
           S : out STD_LOGIC;
           C : out STD_LOGIC);
end full_adder;

architecture Behavioral of full_adder is

signal inter_0 : std_logic;
signal inter_1 : std_logic;
signal inter_2 : std_logic;

begin

inter_0 <= A xor B;
inter_2 <= A and B;

S <= inter_0 xor Ci;
inter_1 <= inter_0 and Ci;
C <= inter_2 or inter_1; 

end Behavioral;


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

signal inter_a : std_logic_vector(N - 1 downto 0);
signal inter_b : std_logic_vector(N - 1 downto 0);
signal inter_carry : std_logic_vector(N downto 0);
signal inter_out : std_logic_vector(N - 1 downto 0);
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
signal zero_test : STD_LOGIC_VECTOR(N-1 downto 0);
    
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

entity nbits_multiplier is
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
end nbits_multiplier;

architecture Behavioral of nbits_multiplier is

function or_reduct(slv : in std_logic_vector) return std_logic is
    variable res_v : std_logic;
  begin
    res_v := '0';
    for i in slv'range loop
      res_v := res_v or slv(i);
    end loop;
    return res_v;
  end function;

function and_reduct(slv : in std_logic_vector) return std_logic is
    variable res_v : std_logic;
  begin
    res_v := '0';
    for i in slv'range loop
      res_v := res_v and slv(i);
    end loop;
    return res_v;
  end function;

type mult_state_type is (idle, comparaison, addition, decallage, fin);
signal mult_state : mult_state_type;
signal operation_counter : unsigned(N - 1 downto 0);
signal a_buffer : signed(N*2 - 1 downto 0);
signal b_buffer : signed(N*2 - 1 downto 0);
signal output_buffer : signed(N*2 -1 downto 0);
signal contains_1 : std_logic;
signal contains_0 : std_logic;

begin

contains_1 <= or_reduct(std_logic_vector(output_buffer(N*2-1 downto N)));
contains_0 <= not(output_buffer(31) and output_buffer(30) and output_buffer(29) and output_buffer(28) and output_buffer(27) and output_buffer(26) and output_buffer(25) and output_buffer(24) and output_buffer(23) and output_buffer(22) and output_buffer(21) and output_buffer(20) and output_buffer(19) and output_buffer(18) and output_buffer(17) and output_buffer(16));

process(CLK, RST, EN)
begin
    if RST = '1' then 
        READY <= '0';
        mult_state <= idle;
    elsif CLK'event and CLK = '1' and en = '1' then
        case mult_state is
            when idle =>
                READY <= '0';
                OVERFLOW <= '0';
                operation_counter <= (others => '0');
                if START = '1' then
                    a_buffer(N-1 downto 0) <= signed(A);
                    if(A(A'length-1)='1') then
                        a_buffer(a_buffer'length-1 downto N) <= (others => '1');
                    else
                        a_buffer(a_buffer'length-1 downto N) <= (others => '0');
                    end if;
                    b_buffer(N-1 downto 0) <= signed(B);
                    if(B(B'length-1)='1') then
                        b_buffer(b_buffer'length-1 downto N) <= (others => '1');
                    else
                        b_buffer(b_buffer'length-1 downto N) <= (others => '0');
                    end if;
                    output_buffer <= (others => '0');
                    mult_state <= comparaison;
                end if;
            when comparaison =>
                if b_buffer(0) = '1' then
                    mult_state <= addition; 
                else
                    mult_state <= decallage;
                end if;
            when addition =>
                output_buffer <= output_buffer + shift_left(a_buffer,to_integer(operation_counter));
                mult_state <= decallage;
            when decallage =>
                b_buffer <= shift_right(b_buffer,1);
                operation_counter <= operation_counter + 1;
                if operation_counter >= N then
                    if(output_buffer(output_buffer'length-1) = '1') then
                        if(contains_0 = '1') then
                            OVERFLOW <= '1';
                        else
                            OVERFLOW <= '0';
                        end if;
                    else
                        if(contains_1 = '1') then
                            OVERFLOW <= '1';
                        else
                            OVERFLOW <= '0';
                        end if;
                    end if;
                    OUTPUT <= output_buffer(N - 1 downto 0);
                    mult_state <= fin;
                else
                    mult_state <= comparaison;
                end if;
            when fin =>
                READY <= '1';
                mult_state <= idle;
			when others =>
				mult_state <= idle;
        end case;
    end if;
end process;

end Behavioral;


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
signal divid_state : divid_state_type;
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
        --- utilité ici? ---
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
