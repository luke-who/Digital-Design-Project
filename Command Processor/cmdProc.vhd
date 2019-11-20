library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity cmdProc is
port (
    clk:		in std_logic;
    reset:        in std_logic;
    rxnow:        in std_logic; --valid
    rxData:            in std_logic_vector (7 downto 0);
    txData:            out std_logic_vector (7 downto 0);
    rxdone:        out std_logic; --done
    ovErr:        in std_logic; --oe
    framErr:    in std_logic; --fe
    txnow:        out std_logic;
    txdone:        in std_logic;
    start: out std_logic;
    numWords_bcd: out BCD_ARRAY_TYPE(2 downto 0); --!!!
    dataReady: in std_logic;
    byte: in std_logic_vector(7 downto 0); --!!!
    maxIndex: in BCD_ARRAY_TYPE(2 downto 0);
    dataResults: in CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1);
    seqDone: in std_logic
    );
end cmdProc;


ARCHITECTURE arch_Proc OF cmdProc IS
  SIGNAL data_number : integer := 0;
  SIGNAL I : integer := 0;
  SIGNAL J : integer := 0;
  TYPE state_type IS (INIT,W8,A_STATE,A_STATE_PROC, L_STATE,L_W8, P_STATE,P_W8, N_STATE1,N_STATE1_PROC, N_STATE2,N_STATE2_PROC, Trans_STATE,Trans_W8,Trans_Action); 
  SIGNAL curState, nextState: state_type;
  
  function four28(
  HEX_IN : in std_logic_vector(3 downto 0))
  return std_logic_vector is
  variable ASC_temp : std_logic_vector(7 downto 0);
  begin
  if HEX_IN<"1010" THEN
      ASC_temp :="0011" & HEX_IN;--number 0 to 9
      else 
      ASC_temp :="0100" & std_logic_vector(to_unsigned(to_integer(unsigned(HEX_IN))-9,4)) ; --number Ato F.
      end IF;
  return std_logic_vector(ASC_temp);
  end;
  
