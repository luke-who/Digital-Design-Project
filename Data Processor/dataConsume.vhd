library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_pack.all;

entity dataConsume is
	PORT (
		clk : in std_logic;
		reset : in std_logic;
		start : in std_logic;
		numWords_bcd:in BCD_ARRAY_TYPE(2 downto 0);
    ctrlIn : in std_logic;
    data : in std_logic_vector(7 downto 0);
    ctrlOut : out std_logic;
		dataReady : out std_logic;
		seqDone : out std_logic;
	    byte : out std_logic_vector(7 downto 0);
		maxINdex:out BCD_ARRAY_TYPE(2 downto 0);
		dataResults : out CHAR_ARRAY_TYPE(6 downto 0)
	);
end dataConsume;

architecture structural of dataConsume is
  


signal num : integer range 0 to 1023;
signal done : std_logic; 
signal count : BCD_ARRAY_TYPE(2 downto 0);

signal en: std_logic;

signal IO_1 : std_logic_vector(7 downto 0);
signal IO_2 : std_logic_vector(7 downto 0);
signal IO_3 : std_logic_vector(7 downto 0);

signal T: std_logic;
signal Receive: std_logic;

signal clear : std_logic;


component BCDcounter IS
	PORT (
	  clk : in std_logic; --CLOCK
           reset : in std_logic; 
           R : in std_logic; 
           clear : in std_logic; 
		numWords_bcd:IN BCD_ARRAY_TYPE(2 downto 0); -- 3 BCD digits
	   done : out std_logic; 
		   count : out BCD_ARRAY_TYPE(2 downto 0)
	);
END component;


component register4 is
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
end component;

component register7 is
    port (
        reset : in std_logic;
		clk : in std_logic; 
		R : in std_logic; 
		clear : in std_logic; 
        data : in std_logic_vector(7 downto 0);-- DATA IN
        I_1 : in std_logic_vector(7 downto 0);
        I_2 : in std_logic_vector(7 downto 0);
        I_3 : in std_logic_vector(7 downto 0); 
        en : out  std_logic; 
        dataResults : out CHAR_ARRAY_TYPE(6 downto 0)
        );
end component;

component T_R is
port( 
  reset: in std_logic;
  T: in std_logic;
  clk: in std_logic;
  ctrl_2: in std_logic;
  ctrl_1: out std_logic;
  R: out std_logic
  );
end component;

component controller IS
PORT(
  start: in STD_ULOGIC;
  clk: in STD_ULOGIC;
  reset: in STD_ULOGIC;
  done: in STD_ULOGIC;
  T: out STD_ULOGIC;
  clear : out std_logic; 
  seqDone: out STD_ULOGIC
  );
end component;

component register12 is
    port (
      clk : in std_logic; --CLOCK
           reset : in std_logic; 
        count : in BCD_ARRAY_TYPE(2 downto 0);
        en : in std_logic; 
        clear : in std_logic; 
		maxIndex:out BCD_ARRAY_TYPE(2 downto 0)
        );
end component;


begin
  
dataReady<=Receive;
byte<=data;  

BCDcounter1: BCDcounter
    port map (
    clear=>clear,
		clk=>clk,
		reset=>reset,
		R=>Receive,
		numWords_bcd=>numWords_bcd,
		done=>done,
		count=>count
    );
    	
register41: register4
    port map (
    clear=>clear,
		data=>data,
		reset=>reset,
		clk=>clk,
	  R=>Receive,
		O_1=>IO_1,
		O_2=>IO_2,
		O_3=>IO_3
    );
    	 
register71: register7
    port map (
    clear=>clear,
		data=>data,
		reset=>reset,
		clk=>clk,
		R=>Receive,
		I_1=>IO_1,
		I_2=>IO_2,
		I_3=>IO_3,
		en=>en,
		dataResults=>dataResults
    );
	
	T_R1: T_R
    port map (
		reset=>reset,
		clk=>clk,
		R=>Receive,
		T=>T,
		ctrl_1=>ctrlOut,
		ctrl_2=>ctrlIn
    );


controller1: controller
    port map (
    clear=>clear,
		start=>start,
		reset=>reset,
		clk=>clk,
		done=>done,
		seqDone=>seqDone,
		  T=> T
    );

register121: register12
    port map (
    clear=>clear,
    reset=>reset,
    clk=>clk,
		count=>count,
		en=>en,
		maxIndex=>maxIndex
    );	
    

end structural;