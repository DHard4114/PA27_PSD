LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY RobotArmFPGA_Detailed_TB IS
END RobotArmFPGA_Detailed_TB;

ARCHITECTURE behavior OF RobotArmFPGA_Detailed_TB IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT RobotArmFPGA
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
    END COMPONENT;

    -- Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL input_data : STD_LOGIC_VECTOR(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL start : STD_LOGIC := '0';

    -- Outputs
    SIGNAL pos_reached : STD_LOGIC;
    SIGNAL gripper_open : STD_LOGIC;
    SIGNAL motor_en : STD_LOGIC;
    SIGNAL state_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL error_out : STD_LOGIC;
    SIGNAL flag_reach : STD_LOGIC;
    SIGNAL x_out : INTEGER RANGE 0 TO 999;
    SIGNAL y_out : INTEGER RANGE 0 TO 999;
    SIGNAL z_out : INTEGER RANGE 0 TO 999;
    SIGNAL display_out : STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- Debug Outputs
    SIGNAL debug_euclid_distance : INTEGER RANGE 0 TO 999;
    SIGNAL debug_remaining_steps : INTEGER RANGE 0 TO 999;
    SIGNAL debug_delta_x : REAL;
    SIGNAL debug_delta_y : REAL;
    SIGNAL debug_delta_z : REAL;
    SIGNAL debug_current_dest_x : INTEGER RANGE 0 TO 999;
    SIGNAL debug_current_dest_y : INTEGER RANGE 0 TO 999;
    SIGNAL debug_current_dest_z : INTEGER RANGE 0 TO 999;

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : RobotArmFPGA PORT MAP(
        clk => clk,
        rst => rst,
        input_data => input_data,
        start => start,
        pos_reached => pos_reached,
        gripper_open => gripper_open,
        motor_en => motor_en,
        state_out => state_out,
        error_out => error_out,
        flag_reach => flag_reach,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out,
        display_out => display_out,
        debug_euclid_distance => debug_euclid_distance,
        debug_remaining_steps => debug_remaining_steps,
        debug_delta_x => debug_delta_x,
        debug_delta_y => debug_delta_y,
        debug_delta_z => debug_delta_z,
        debug_current_dest_x => debug_current_dest_x,
        debug_current_dest_y => debug_current_dest_y,
        debug_current_dest_z => debug_current_dest_z
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Initial reset
        rst <= '1';
        WAIT FOR 100 ns;
        rst <= '0';

        -- Set input data
        -- Object coordinates: 5, 10, 15
        -- Target coordinates: 20, 25, 30
        input_data <= "000001010000101000001111000101000001100100011110";

        -- Wait and start the process
        WAIT FOR 50 ns;
        start <= '1';

        -- Hold start for a few clock cycles
        WAIT FOR clk_period * 3;
        start <= '0';

        -- Wait for the entire operation to complete
        WAIT FOR clk_period * 500;

        -- End simulation
        ASSERT false REPORT "Simulation completed" SEVERITY failure;
    END PROCESS;
    -- Monitoring process to track state transitions and robot arm movement
    monitor_proc : PROCESS (clk)
        -- Convert std_logic_vector to string
        FUNCTION slv_to_string(slv : STD_LOGIC_VECTOR) RETURN STRING IS
            VARIABLE result : STRING(slv'length - 1 DOWNTO 0);
        BEGIN
            FOR i IN slv'RANGE LOOP
                IF slv(i) = '0' THEN
                    result(i) := '0';
                ELSE
                    result(i) := '1';
                END IF;
            END LOOP;
            RETURN result;
        END FUNCTION;
    BEGIN
        IF rising_edge(clk) THEN
            -- Detailed state and movement tracking
            REPORT
                "State: " & slv_to_string(state_out) &
                " | X: " & INTEGER'IMAGE(x_out) &
                " | Y: " & INTEGER'IMAGE(y_out) &
                " | Z: " & INTEGER'IMAGE(z_out) &
                " | Flag Reach: " & STD_LOGIC'IMAGE(flag_reach) &
                " | Euclid Dist: " & INTEGER'IMAGE(debug_euclid_distance) &
                " | Remaining Steps: " & INTEGER'IMAGE(debug_remaining_steps) &
                " | Motor En: " & STD_LOGIC'IMAGE(motor_en) &
                " | Gripper: " & STD_LOGIC'IMAGE(gripper_open);
        END IF;
    END PROCESS;

END behavior;