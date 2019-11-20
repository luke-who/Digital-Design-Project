LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
PORT(
  start: in STD_ULOGIC;
  clk: in STD_ULOGIC;
  reset: in STD_ULOGIC;
  done: in STD_ULOGIC;
  T: out STD_ULOGIC;
  seqDone: out STD_ULOGIC;
  clear: out STD_ULOGIC
  );
end;

ARCHITECTURE structural OF controller IS
  -- State declaration
  TYPE state_type IS (INIT, FIRST, SECOND, THIRD, FOURTH);  -- List your states here 	
  SIGNAL curState, nextState: state_type;

BEGIN

combi_out: PROCESS(curState)
  BEGIN
    T <= '0'; -- assign default value
    IF curstate = first THEN
      T <= '1'; 
    END IF;
  END PROCESS; -- combi_output

 PROCESS(curState)
  BEGIN
    clear <= '0'; -- assign default value
    IF curstate = Init THEN
      clear <= '1'; 
    END IF;
  END PROCESS; -- combi_output
  
  -----------------------------------------------------
  combi_nextState: PROCESS(curState, start,done)
  BEGIN
    nextState <= INIT;
   seqDone<='0';
    CASE curState IS
      WHEN INIT =>

        IF start='1' THEN 
          nextState <= FIRST;
        ELSE null;
        END IF;
        
      WHEN FIRST =>
			IF done='1' THEN
				nextState <= THIRD;
			ELSIF start = '1' THEN
				nextSTATE <= FOURTH;
			ELSE
        nextState <= SECOND;
			END IF;	
      
	  WHEN SECOND =>
	  			IF done='1' THEN
          nextState <= THIRD;
        ELSIF start='1' THEN
          nextState <= FIRST;
        ELSE
          nextState <= SECOND;
        END IF;
		
	  WHEN THIRD =>
		seqDone<='1';
		if start='1' then
            nextState <= INIT;
        ELSE nextState <= THIRD;
        end if;

		
		WHEN FOURTH =>
            IF start='1' THEN
               nextState <= FOURTH;
            ELSE
               nextState <= SECOND;
            END IF;
                
      WHEN OTHERS =>NULL;
    END CASE;
  END PROCESS; -- combi_nextState
    -----------------------------------------------------
  seq_state: PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      curState <= INIT;
    ELSIF clk'EVENT AND clk='0' THEN
      curState <= nextState;
    END IF;
  END PROCESS; -- seq
  -----------------------------------------------------

END;
