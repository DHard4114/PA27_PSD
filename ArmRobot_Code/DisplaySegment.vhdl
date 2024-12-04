LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DisplaySegment IS
    PORT (
        state_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        display_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END DisplaySegment;

ARCHITECTURE Behavioral OF DisplaySegment IS
BEGIN
    PROCESS (state_in)
    BEGIN
        CASE state_in IS
            WHEN "000" => -- IDLE
                display_out <= "1111110"; -- Display 1
            WHEN "001" => -- CALIBRATING
                display_out <= "0110000"; -- Display 2
            WHEN "010" => -- NAV_TO_OBJ
                display_out <= "1101101"; -- Display 3
            WHEN "011" => -- GRIP_OBJ
                display_out <= "1111001"; -- Display 4
            WHEN "100" => -- HOLDING
                display_out <= "0110011"; -- Display 5
            WHEN "101" => -- NAV_TO_TGT
                display_out <= "1011011"; -- Display 6
            WHEN "110" => -- RELEASE_OBJ
                display_out <= "1011111"; -- Display 7
            WHEN "111" => -- ERROR
                display_out <= "0000000"; -- Error (All segments on)
            WHEN OTHERS =>
                display_out <= "0000000"; -- Default to Error
        END CASE;
    END PROCESS;
END Behavioral;