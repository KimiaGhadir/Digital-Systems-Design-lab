onerror {quit -f}
vlib work
vlog -work work main1.vo
vlog -work work main1.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.main1_vlg_vec_tst
vcd file -direction main1.msim.vcd
vcd add -internal main1_vlg_vec_tst/*
vcd add -internal main1_vlg_vec_tst/i1/*
add wave /*
run -all
