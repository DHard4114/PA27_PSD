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
        flag_reach: OUT STD_LOGIC;
        x_out : OUT INTEGER RANGE 0 TO 999; -- Posisi x robot
        y_out : OUT INTEGER RANGE 0 TO 999; -- Posisi y robot
        z_out : OUT INTEGER RANGE 0 TO 999; -- Posisi z robot
        display_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- Output untuk Display 7-segment
    );
END RobotArmFPGA;
ARCHITECTURE Structural OF RobotArmFPGA IS

    SIGNAL x_obj, y_obj, z_obj : INTEGER RANGE 0 TO 999;
    SIGNAL x_target, y_target, z_target : INTEGER RANGE 0 TO 999;
    SIGNAL internal_state : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL motor_enable : STD_LOGIC;
    SIGNAL gripper_enable : STD_LOGIC;
    SIGNAL error_flag : STD_LOGIC;
    SIGNAL pos_reached_internal : STD_LOGIC;
    SIGNAL flag_reach_internal: STD_LOGIC;
BEGIN

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

    Navigator_Module : ENTITY work.Navigator
        PORT MAP(
            clk => clk,
            rst => rst,
            start => start,
            target_x => x_target,
            target_y => y_target,
            target_z => z_target,
            current_x => x_out,
            current_y => y_out,
            current_z => z_out,
            flag_reach => flag_reach_internal
        );

    FSM_Module : ENTITY work.RobotArmFSM
        PORT MAP(
            clk => clk,
            rst => rst,
            start => start,
            pos_reached => pos_reached_internal,
            gripper_status => gripper_enable,
            motor_status => motor_enable,
            state_out => internal_state,
            error_out => error_flag,
            flag_reach => flag_reach_internal
        );

    Display_Module : ENTITY work.DisplaySegment
        PORT MAP(
            state_in => internal_state,
            display_out => display_out
        );

    motor_en <= motor_enable;
    gripper_open <= gripper_enable;
    error_out <= error_flag;
    pos_reached <= pos_reached_internal;
    state_out <= internal_state;
    flag_reach <= flag_reach_internal;
END Structural;