----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2020 03:20:57 PM
-- Design Name: 
-- Module Name: nbits_multiplier - Behavioral
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
signal mult_state : mult_state_type := idle;
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
    elsif CLK'event and CLK = '1' then
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
        end case;
    end if;
end process;

end Behavioral;
