.PHONY: test_reg_file test_csr_reg_file test_instr_decode test_if2id test_control test_alu test_integration build clean

test_reg_file:
	@verilator -Wall --cc --exe  test/test_reg_file.cpp rtl/reg_file.sv -Irtl
	@cd obj_dir/ && make -f Vreg_file.mk
	@./obj_dir/Vreg_file

test_csr_reg_file:
	@verilator -Wall --cc --exe  --trace  test/test_csr_reg_file.cpp rtl/csr_reg_file.sv -Irtl
	@cd obj_dir/ && make -f Vcsr_reg_file.mk
	@./obj_dir/Vcsr_reg_file

test_instr_decode:
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_instr_decode.cpp rtl/instr_decode.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vinstr_decode

test_if2id: 
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_if2id.cpp rtl/if2id.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vif2id

test_control:
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_control.cpp rtl/control.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vcontrol

test_alu:
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_alu.cpp rtl/mod_alu.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vmod_alu

test_mod_muldiv:
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_mod_muldiv.cpp rtl/mod_muldiv.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vmod_muldiv

test_integration:
	verilator -Wall --cc --exe --build --trace --top-module mod_cpu -o test_integration --timescale 1s/1s -Irtl test/test_integration.cpp rtl/*.sv

test_test:
	@verilator -Wall --cc --exe --build --trace --top-module mod_cpu -o test --timescale 1s/1s -Irtl test/test_integration.cpp rtl/*.sv
	@echo =========================================build complete=========================================
	@./obj_dir/test

test_cache:
	@verilator -Wall --cc --exe --build --trace --timescale 1s/1s test/test_cache.cpp rtl/mod_mem_cache_test.sv -Irtl
	@echo =========================================build complete=========================================
	@./obj_dir/Vmod_mem_cache_test

build:
	@verilator -Wall --cc --build --trace --top-module mod_cpu --timescale 1s/1s rtl/mod_*.sv -Irtl
	@echo =========================================build complete=========================================

clean: 
	@rm -rf obj_dir/ && echo "Removing obj_dir/"
	@rm -f *.vcd && echo "Removing waveforms"
