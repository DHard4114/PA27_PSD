LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Navigator IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        current_state : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- State input from FSM
        start : IN STD_LOGIC;

        -- Object coordinates from InputDecoder
        x_obj : IN INTEGER RANGE 0 TO 999;
        y_obj : IN INTEGER RANGE 0 TO 999;
        z_obj : IN INTEGER RANGE 0 TO 999;

        -- Target coordinates from InputDecoder
        x_target : IN INTEGER RANGE 0 TO 999;
        y_target : IN INTEGER RANGE 0 TO 999;
        z_target : IN INTEGER RANGE 0 TO 999;

        current_x : OUT INTEGER RANGE 0 TO 999;
        current_y : OUT INTEGER RANGE 0 TO 999;
        current_z : OUT INTEGER RANGE 0 TO 999;
        flag_reach : OUT STD_LOGIC
    );
END Navigator;

ARCHITECTURE Behavioral OF Navigator IS
    SIGNAL x_pos, y_pos, z_pos : INTEGER RANGE 0 TO 999;
    SIGNAL target_reached : STD_LOGIC;

    -- FSM State Constants (matching RobotArmFSM)
    CONSTANT STATE_NAV_TO_OBJ : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
    CONSTANT STATE_NAV_TO_TGT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";

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
                -- Navigation logic with state-dependent target selection
                CASE current_state IS
                    WHEN STATE_NAV_TO_OBJ =>
                        -- Navigate to object coordinates
                        IF x_pos < x_obj THEN
                            x_pos <= x_pos + 1;
                        ELSIF x_pos > x_obj THEN
                            x_pos <= x_pos - 1;
                        END IF;

                        IF y_pos < y_obj THEN
                            y_pos <= y_pos + 1;
                        ELSIF y_pos > y_obj THEN
                            y_pos <= y_pos - 1;
                        END IF;

                        IF z_pos < z_obj THEN
                            z_pos <= z_pos + 1;
                        ELSIF z_pos > z_obj THEN
                            z_pos <= z_pos - 1;
                        END IF;

                        -- Check if object coordinates are reached
                        IF x_pos = x_obj AND y_pos = y_obj AND z_pos = z_obj THEN
                            target_reached <= '1';
                        ELSE
                            target_reached <= '0';
                        END IF;

                    WHEN STATE_NAV_TO_TGT =>
                        -- Navigate to target coordinates
                        IF x_pos < x_target THEN
                            x_pos <= x_pos + 1;
                        ELSIF x_pos > x_target THEN
                            x_pos <= x_pos - 1;
                        END IF;

                        IF y_pos < y_target THEN
                            y_pos <= y_pos + 1;
                        ELSIF y_pos > y_target THEN
                            y_pos <= y_pos - 1;
                        END IF;

                        IF z_pos < z_target THEN
                            z_pos <= z_pos + 1;
                        ELSIF z_pos > z_target THEN
                            z_pos <= z_pos - 1;
                        END IF;

                        -- Check if target coordinates are reached
                        IF x_pos = x_target AND y_pos = y_target AND z_pos = z_target THEN
                            target_reached <= '1';
                        ELSE
                            target_reached <= '0';
                        END IF;

                    WHEN OTHERS =>
                        -- No navigation in other states
                        target_reached <= '0';
                        x_pos <= 0;
                        y_pos <= 0;
                        z_pos <= 0;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Output assignments
    current_x <= x_pos;
    current_y <= y_pos;
    current_z <= z_pos;
    flag_reach <= target_reached;

END Behavioral;