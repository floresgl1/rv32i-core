# directories to search for source files
RTL_DIR = ../rtl
TB_DIR = ../tb

# targets:
lint:
TB_DIR= ../tb

#targets:
lint: 
	@echo "Linting RTL files..."
	@verilator --lint-only $(RTL_DIR)/*.sv

sim:
	@echo "Compiling and simulating..."
	@verilator --binary --top-module top_tb $(TB_DIR)/top_tb.sv $(RTL_DIR)/top.sv
	@verilator --binary --top-module top_tb $(TB_DIR)/top_tb.sv $(RTL_DIR)/top.sv 
	@./obj_dir/Vtop_tb

clean:
	@echo "Cleaning up..."
	@rm -rf obj_dir
	@rm -rf obj_dir
