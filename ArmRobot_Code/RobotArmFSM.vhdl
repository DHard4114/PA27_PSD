LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFSM IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        start : IN STD_LOGIC;
        gripper_status : OUT STD_LOGIC;
        motor_status : OUT STD_LOGIC;
        pos_reached : OUT STD_LOGIC;
        state_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        error_out : OUT STD_LOGIC
    );
END RobotArmFSM;

ARCHITECTURE Behavioral OF RobotArmFSM IS
    TYPE state_type IS (IDLE, CALIBRATING, NAV_TO_OBJ, GRIP_OBJ, HOLDING, NAV_TO_TGT, RELEASE_OBJ, ERROR);
    SIGNAL current_state, next_state : state_type;

BEGIN
    -- Process for state transition
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    -- Process for state machine logic
    PROCESS (current_state, start)
        VARIABLE pos_reached_temp : STD_LOGIC := '0';
        VARIABLE gripper_control : STD_LOGIC := '0';
        VARIABLE motor_control : STD_LOGIC := '0';

    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                IF start = '1' THEN
                    next_state <= CALIBRATING;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN CALIBRATING =>
                -- Verifikasi menguji komponen
                motor_control := '1';
                gripper_control := '1';
                
                IF motor_control = '1' AND gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= NAV_TO_OBJ;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN NAV_TO_OBJ =>

                motor_control := '1';
                IF motor_control = '1' THEN
                    
                END IF;

                IF pos_reached_temp = '1' THEN
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                    next_state <= GRIP_OBJ;
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN GRIP_OBJ =>
                gripper_control := '1';
                IF gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= HOLDING;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN HOLDING =>

                gripper_control := '1';
                IF gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= NAV_TO_TGT;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN NAV_TO_TGT =>
                motor_control := '1';

                IF motor_control = '1' THEN
                    -- Melakukan navigasi pada modul Navigator
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= RELEASE_OBJ;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN RELEASE_OBJ =>
                gripper_control := '1';
                IF gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= IDLE;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0';
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN ERROR =>
                IF rst = '1' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= ERROR;
                END IF;
        END CASE;
        pos_reached <= pos_reached_temp;
        motor_status <= motor_control;
        gripper_status <= gripper_control;
    END PROCESS;
    -- State Output to Display 7-segment (or other monitoring)
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