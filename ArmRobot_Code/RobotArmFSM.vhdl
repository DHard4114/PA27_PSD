LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFSM IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        start : IN STD_LOGIC;
        flag_reach : IN STD_LOGIC;
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

    -- Signaler untuk delay
    SIGNAL delay_done : STD_LOGIC := '0';
    CONSTANT DELAY_CYCLES_CALIBRATING : INTEGER := 2; -- Jumlah siklus untuk delay calibrating (2 clock)

BEGIN

    -- Proses pertama: Menangani clock dan reset
    state_transition : PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS state_transition;

    -- Proses delay untuk kalibrasi
    calibration_delay_process : PROCESS (clk, rst)
        VARIABLE delay_count : INTEGER RANGE 0 TO DELAY_CYCLES_CALIBRATING;
    BEGIN
        IF rst = '1' THEN
            delay_count := 0;
            delay_done <= '0';
        ELSIF rising_edge(clk) THEN
            IF current_state = CALIBRATING THEN
                -- Ketika berada di state CALIBRATING, kita hitung delay
                IF delay_count < DELAY_CYCLES_CALIBRATING THEN
                    delay_count := delay_count + 1;
                    delay_done <= '0'; -- Delay belum selesai
                ELSE
                    delay_count := 0;
                    delay_done <= '1'; -- Delay selesai setelah mencapai 4 siklus
                END IF;
            ELSE
                delay_done <= '1'; -- Di luar state CALIBRATING, delay dianggap selesai
            END IF;
        END IF;
    END PROCESS calibration_delay_process;
    -- Proses state machine utama
    fsm_process : PROCESS (current_state, start, delay_done)
        VARIABLE pos_reached_temp : STD_LOGIC := '0';
        VARIABLE gripper_control : STD_LOGIC := '0';
        VARIABLE motor_control : STD_LOGIC := '0';
    BEGIN
        -- Default assignments

        CASE current_state IS
            WHEN IDLE =>
                IF start = '1' THEN
                    next_state <= CALIBRATING;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN CALIBRATING =>
                IF delay_done = '1' THEN
                    -- Setelah delay selesai, aktifkan motor dan gripper
                    motor_control := '1';
                    gripper_control := '1';
                END IF;

                IF motor_control = '1' AND gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= NAV_TO_OBJ;
                    motor_control := '0';
                    gripper_control := '0';
                    pos_reached_temp := '0'; -- Reset posisi tercapai
                END IF;
            WHEN NAV_TO_OBJ =>
                ---flag_reach := '1'; -- Asumsi navigator berhasil
                IF flag_reach = '1' THEN
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
                    pos_reached_temp := '0';
                END IF;

                IF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN HOLDING =>
                gripper_control := '1';
                motor_control := '0';
                IF gripper_control = '1' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= NAV_TO_TGT;
                    pos_reached_temp := '0';
                END IF;

                IF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN NAV_TO_TGT =>
                motor_control := '1';
                --flag_reach := '1'; -- Asumsi navigator berhasil
                IF flag_reach = '1' THEN
                    pos_reached_temp := '0';
                    next_state <= RELEASE_OBJ;
                ELSIF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN RELEASE_OBJ =>
                gripper_control := '0';
                motor_control := '0';
                IF gripper_control = '0' AND motor_control = '0' THEN
                    pos_reached_temp := '1';
                END IF;

                IF pos_reached_temp = '1' THEN
                    next_state <= IDLE;
                    pos_reached_temp := '0';
                END IF;

                IF start = '0' THEN
                    next_state <= ERROR;
                END IF;

            WHEN ERROR =>
                IF rst = '1' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= ERROR;
                END IF;
        END CASE;

        -- Assign output values
        motor_status <= motor_control;
        gripper_status <= gripper_control;
        pos_reached <= pos_reached_temp;

    END PROCESS fsm_process;

    -- Output state encoding
    state_out <= "000" WHEN current_state = IDLE ELSE
        "001" WHEN current_state = CALIBRATING ELSE
        "010" WHEN current_state = NAV_TO_OBJ ELSE
        "011" WHEN current_state = GRIP_OBJ ELSE
        "100" WHEN current_state = HOLDING ELSE
        "101" WHEN current_state = NAV_TO_TGT ELSE
        "110" WHEN current_state = RELEASE_OBJ ELSE
        "111";

    -- Error output
    error_out <= '1' WHEN current_state = ERROR ELSE
        '0';

END Behavioral;