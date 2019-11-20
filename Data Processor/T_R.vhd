library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity T_R is
port( 
  reset: in std_logic;
  T: in std_logic;
  clk: in std_logic;
  ctrl_2: in std_logic;
  ctrl_1: out std_logic;
  R: out std_logic
  );
end T_R;


architecture behav of T_R is
  
  signal ctrl2_delayed, ctrl1_reg: std_logic;
begin
  
  delay_Ctrl2: process(clk)     
  begin
    if falling_edge(clk) then
      ctrl2_delayed <= ctrl_2;
    end if;
  end process;
  
R <= ctrl_2 xor ctrl2_delayed;
  
  count: process(clk,reset)
  begin

      if reset = '1' then
        ctrl1_reg <= '0';
      elsif falling_edge(clk) then
        if (T='1') then
          ctrl1_reg <= not ctrl1_reg;
        else null;
        end if;
      else null;
      end if;
  end process;

  ctrl_1 <= ctrl1_reg;
end behav;