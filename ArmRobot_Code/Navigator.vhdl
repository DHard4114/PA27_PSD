LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Untuk menggunakan TO_INTEGER dan unsigned
ENTITY Navigator IS
    PORT (
        clk : IN STD_LOGIC; -- Clock input
        rst : IN STD_LOGIC; -- Reset
        start : IN STD_LOGIC; -- Start navigation
        target_x : IN INTEGER RANGE 0 TO 999; -- Target x position (integer)
        target_y : IN INTEGER RANGE 0 TO 999; -- Target y position (integer)
        target_z : IN INTEGER RANGE 0 TO 999; -- Target z position (integer)
        current_x : OUT INTEGER RANGE 0 TO 999; -- Current x position (integer)
        current_y : OUT INTEGER RANGE 0 TO 999; -- Current y position (integer)
        current_z : OUT INTEGER RANGE 0 TO 999; -- Current z position (integer)
        flag_reach : OUT STD_LOGIC
    );
END Navigator;
ARCHITECTURE Behavioral OF Navigator IS
    SIGNAL x_pos, y_pos, z_pos : INTEGER RANGE 0 TO 999;
    SIGNAL target_reached : STD_LOGIC;
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            x_pos <= 0;
            y_pos <= 0;
            z_pos <= 0;
            target_reached <= '0';
        ELSIF rising_edge(clk) THEN
            IF start = '1' THEN

                IF x_pos < target_x THEN
                    x_pos <= x_pos + 1;
                ELSIF x_pos > target_x THEN
                    x_pos <= x_pos - 1;
                END IF;
                IF y_pos < target_y THEN
                    y_pos <= y_pos + 1;
                ELSIF y_pos > target_y THEN
                    y_pos <= y_pos - 1;
                END IF;
                IF z_pos < target_z THEN
                    z_pos <= z_pos + 1;
                ELSIF z_pos > target_z THEN
                    z_pos <= z_pos - 1;
                END IF;

                IF x_pos = target_x AND y_pos = target_y AND z_pos = target_z THEN
                    target_reached <= '1';
                ELSE
                    target_reached <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    current_x <= x_pos;
    current_y <= y_pos;
    current_z <= z_pos;

    flag_reach <= target_reached;
END Behavioral;