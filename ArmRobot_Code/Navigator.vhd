LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY Navigator IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        current_state : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        start : IN STD_LOGIC;
        x_obj : IN INTEGER RANGE 0 TO 999;
        y_obj : IN INTEGER RANGE 0 TO 999;
        z_obj : IN INTEGER RANGE 0 TO 999;
        x_target : IN INTEGER RANGE 0 TO 999;
        y_target : IN INTEGER RANGE 0 TO 999;
        z_target : IN INTEGER RANGE 0 TO 999;

        current_x : OUT INTEGER RANGE 0 TO 999;
        current_y : OUT INTEGER RANGE 0 TO 999;
        current_z : OUT INTEGER RANGE 0 TO 999;
        flag_reach : OUT STD_LOGIC;
        debug_euclid_distance : OUT INTEGER RANGE 0 TO 999;
        debug_remaining_steps : OUT INTEGER RANGE 0 TO 999;
        debug_delta_x : OUT REAL;
        debug_delta_y : OUT REAL;
        debug_delta_z : OUT REAL;
        debug_current_dest_x : OUT INTEGER RANGE 0 TO 999;
        debug_current_dest_y : OUT INTEGER RANGE 0 TO 999;
        debug_current_dest_z : OUT INTEGER RANGE 0 TO 999
    );
END Navigator;

ARCHITECTURE Behavioral OF Navigator IS
    SIGNAL x_pos, y_pos, z_pos : INTEGER RANGE 0 TO 999;
    SIGNAL target_reached : STD_LOGIC;
    SIGNAL euclid_distance : INTEGER RANGE 0 TO 999;
    SIGNAL delta_x, delta_y, delta_z : REAL;
    SIGNAL remaining_steps : INTEGER RANGE 0 TO 999;
    SIGNAL euclid_last_distance : INTEGER RANGE 0 TO 999;
    SIGNAL current_dest_x, current_dest_y, current_dest_z : INTEGER RANGE 0 TO 999;
    FUNCTION Euclidean_Distance(x1, y1, z1, x2, y2, z2 : IN INTEGER) RETURN INTEGER IS
        VARIABLE distance : REAL;
    BEGIN

        distance := SQRT(REAL((x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2));
        RETURN INTEGER(FLOOR(distance));
    END Euclidean_Distance;

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            x_pos <= 0;
            y_pos <= 0;
            z_pos <= 0;
            current_dest_x <= 0;
            current_dest_y <= 0;
            current_dest_z <= 0;
            target_reached <= '0';
            delta_x <= 0.0;
            delta_y <= 0.0;
            delta_z <= 0.0;
            remaining_steps <= 0;
            euclid_last_distance <= 0;
        ELSIF rising_edge(clk) THEN
            IF start = '1' THEN
                CASE current_state IS

                    WHEN "010" =>

                        euclid_distance <= Euclidean_Distance(x_pos, y_pos, z_pos, x_obj, y_obj, z_obj);
                        current_dest_x <= x_obj;
                        current_dest_y <= y_obj;
                        current_dest_z <= z_obj;
                        IF euclid_distance > 0 THEN

                            euclid_last_distance <= euclid_distance;
                            delta_x <= REAL(x_obj - x_pos) / REAL(euclid_distance);
                            delta_y <= REAL(y_obj - y_pos) / REAL(euclid_distance);
                            delta_z <= REAL(z_obj - z_pos) / REAL(euclid_distance);
                            IF remaining_steps < euclid_distance THEN
                                x_pos <= x_pos + INTEGER(FLOOR(delta_x));
                                y_pos <= y_pos + INTEGER(FLOOR(delta_y));
                                z_pos <= z_pos + INTEGER(FLOOR(delta_z));

                                remaining_steps <= remaining_steps + 1;
                            END IF;
                            IF remaining_steps = euclid_distance THEN
                                target_reached <= '1';
                            ELSE
                                target_reached <= '0';
                            END IF;
                        END IF;
                    WHEN "101" =>

                        euclid_distance <= Euclidean_Distance(x_pos, y_pos, z_pos, x_target, y_target, z_target);
                        current_dest_x <= x_target;
                        current_dest_y <= y_target;
                        current_dest_z <= z_target;
                        IF euclid_last_distance > 0 THEN

                            delta_x <= REAL(x_target - x_pos) / REAL(euclid_distance);
                            delta_y <= REAL(y_target - y_pos) / REAL(euclid_distance);
                            delta_z <= REAL(z_target - z_pos) / REAL(euclid_distance);
                            IF remaining_steps < euclid_distance THEN
                                x_pos <= x_pos + INTEGER(FLOOR(delta_x));
                                y_pos <= y_pos + INTEGER(FLOOR(delta_y));
                                z_pos <= z_pos + INTEGER(FLOOR(delta_z));

                                remaining_steps <= remaining_steps + 1;
                                IF remaining_steps = (euclid_distance - 1) THEN
                                    target_reached <= '1';
                                ELSE
                                    target_reached <= '0';
                                END IF;
                            END IF;
                        END IF;

                    WHEN OTHERS =>

                        target_reached <= '0';
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    current_x <= x_pos;
    current_y <= y_pos;
    current_z <= z_pos;
    flag_reach <= target_reached;
    debug_euclid_distance <= euclid_distance;
    debug_remaining_steps <= remaining_steps;
    debug_delta_x <= delta_x;
    debug_delta_y <= delta_y;
    debug_delta_z <= delta_z;
    debug_current_dest_x <= current_dest_x;
    debug_current_dest_y <= current_dest_y;
    debug_current_dest_z <= current_dest_z;

END Behavioral;