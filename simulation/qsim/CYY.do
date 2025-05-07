onerror {exit -code 1}
vlib work
vlog -work work CYY_AU_OP_RP.vo
vlog -work work test_CYY_AU_OP_RP.vwf.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.CYY_AU_OP_RP_vlg_vec_tst -voptargs="+acc"
vcd file -direction CYY.msim.vcd
vcd add -internal CYY_AU_OP_RP_vlg_vec_tst/*
vcd add -internal CYY_AU_OP_RP_vlg_vec_tst/i1/*
run -all
quit -f
