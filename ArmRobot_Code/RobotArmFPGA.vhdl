LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFPGA IS
    PORT (
        clk : IN STD_LOGIC; -- Clock utama
        rst : IN STD_LOGIC; -- Reset
        input_data : IN STD_LOGIC_VECTOR(47 DOWNTO 0); -- Input gabungan koordinat objek & target
        start : IN STD_LOGIC; -- Sinyal mulai operasi
        pos_reached : OUT STD_LOGIC; -- Indikator posisi tercapai
        gripper_open : OUT STD_LOGIC; -- Output gripper aktif
        motor_en : OUT STD_LOGIC; -- Output motor aktif
        state_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Status FSM
        error_out : OUT STD_LOGIC; -- Indikator error
        flag_reach : OUT STD_LOGIC; -- Flag indikator mencapai target
        x_out : OUT INTEGER RANGE 0 TO 999; -- Posisi x robot
        y_out : OUT INTEGER RANGE 0 TO 999; -- Posisi y robot
        z_out : OUT INTEGER RANGE 0 TO 999; -- Posisi z robot
        display_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- Output untuk Display 7-segment
    );
END RobotArmFPGA;

ARCHITECTURE Structural OF RobotArmFPGA IS
    -- Internal signals untuk menghubungkan modul-modul
    SIGNAL x_obj, y_obj, z_obj : INTEGER RANGE 0 TO 999;
    SIGNAL x_target, y_target, z_target : INTEGER RANGE 0 TO 999;
    SIGNAL internal_state : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL motor_enable : STD_LOGIC;
    SIGNAL gripper_enable : STD_LOGIC;
    SIGNAL error_flag : STD_LOGIC;
    SIGNAL pos_reached_internal : STD_LOGIC;
    SIGNAL flag_reach_internal : STD_LOGIC;

    -- Internal signals untuk Navigator
    SIGNAL current_x_internal : INTEGER RANGE 0 TO 999;
    SIGNAL current_y_internal : INTEGER RANGE 0 TO 999;
    SIGNAL current_z_internal : INTEGER RANGE 0 TO 999;

BEGIN
    -- Input Decoder Module
    Decoder_Module : ENTITY work.InputDecoder
        PORT MAP(
            input_data => input_data,
            x_obj => x_obj,
            y_obj => y_obj,
            z_obj => z_obj,
            x_target => x_target,
            y_target => y_target,
            z_target => z_target
        );

    -- Navigator Module dengan state-dependent navigation
    Navigator_Module : ENTITY work.Navigator
        PORT MAP(
            clk => clk,
            rst => rst,
            current_state => internal_state, -- Passing current state from FSM
            start => start,

            -- Object and target coordinates from Decoder
            x_obj => x_obj,
            y_obj => y_obj,
            z_obj => z_obj,
            x_target => x_target,
            y_target => y_target,
            z_target => z_target,

            -- Current position outputs
            current_x => current_x_internal,
            current_y => current_y_internal,
            current_z => current_z_internal,

            -- Reach flag
            flag_reach => flag_reach_internal
        );

    -- Finite State Machine Module
    FSM_Module : ENTITY work.RobotArmFSM
        PORT MAP(
            clk => clk,
            rst => rst,
            start => start,
            flag_reach => flag_reach_internal,
            gripper_status => gripper_enable,
            motor_status => motor_enable,
            pos_reached => pos_reached_internal,
            state_out => internal_state,
            error_out => error_flag
        );

    -- Display Segment Module
    Display_Module : ENTITY work.DisplaySegment
        PORT MAP(
            state_in => internal_state,
            display_out => display_out
        );

    -- Assign output signals
    motor_en <= motor_enable;
    gripper_open <= gripper_enable;
    error_out <= error_flag;
    pos_reached <= pos_reached_internal;
    state_out <= internal_state;
    flag_reach <= flag_reach_internal;

    -- Assign current position outputs
    x_out <= current_x_internal;
    y_out <= current_y_internal;
    z_out <= current_z_internal;

END Structural;