# audio_out testbench
vlog -vlog01compat -work work +incdir+C:/Users/dacb/Desktop/synthX/synthX {C:/Users/dacb/Desktop/synthX/synthX/audio_out_tb.v}
vsim +altera -L altera_ver -L altera -L 220model_ver -L 220model -L altera_lnsim_ver -L altera_lnsim -L cycloneive_ver -L cycloneive -L altera_mf_ver -L altera_mf -do synthX_run_msim_rtl_verilog.do -gui -l msim_transcript work.audio_out_tb