BEGIN
  
  
  
  
  combi_nextState: PROCESS(curState, dataReady, seqDone, rxData, txDone, rxNow,dataResults,byte,maxIndex,I,J,data_number) --(need to modify)

  BEGIN
    start<='0';
    rxDone <= '0';
    nextState <= INIT;
    CASE curState IS
      WHEN INIT =>
       IF rxNow = '1' AND (rxData ="01100001" OR rxData ="01000001")  THEN
          nextState <= A_STATE;
        ELSIF rxNow = '1' AND (rxData="01001100" or rxdata="01101100")  THEN
          nextState <= W8;
        ELSIF rxNow = '1' AND (rxData="01010000"  or rxData="01110000") THEN
          nextState <= W8;
        ELSE 
           nextState <= INIT;
        END IF;
        rxDone <= '1';
        
      WHEN A_STATE =>
        IF rxNow='1'  THEN
            IF (rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") then
          nextState <= A_STATE_PROC;
           end IF;
       ELSE 
          nextState <= A_STATE;
        END IF;
        RXDONE <= '1';
        
      WHEN A_STATE_PROC =>
        rxDone <= '1';
        if rxNow = '0' THEN
          nextState <= N_STATE1;
        ELSE 
        nextState <= A_STATE_PROC;
        END IF;
      
      WHEN N_STATE1 =>
          IF rxNow='1'  THEN
              IF (rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") then
                nextState <= N_STATE1_PROC;
              END IF;
          ELSE 
          nextState <= N_STATE1;
          END IF;
          rxDone <= '1';
          
      WHEN N_STATE1_PROC =>
        rxDone <= '1';
        if rxNow = '0' THEN
          nextState <= N_STATE2;
        ELSE 
          nextState <= N_STATE1_PROC;
      END IF;
          
      WHEN N_STATE2 =>
           IF rxNow='1'  THEN
                IF (rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") then
                nextState <= N_STATE2_PROC;
                END IF;
          ELSE
          nextState <= N_STATE2;
           END IF;
           rxDone <= '1';
        
      WHEN N_STATE2_PROC =>
        rxDone <= '1';
        if rxNow = '0' THEN
          nextState <=W8;
       else
       nextstate <= N_STATE2_PROC;
      END IF;
      
      
        WHEN Trans_STATE =>
          start<='1';
          IF dataReady = '1' then
             nextState <= Trans_Action; 
             ELSE nextState <= Trans_State;
          end if;
          
        WHEN Trans_Action =>
           if txDone = '0'  then
            nextState <= Trans_W8;
            ELSE nextState<=Trans_Action;
          end if;
         
        WHEN Trans_W8 =>
          IF txDone='1' then
          IF  I=Data_Number*3+2 then
            nextState <= INIT;
          ELSIF I/=2 AND((I-2) mod 3)= 0 then
            nextState <= Trans_State;
          ELSE  nextState <= Trans_ACTION;
          end if;
          ELSE nextState <= Trans_W8;
        end if;
          
           
        WHEN P_STATE =>
         if txDone='0' then
            nextState <= P_W8;
          ELSE  nextState <= P_STATE;
          END IF;
          
        WHEN P_W8 =>
        if txDone='1' THEN
          IF I = 8 THEN
          nextState <= init;
          ELSE nextstate <= P_STATE;
          end IF;
        ELSE nextstate<=P_W8;
        END IF;
        
        
         WHEN L_STATE =>
         if txDone='0' then
            nextState <= L_W8;
          ELSE  nextState <= L_STATE;
          END IF;
          
        WHEN L_W8 =>
        if txDone='1' THEN
          IF I = 22 THEN
          nextState <= init;
          ELSE nextstate <= L_STATE;
          end IF;
        ELSE nextstate<=L_W8;
        END IF;

         WHEN W8 =>
         if txDone='1' THEN
         if J = 0 then
         nextState <= Trans_State;
         elsif J = 1 then
         nextState <= P_State;
         elsif J=2 then
         nextState <= L_State;
         end if;
         ELSE nextState<=W8;
         end if;
            
        
    END CASE;
  END PROCESS;
  ----------------------------------------------------
 ------------------------------------------------------
  counter_proc: PROCESS(clk)
  BEGIN
   IF  clk'EVENT AND clk='0' THEN
   
    IF curstate = Trans_Action OR curstate = P_STATE OR curstate = L_STATE THEN
    txNow <= '1';
    ELSIF rxnow='1' AND (curstate = INIT OR curstate = A_STATE OR curstate = N_STATE1 OR curstate = N_STATE2) then
            txdata <= rxdata;
            txnow <= '1';
    ELSE txNow<='0';
    END iF;
   IF curstate = A_STATE AND  rxNow='1' AND(rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") THEN
    numWords_bcd(2)<=rxData(3 downto 0);
    DATA_NUMBER <= DATA_NUMBER + 100 * to_integer(unsigned(rxData(3 downto 0)));
   END IF;
      IF curstate = N_STATE1 AND  rxNow='1' AND(rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") THEN
    numWords_bcd(1)<=rxData(3 downto 0);
    DATA_NUMBER <= DATA_NUMBER + 10 * to_integer(unsigned(rxData(3 downto 0)));
   END IF;
      IF curstate = N_STATE2 AND  rxNow='1' AND(rxData ="00110000" OR rxData ="00110001" OR rxData ="00110010" OR rxData ="00110011" OR rxData ="00110100" OR rxData ="00110101" OR rxData ="00110110" OR rxData ="00110111" OR rxData ="00111000" OR rxData ="00111001") THEN
    numWords_bcd(0)<=rxData(3 downto 0);
    DATA_NUMBER <= DATA_NUMBER + to_integer(unsigned(rxData(3 downto 0)));
   END IF;
      IF curstate = Trans_Action then
      IF I=0 then
        txData <= "00001010";
      elsif I=1 then
        txData <= "00001101";
      elsif ((I-2) mod 3)=0 THEN
              txData <= four28(byte(7 downto 4));
      elsif ((I-2) mod 3)=1 then txData<= four28(byte(3 downto 0)); 
      else txData<="00100000";
      end if;
      if txDone = '0' THEN
        I<=I+1;
        END IF;
        end if;
    IF curstate = INIT THEN
     I<=0; DATA_NUMBER <= 0;
     IF rxNow = '1' AND (rxData="01001100" or rxdata="01101100") then
     J<=2;
     ELSIF rxNow = '1' AND (rxData="01010000"  or rxData="01110000") then
     J<=1;
     ELSE
     J<=0;
     END IF;
   END IF;
   IF curstate = P_STATE OR curSTATE = P_W8 then
   IF I=0 then
           txData <= "00001010";
         elsif I=1 then
           txData <= "00001101";
    ELSIF I=2  THEN
      txData<=four28(dataResults(3)(7 downto 4));
    ELSIF I=3 THEN
      txData<=four28(dataResults(3)(3 downto 0));
    ELSIF I=4 THEN
      txData<="00100000";
    ELSIF I=5 THEN
      txData<=four28(maxIndex(2));
    ELSIF I=6 THEN
      txData<=four28(maxIndex(1));
    ELSIF I=7 THEN
      txData<=four28(maxIndex(0));
    ELSIF I=8 THEN
      txData<="00100000";
    END IF;
   END IF;
    IF curstate = L_STATE OR curSTATE = L_W8 then
    IF I=0 then
            txData <= "00001010";
          elsif I=1 then
            txData <= "00001101";
    ELSIF ((I-2) mod 3)=0  THEN
      txData<=four28(dataResults((i-2)/3)(7 downto 4));
    ELSIF ((I-2) mod 3)=1 THEN
      txData<=four28(dataResults((i-2)/3)(3 downto 0));
    ELSIF ((I-2) mod 3)=2 THEN
      txData<="00100000";
    END IF;
   END IF;
   IF curstate = P_W8 and txDone = '1' then
      I <= I+1;
   END IF;
   IF curstate = L_W8 and txDone = '1' then
      I <= I+1;
   END IF;
   
   END IF;
  END PROCESS;
 ------------------------------------------------------
  seq_state: PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      curState <= INIT;
    ELSIF clk'EVENT AND clk='0' THEN
      curState <= nextState;
    END IF;
  END PROCESS; 
  -----------------------------------------------------
END;
