library ieee;

use ieee.std_logic_1164.all;
use work.common_pack.all;

entity register7 is
    port (
        reset : in std_logic;
		clk : in std_logic; 
		R : in std_logic; 
		clear  : in std_logic; 
        data : in std_logic_vector(7 downto 0);-- DATA IN
        I_1 : in std_logic_vector(7 downto 0);
        I_2 : in std_logic_vector(7 downto 0);
        I_3 : in std_logic_vector(7 downto 0); 
        en : out std_logic; 
        dataResults : out CHAR_ARRAY_TYPE(6 downto 0)
        );
end register7;

architecture behaviour of register7 is
    
--SIGNALS
signal delay : std_logic_vector(1 downto 0) ; 
signal Q_0 : std_logic_vector(7 downto 0);

begin
--PROCESS : SHIFT
shift : process (clk,reset,clear)
begin
  if (reset='1' or clear='1') then
    dataResults<=("00000000", "00000000","00000000","00000000","00000000","00000000","00000000");
    Q_0<="00000000";
    en<='0';
    delay<="00";
  else     
    if (falling_edge(clk)) then -- FULLY SYNCHRONOUS AND ENABLED
      if (R='1') then
        CASE delay IS  
	        WHEN "11" => dataResults(0) <= data; delay <="00";
	        WHEN "10" => dataResults(1) <= data; delay <="11"; 
	        WHEN "01" => dataResults(2) <= data; delay <="10"; 
          WHEN "00" => null; 
          WHEN OTHERS => null;
	      END CASE;
	      if (data > Q_0) then
                  delay<="01";
                  dataResults(6) <= I_3;
                  dataResults(5) <= I_2;
                  dataResults(4) <= I_1;
                  dataResults(3) <=data;
                  Q_0<= data;
                  en<='1';
              else
                en<='0';
              end if;
	      else null;
	      end if;
    else null;
        end if;
    end if;
end process;
end behaviour;


