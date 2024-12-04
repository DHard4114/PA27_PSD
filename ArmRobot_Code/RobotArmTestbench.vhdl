LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RobotArmTestbench IS
END RobotArmTestbench;

ARCHITECTURE behavior OF RobotArmTestbench IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL pos_reached : STD_LOGIC;
    SIGNAL gripper_open : STD_LOGIC;
    SIGNAL motor_en : STD_LOGIC;
    SIGNAL state_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL error_out : STD_LOGIC;
    SIGNAL input_data : STD_LOGIC_VECTOR(47 DOWNTO 0);
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : ENTITY work.RobotArmFPGA
        PORT MAP(
            clk => clk,
            rst => rst,
            start => start,
            pos_reached => pos_reached,
            gripper_open => gripper_open,
            motor_en => motor_en,
            state_out => state_out,
            error_out => error_out,
            input_data => input_data
        );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR 10 ns;
        clk <= '1';
        WAIT FOR 10 ns;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Test 1: Reset System
        rst <= '1';
        WAIT FOR 20 ns;
        rst <= '0';
        WAIT FOR 20 ns;

        -- Test 2: Start Kalibrasi
        start <= '1';
        input_data <= "000001010000101000001111000101000001100100011110"; -- Koordinat objek (10,20,30) dan target (50,40,60)
        WAIT FOR 20 ns;
        start <= '0';
        WAIT FOR 20 ns;

        -- Test 3: FSM Transitions (Kalibrasi selesai, start = 1)
        pos_reached <= '1'; -- Kalibrasi selesai
        WAIT FOR 20 ns;

        -- Test 4: Navigasi ke Objek (pos_reached = '1')
        pos_reached <= '1'; -- Posisi objek tercapai
        WAIT FOR 20 ns;

        -- Test 5: Penggenggaman dan Menunggu di Holding
        gripper_open <= '1'; -- Gripper terbuka
        WAIT FOR 20 ns;

        -- Test 6: Navigasi ke Target
        start <= '1'; -- Perintah navigasi ke target
        pos_reached <= '1'; -- Target tercapai
        WAIT FOR 20 ns;

        -- Test 7: Release Objek
        gripper_open <= '0'; -- Gripper tertutup
        WAIT FOR 20 ns;

        -- Test 8: Return to Idle
        pos_reached <= '1'; -- Objek dilepas
        WAIT FOR 20 ns;

        -- Test 9: Error Handling
        pos_reached <= '0'; -- Error terjadi
        WAIT FOR 20 ns;

        WAIT;
    END PROCESS;
END behavior;