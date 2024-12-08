LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmFPGA_tb IS
END RobotArmFPGA_tb;

ARCHITECTURE Behavioral OF RobotArmFPGA_tb IS
    -- Signals for DUT
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL rst         : STD_LOGIC := '0';
    SIGNAL start       : STD_LOGIC := '0';
    SIGNAL input_data  : STD_LOGIC_VECTOR(47 DOWNTO 0);
    SIGNAL pos_reached : STD_LOGIC;
    SIGNAL gripper_open : STD_LOGIC;
    SIGNAL motor_en    : STD_LOGIC;
    SIGNAL state_out   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL error_out   : STD_LOGIC;
    SIGNAL flag_reach  : STD_LOGIC := '0';
    SIGNAL x_out, y_out, z_out : INTEGER RANGE 0 TO 999;
    SIGNAL display_out : STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- Debug signals
    SIGNAL debug_euclid_distance : INTEGER RANGE 0 TO 999;
    SIGNAL debug_remaining_steps : INTEGER RANGE 0 TO 999;
    SIGNAL debug_delta_x, debug_delta_y, debug_delta_z : REAL;
    SIGNAL debug_current_dest_x, debug_current_dest_y, debug_current_dest_z : INTEGER RANGE 0 TO 999;

    -- Local testbench signals
    SIGNAL counter    : INTEGER RANGE 0 TO 999 := 0; -- Simulates Euclidean distance counting
    SIGNAL current_state : STD_LOGIC_VECTOR(2 DOWNTO 0);
    CONSTANT CLK_PERIOD : TIME := 20 ns;

BEGIN
    -- Instantiate the RobotArmFPGA module
    UUT: ENTITY work.RobotArmFPGA
        PORT MAP (
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

    -- Clock process
    clk_process : PROCESS
    BEGIN
        WAIT FOR CLK_PERIOD / 2;
        clk <= NOT clk;
    END PROCESS;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Initialize Inputs
        rst <= '1';
        start <= '0';
        input_data <= "000001010000101000001111000101000001100100011110"; -- Input object (5,10,15) and target (20,25,30)
        WAIT FOR 50 ns; -- Hold reset for 50 ns
        rst <= '0';
        WAIT FOR 50 ns;
        
        -- Start operation
        start <= '1';
        WAIT FOR 20 ns;
        
        -- FSM Simulation
        WHILE TRUE LOOP
            current_state <= state_out;
            
            CASE current_state IS
                WHEN "010" => -- NAV_TO_OBJ
                    IF counter < debug_euclid_distance THEN
                        counter <= counter + 1; -- Simulate navigation progress
                        flag_reach <= '0';
                    ELSE
                        flag_reach <= '1'; -- Target reached
                    END IF;
                WHEN "101" => -- NAV_TO_TGT
                    IF counter < debug_euclid_distance THEN
                        counter <= counter + 1; -- Simulate navigation progress
                        flag_reach <= '0';
                    ELSE
                        flag_reach <= '1'; -- Target reached
                    END IF;
                WHEN OTHERS =>
                    -- Simulate reaching next state
                    pos_reached <= '1';
                    flag_reach <= '0';
                    WAIT FOR 20 ns;
                    pos_reached <= '0';
            END CASE;

            WAIT FOR CLK_PERIOD; -- Wait for one clock cycle
        END LOOP;
    END PROCESS;
END Behavioral;
