zephyr_dir := ~/open-sources/zephyr
riscv_test_dir := ~/riscv-tests

default: all

zephyr.hex: $(zephyr_dir)/samples/hello_world/build/zephyr/zephyr.elf firmware/makehex.py
	python firmware/makehex.py $< > hex_file/zephyr/$@
	sed -i "1,37d" hex_file/zephyr/$@

zephyr_phil.hex: $(zephyr_dir)/samples/philosophers/build/zephyr/zephyr.elf firmware/makehex.py
	python firmware/makehex.py $< > hex_file/zephyr/$@
	sed -i "1,37d" hex_file/zephyr/$@

zephyr_sync.hex: $(zephyr_dir)/samples/synchronization/build/zephyr/zephyr.elf firmware/makehex.py
	python firmware/makehex.py $< > hex_file/zephyr/$@
	sed -i "1,37d" hex_file/zephyr/$@

pg/%.hex: tests/extra_tests/pg_ctrl/pg_ctrl-m-% firmware/makehex.py
	python firmware/makehex.py $< > hex_file/$@
	sed -i "1,1024d" hex_file/$@

dhrystone.hex:  /home/kitty/open-sources/RISC-V-CORES/VexRiscvSoftcoreContest2018/software/dhrystone/up5kPerf/build/dhrystone.elf firmware/makehex.py
	python firmware/makehex.py $< > hex_file/$@
	sed -i "1,1024d" hex_file/$@

hack_hex: dhrystone.hex
	sed -i "1636,2047d" hex_file/$<

all_pg_hex: pg/simple.hex


int/%.hex: tests/extra_tests/int/kplic-m-% firmware/makehex.py
	python firmware/makehex.py $< > hex_file/$@
	sed -i "1,1024d" hex_file/$@

all_int_hex: int/simple.hex


csr/%.hex: tests/extra_tests/csr/rv32m-m-% firmware/makehex.py
	python firmware/makehex.py $< > hex_file/$@
	sed -i "1,1024d" hex_file/$@

all_csr_hex: csr/csrrc.hex csr/csrrs.hex csr/csrrw.hex csr/csrrci.hex csr/csrrsi.hex csr/csrrwi.hex

riscv/%.hex: $(riscv_test_dir)/isa/rv32ui-p-% firmware/makehex.py
	python firmware/makehex.py $< > hex_file/$@
	sed -i "1,1024d" hex_file/$@

all_riscv_hex: riscv/add.hex riscv/bne.hex riscv/or.hex riscv/sltu.hex riscv/addi.hex riscv/fence_i.hex riscv/ori.hex riscv/sra.hex riscv/and.hex riscv/jal.hex riscv/sb.hex riscv/srai.hex riscv/andi.hex riscv/jalr.hex riscv/sh.hex riscv/srl.hex riscv/auipc.hex  riscv/lb.hex riscv/simple.hex  riscv/srli.hex riscv/beq.hex riscv/lbu.hex riscv/sll.hex riscv/sub.hex riscv/bge.hex riscv/lh.hex riscv/slli.hex riscv/sw.hex riscv/bgeu.hex riscv/lhu.hex riscv/slt.hex riscv/xor.hex riscv/blt.hex riscv/lui.hex riscv/slti.hex riscv/xori.hex riscv/bltu.hex riscv/lw.hex riscv/sltiu.hex

comp:
	iverilog -g2009 -I ./tb -I ./tb/sim_inc -o ./out/krv ./tb/krv_m_tb.v ./tb/rom.v ./src/rtl/*/*.v ./src/Actel_DirectCore/*.v 

veri:
	verilator -Wall +incdir+./tb +incdir+./tb/sim_inc --cc ./tb/rom.v ./verification/krv_m_tb.v ./src/rtl/*/*.v  ./src/Actel_DirectCore/*.v --exe ./verification/sim_main.cpp
	make -j -C obj_dir -f Vkrv_m_tb.mk Vkrv_m_tb

csr.%.sim: hex_file/csr/%.hex 
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt

all_csr_tests: csr.csrrc.sim csr.csrrs.sim csr.csrrw.sim csr.csrrci.sim csr.csrrsi.sim csr.csrrwi.sim

pg.%.sim: hex_file/pg/%.hex 
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt

all_pg_tests: pg.simple.sim

int.%.sim: hex_file/int/%.hex 
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt

all_int_tests: int.simple.sim


zephyr.sim: hex_file/zephyr/zephyr.hex
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt
	mv run.mem bin_file/$@.mem
	
zephyr_phil.sim: hex_file/zephyr/zephyr_phil.hex
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt
	
zephyr_sync.sim: hex_file/zephyr/zephyr_sync.hex
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt
	
dhrystone.sim: hex_file/dhrystone.hex
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt
	

riscv.%.sim: hex_file/riscv/%.hex 
	cp $< hex_file/run.hex
	vvp -l out/$@ -v -n ./out/krv -lxt2
	cp out/krv.vcd out/krv.lxt

all_riscv_tests: riscv.add.sim riscv.bne.sim riscv.or.sim riscv.sltu.sim riscv.addi.sim riscv.fence_i.sim riscv.ori.sim riscv.sra.sim riscv.and.sim riscv.jal.sim riscv.sb.sim riscv.srai.sim riscv.andi.sim riscv.jalr.sim riscv.sh.sim riscv.srl.sim riscv.auipc.sim  riscv.lb.sim riscv.simple.sim  riscv.srli.sim riscv.beq.sim riscv.lbu.sim riscv.sll.sim riscv.sub.sim riscv.bge.sim riscv.lh.sim riscv.slli.sim riscv.sw.sim riscv.bgeu.sim riscv.lhu.sim riscv.slt.sim riscv.xor.sim riscv.blt.sim riscv.lui.sim riscv.slti.sim riscv.xori.sim riscv.bltu.sim riscv.lw.sim riscv.sltiu.sim

update_fpga:
	cp src/Actel_DirectCore/*.v ./fpga/hdl/
	cp src/rtl/*/*.* ./fpga/hdl/
	cp src/fpga_inc/*.* ./fpga/hdl/

check_fail:
	grep "Fail" out/*.sim

check_time_out:
	grep "Time Out" out/*.sim

wave: 
	gtkwave ./out/krv.lxt &
	
clean:
	rm -vrf ./out/*

.PHONY: all
