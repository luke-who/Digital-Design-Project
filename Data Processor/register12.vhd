library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;
use work.common_pack.all;

entity register12 is
    port (
      clk : in std_logic; --CLOCK
           reset : in std_logic; 
        count : in BCD_ARRAY_TYPE(2 downto 0);
        en : in std_logic; 
        clear : in std_logic; 
		maxIndex:out BCD_ARRAY_TYPE(2 downto 0)
        );
end register12;

architecture structural of register12 is
begin
shift : process (clk,reset,clear)
begin
    if (reset='1' or clear='1') then
      maxIndex<=("1010","0000","0000");
    elsif (falling_edge(clk)) then
      if (en='1') then
        maxIndex<=count;
      else null;
      end if;
    end if;
end process;
end structural;


