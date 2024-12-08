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
            WHEN "000" =>
                display_out <= "1111110";
            WHEN "001" =>
                display_out <= "0110000";
            WHEN "010" =>
                display_out <= "1101101";
            WHEN "011" =>
                display_out <= "1111001";
            WHEN "100" =>
                display_out <= "0110011";
            WHEN "101" =>
                display_out <= "1011011";
            WHEN "110" =>
                display_out <= "1011111";
            WHEN "111" =>
                display_out <= "0000000";
            WHEN OTHERS =>
                display_out <= "0000000";
        END CASE;
    END PROCESS;
END Behavioral;