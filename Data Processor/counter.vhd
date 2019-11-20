LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.common_pack.all;
 
ENTITY BCDcounter IS
	PORT (
	  clk : in std_logic; --CLOCK
           reset : in std_logic; 
           R : in std_logic; 
           clear : in std_logic; 
		numWords_bcd:IN BCD_ARRAY_TYPE(2 downto 0); -- 3 BCD digits
	   done : out std_logic; 
		   count : out BCD_ARRAY_TYPE(2 downto 0)
	);
END BCDcounter;

ARCHITECTURE behavioural OF BCDcounter IS
signal num : integer :=0;
signal max : integer :=0;


begin
  count(0)<=std_logic_vector(to_unsigned(num REM 10, 4));
  count(1)<=std_logic_vector(to_unsigned((num/10) rem 10, 4));
  count(2)<=std_logic_vector(to_unsigned(num / 100, 4));
	increment : process (clk,reset,clear)
begin
	if (reset='1' or clear='1') then
		done<='0';
		num<=1000;
		max<=0;
	elsif falling_edge(clk) then
    max<=(100*to_integer(unsigned(numWords_bcd(2)))+10*to_integer(unsigned(numWords_bcd(1)))+to_integer(unsigned(numWords_bcd(0)))-1);
		if (R='1') then
      if (num=999 or num =1000) then
        num<=0;
      else
        num<=num+1;
      end if;
    end if;
		if(num=max) then
		  done<='1';
		else
		  done<='0';
		end if;
	else null;
	end if;
end process;

end behavioural;



