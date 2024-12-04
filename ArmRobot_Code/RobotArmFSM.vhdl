LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFSM IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        start : IN STD_LOGIC;
        pos_reached : IN STD_LOGIC;
        gripper_open : OUT STD_LOGIC;
        motor_en : OUT STD_LOGIC;
        state_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        error_out : OUT STD_LOGIC
    );
END RobotArmFSM;

ARCHITECTURE Behavioral OF RobotArmFSM IS
    TYPE state_type IS (IDLE, CALIBRATING, NAV_TO_OBJ, GRIP_OBJ, HOLDING, NAV_TO_TGT, RELEASE_OBJ, ERROR);
    SIGNAL current_state, next_state : state_type;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (current_state, start, pos_reached)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                IF start = '1' THEN
                    next_state <= CALIBRATING;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN CALIBRATING =>
                IF pos_reached = '1' THEN
                    next_state <= NAV_TO_OBJ;
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                ELSE
                    next_state <= CALIBRATING;
                END IF;

            WHEN NAV_TO_OBJ =>
                IF pos_reached = '1' THEN
                    next_state <= GRIP_OBJ;
                ELSE
                    next_state <= NAV_TO_OBJ;
                END IF;

            WHEN GRIP_OBJ =>
                next_state <= HOLDING;

            WHEN HOLDING =>
                IF start = '1' THEN
                    next_state <= NAV_TO_TGT;
                ELSE
                    next_state <= HOLDING;
                END IF;

            WHEN NAV_TO_TGT =>
                IF pos_reached = '1' THEN
                    next_state <= RELEASE_OBJ;
                ELSE
                    next_state <= NAV_TO_TGT;
                END IF;

            WHEN RELEASE_OBJ =>
                next_state <= IDLE;

            WHEN ERROR =>
                IF rst = '1' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= ERROR;
                END IF;

        END CASE;
    END PROCESS;

    -- Output Signals
    motor_en <= '1' WHEN current_state IN (NAV_TO_OBJ, NAV_TO_TGT) ELSE
        '0';
    gripper_open <= '1' WHEN current_state IN (GRIP_OBJ, HOLDING) ELSE
        '0';

    -- State Output to Display 7-segment
    state_out <= "000" WHEN current_state = IDLE ELSE
        "001" WHEN current_state = CALIBRATING ELSE
        "010" WHEN current_state = NAV_TO_OBJ ELSE
        "011" WHEN current_state = GRIP_OBJ ELSE
        "100" WHEN current_state = HOLDING ELSE
        "101" WHEN current_state = NAV_TO_TGT ELSE
        "110" WHEN current_state = RELEASE_OBJ ELSE
        "111"; -- ERROR

    -- Error Indicator
    error_out <= '1' WHEN current_state = ERROR ELSE
        '0';

END Behavioral;