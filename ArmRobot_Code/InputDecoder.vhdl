LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY InputDecoder IS
    PORT (
        input_data : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        x_obj : OUT INTEGER RANGE 0 TO 999;
        y_obj : OUT INTEGER RANGE 0 TO 999;
        z_obj : OUT INTEGER RANGE 0 TO 999;
        x_target : OUT INTEGER RANGE 0 TO 999;
        y_target : OUT INTEGER RANGE 0 TO 999;
        z_target : OUT INTEGER RANGE 0 TO 999
    );
END InputDecoder;

ARCHITECTURE Behavioral OF InputDecoder IS
    FUNCTION decode_input(input_data : STD_LOGIC_VECTOR) RETURN INTEGER IS
    BEGIN
        RETURN TO_INTEGER(unsigned(input_data));
    END FUNCTION;
BEGIN
    x_obj <= decode_input(input_data(47 DOWNTO 36));
    y_obj <= decode_input(input_data(35 DOWNTO 24));
    z_obj <= decode_input(input_data(23 DOWNTO 12));
    x_target <= decode_input(input_data(11 DOWNTO 8));
    y_target <= decode_input(input_data(7 DOWNTO 4));
    z_target <= decode_input(input_data(3 DOWNTO 0));
END Behavioral;