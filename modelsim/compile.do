vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vcom -work xil_defaultlib  -93  \
"../project_1/project_1.srcs/sources_1/new/DisplaySegment.vhd" \
"../project_1/project_1.srcs/sources_1/new/InputDecoder.vhd" \
"../project_1/project_1.srcs/sources_1/new/Navigator.vhd" \
"../project_1/project_1.srcs/sources_1/new/RobotArmFSM.vhd" \
"../project_1/project_1.srcs/sources_1/new/RobotArmFPGA.vhd" \
"../project_1/project_1.srcs/sources_1/new/RobotArmTestbench.vhd" \


