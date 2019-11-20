library ieee;

use ieee.std_logic_1164.all;

entity register4 is
    port (
        data : in std_logic_vector(7 downto 0); -- DATA IN
        reset : in std_logic; 
        clk : in std_logic; 
        R : in std_logic; 
        clear : in std_logic; 
        O_1 : out std_logic_vector(7 downto 0);
        O_2 : out std_logic_vector(7 downto 0);
        O_3 : out std_logic_vector(7 downto 0)
        );
end register4;

architecture structural of register4 is
    
--SIGNALS
signal p_0 : std_logic_vector (7 downto 0); -- REGISTER CONTENTS
signal p_1 : std_logic_vector (7 downto 0);
signal p_2 : std_logic_vector (7 downto 0);

begin
  O_3 <= p_2;
  O_2 <= p_1;
  O_1 <= p_0;
--PROCESS : SHIFT
shift : process (clk,reset,clear)
begin
    if (reset='1' or clear='1') then
      p_2 <= "00000000";
      p_1 <= "00000000";
      p_0 <= "00000000";
    elsif (falling_edge(clk) ) then 
      if (R='1') then
        p_2 <= p_1;  --shift
        p_1 <= p_0;
        p_0 <= data;
      else null;
      end if;
    else null;
    end if;
end process;
end structural;


