LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFPGA IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        input_data : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        start : IN STD_LOGIC;
        pos_reached : OUT STD_LOGIC;
        gripper_open : OUT STD_LOGIC;
        motor_en : OUT STD_LOGIC;
        state_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        error_out : OUT STD_LOGIC;
        flag_reach : OUT STD_LOGIC;
        x_out : OUT INTEGER RANGE 0 TO 999;
        y_out : OUT INTEGER RANGE 0 TO 999;
        z_out : OUT INTEGER RANGE 0 TO 999;
        display_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

        debug_euclid_distance : OUT INTEGER RANGE 0 TO 999;
        debug_remaining_steps : OUT INTEGER RANGE 0 TO 999;
        debug_delta_x : OUT REAL;
        debug_delta_y : OUT REAL;
        debug_delta_z : OUT REAL;
        debug_current_dest_x : OUT INTEGER RANGE 0 TO 999;
        debug_current_dest_y : OUT INTEGER RANGE 0 TO 999;
        debug_current_dest_z : OUT INTEGER RANGE 0 TO 999
    );
END RobotArmFPGA;

ARCHITECTURE Structural OF RobotArmFPGA IS

    SIGNAL x_obj, y_obj, z_obj : INTEGER RANGE 0 TO 999 := 0;
    SIGNAL x_target, y_target, z_target : INTEGER RANGE 0 TO 999 := 0;
    SIGNAL internal_state : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL motor_enable : STD_LOGIC := '0';
    SIGNAL gripper_enable : STD_LOGIC := '0';
    SIGNAL error_flag : STD_LOGIC := '0';
    SIGNAL pos_reached_internal : STD_LOGIC := '0';
    SIGNAL flag_reach_internal : STD_LOGIC := '0';
    SIGNAL current_x_internal : INTEGER RANGE 0 TO 999;
    SIGNAL current_y_internal : INTEGER RANGE 0 TO 999;
    SIGNAL current_z_internal : INTEGER RANGE 0 TO 999;

    SIGNAL debug_euclid_distance_internal : INTEGER RANGE 0 TO 999;
    SIGNAL debug_remaining_steps_internal : INTEGER RANGE 0 TO 999;
    SIGNAL debug_delta_x_internal : REAL;
    SIGNAL debug_delta_y_internal : REAL;
    SIGNAL debug_delta_z_internal : REAL;
    SIGNAL debug_current_dest_x_internal : INTEGER RANGE 0 TO 999;
    SIGNAL debug_current_dest_y_internal : INTEGER RANGE 0 TO 999;
    SIGNAL debug_current_dest_z_internal : INTEGER RANGE 0 TO 999;

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
            current_state => internal_state,
            start => start,
            x_obj => x_obj,
            y_obj => y_obj,
            z_obj => z_obj,
            x_target => x_target,
            y_target => y_target,
            z_target => z_target,
            current_x => current_x_internal,
            current_y => current_y_internal,
            current_z => current_z_internal,
            flag_reach => flag_reach_internal,
            debug_euclid_distance => debug_euclid_distance_internal,
            debug_remaining_steps => debug_remaining_steps_internal,
            debug_delta_x => debug_delta_x_internal,
            debug_delta_y => debug_delta_y_internal,
            debug_delta_z => debug_delta_z_internal,
            debug_current_dest_x => debug_current_dest_x_internal,
            debug_current_dest_y => debug_current_dest_y_internal,
            debug_current_dest_z => debug_current_dest_z_internal
        );
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
    x_out <= current_x_internal;
    y_out <= current_y_internal;
    z_out <= current_z_internal;

    debug_euclid_distance <= debug_euclid_distance_internal;
    debug_remaining_steps <= debug_remaining_steps_internal;
    debug_delta_x <= debug_delta_x_internal;
    debug_delta_y <= debug_delta_y_internal;
    debug_delta_z <= debug_delta_z_internal;
    debug_current_dest_x <= debug_current_dest_x_internal;
    debug_current_dest_y <= debug_current_dest_y_internal;
    debug_current_dest_z <= debug_current_dest_z_internal;
END Structural;