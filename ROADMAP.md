# RV32I Core — Roadmap

> **Goal:** Build a pipelined RISC-V RV32I CPU core from scratch in
> SystemVerilog. Document every stage as a blog post. End result: a
> working 5-stage pipeline that runs real programs, optionally on a
> Tang Nano 9K FPGA ($15).

> **Toolchain:** Verilator (simulation), Yosys + nextpnr-gowin (FPGA
> synthesis). All open-source, all free.

> **Time budget:** Weekends only. Each stage ≈ 1 weekend.

---

## Stages Overview

| # | Stage | Blog post title (working) | Gate (pass/fail) |
|---|-------|--------------------------|------------------|
| 0 | Setup + blog scaffold | "I'm Building a CPU from Scratch" | Blog is live, repo has Makefile, `make lint` passes on empty project |
| 1 | Fetch + decode | "Decoding RISC-V Instructions by Hand" | Testbench decodes all 6 instruction formats (R/I/S/B/U/J) correctly |
| 2 | ALU + register file | "The Arithmetic Heart of a CPU" | Every RV32I ALU op produces correct output; x0 always reads zero |
| 3 | Single-cycle datapath | "My CPU Ran Its First Program" | A hardcoded program computes 2+3=5 and stores it — verified in sim |
| 4 | Control + branches | "Teaching My CPU to Make Decisions" | Iterative factorial program produces correct result for N=5 (120) |
| 5 | Full single-cycle RV32I | "All 37 Instructions" | Passes a subset of riscv-tests (at least: ADD, SUB, AND, OR, BEQ, JAL, LW, SW) |
| 6 | Pipeline: IF/ID split | "Splitting the Datapath" | Same test programs still pass with the structural split |
| 7 | Full 5-stage pipeline | "Why CPUs Overlap Work" | Non-hazardous programs produce correct results |
| 8 | Hazards + forwarding | "When the Pipeline Lies to Itself" | Programs with back-to-back data dependencies produce correct results |
| 9 | Branch handling | "Guessing the Future" | Bubble sort program produces correct output |
| 10 | Integration | "Benchmarking the Pipeline" | Side-by-side cycle count: single-cycle vs pipelined on same program |
| 11 | FPGA port (stretch) | "From Simulation to Silicon" | LED blinks or UART prints on Tang Nano 9K |

---

## Stage 0 — Setup + Blog Scaffold

**Weekend 1. This is where you start.**

### Checklist

- [ ] Install Verilator on your machine (`sudo apt install verilator`
      or `brew install verilator`)
- [ ] Install RISC-V GNU toolchain (for assembling test programs later)
- [ ] Create `sim/Makefile` with `lint`, `sim`, and `clean` targets
- [ ] Write a trivial SV module (`rtl/top.sv` — empty module with clock
      and reset ports)
- [ ] Write a trivial testbench (`tb/top_tb.sv` — toggles clock, prints
      "PASS" after 10 cycles)
- [ ] Verify `make lint` passes on the empty module
- [ ] Verify `make sim` compiles and prints "PASS"
- [ ] Set up GitHub Pages (Jekyll `minima` theme, `_posts/` directory)
- [ ] Write Blog Post 0: "I'm Building a CPU from Scratch"
    - [ ] Why you're doing this
    - [ ] What RV32I is (the 40-instruction base integer ISA)
    - [ ] What tools you'll use and why (all free/open-source)
    - [ ] What the end goal looks like
- [ ] Publish blog post and verify it's accessible at a URL
- [ ] Update repo README with link to the blog
- [ ] Read Chapter 2 of the RISC-V Unprivileged Spec (~20 pages,
      RV32I base only — skip everything else)

### Pass/fail gate

- [ ] `make lint` runs without errors on an empty top-level module
- [ ] `make sim` compiles and runs a trivial testbench (prints "PASS")
- [ ] Blog post 0 is published and accessible at a URL
- [ ] Repo README links to the blog

### What "done" means

You have a working development loop: write SV → simulate → see results.
You have a blog readers can find. You have not written a single line of
CPU logic yet — and that's correct. The infrastructure is the deliverable.

### What you'll need to learn (research list)

- Verilator basics: how to compile and run a SystemVerilog testbench
- GitHub Pages setup: Jekyll `minima` theme, one `_posts/` directory
- RISC-V ISA overview: read Chapter 2 of the RISC-V Unprivileged Spec
  (just the RV32I base — skip everything else, it's 20 pages)

---

## Stage 1 — Fetch + Decode

### Checklist

- [ ] Create `rtl/instr_mem.sv` — ROM that reads a `.hex` file with
      `$readmemh`
- [ ] Create `rtl/pc.sv` — program counter register, increments by 4
      each cycle
- [ ] Create `rtl/fetch.sv` — wires PC → instruction memory → 32-bit
      instruction output
- [ ] Create `rtl/decoder.sv` — extracts opcode, rd, rs1, rs2, funct3,
      funct7 from the instruction
- [ ] Implement immediate decoding for all 6 formats (R, I, S, B, U, J)
      with correct sign extension
- [ ] Create test hex file (`sw/test_decode.hex`) with at least one
      instruction of each format type
- [ ] Hand-calculate expected decoded fields for each test instruction
      (write these down before simulating)
- [ ] Create `tb/decoder_tb.sv` — loads hex file, prints decoded fields,
      compares against expected values
- [ ] Run testbench — all decoded fields match hand-calculated values
- [ ] Verify `make sim STAGE=1` runs clean with zero warnings
- [ ] Write Blog Post 1: "Decoding RISC-V Instructions by Hand"
    - [ ] Walk through the instruction encoding table
    - [ ] Show a hex instruction, decode it bit by bit
    - [ ] Show the hardware doing the same thing
- [ ] Publish blog post

### Pass/fail gate

- [ ] Testbench loads a hex file with at least one of each format type
      (R, I, S, B, U, J) and prints decoded fields
- [ ] All decoded fields match hand-calculated expected values
- [ ] `make sim STAGE=1` runs clean with zero warnings

### What you'll need to learn

- RISC-V instruction encoding formats (Table 2.2 in the spec)
- How `$readmemh` works in Verilator
- Sign extension — why it matters and how to implement it in hardware

---

## Stage 2 — ALU + Register File

### Checklist

- [ ] Create `rtl/regfile.sv` — 32×32 register file, two read ports,
      one write port, x0 hardwired to zero
- [ ] Create `rtl/alu.sv` — supports ADD, SUB, AND, OR, XOR, SLT, SLTU,
      SLL, SRL, SRA
- [ ] Define ALU operation encoding (e.g., 4-bit `alu_op` signal)
- [ ] Create `tb/regfile_tb.sv`:
    - [ ] Write a value to every register (x0–x31), read each back
    - [ ] Verify all values match (except x0 = 0)
    - [ ] Write 0xDEADBEEF to x0, read x0 — verify it returns 0
- [ ] Create `tb/alu_tb.sv`:
    - [ ] Test each ALU operation with at least 3 input pairs
    - [ ] Include edge cases: negative numbers, shift by 0, shift by 31
    - [ ] Test SLT with signed overflow edge case
    - [ ] Test SLTU with max unsigned values
- [ ] All tests automated — testbench prints PASS/FAIL, no manual
      waveform inspection needed
- [ ] Run both testbenches — all PASS
- [ ] Write Blog Post 2: "The Arithmetic Heart of a CPU"
    - [ ] Explain what an ALU is (mux selecting between operations)
    - [ ] Explain why x0 is hardwired to zero (design trick)
    - [ ] Show the ALU operation table
- [ ] Publish blog post

### Pass/fail gate

- [ ] Write a value to every register, read it back — all match
- [ ] Write to x0, read x0 — always returns 0
- [ ] Every ALU operation tested against at least 3 input pairs
      (including edge cases: negative numbers, shift by 0, shift by 31)
- [ ] All tests automated in testbench — no manual inspection

### What you'll need to learn

- Two's complement arithmetic (if rusty)
- How arithmetic right shift differs from logical right shift in hardware
- Register file timing: write on clock edge, read combinationally

---

## Stage 3 — Single-Cycle Datapath

### Checklist

- [ ] Create `rtl/imm_gen.sv` — immediate generator that decodes the
      immediate value for each instruction format
- [ ] Create `rtl/data_mem.sv` — data memory for load/store (LW/SW only
      to start), read/write on clock edge
- [ ] Create `rtl/core.sv` — top-level module wiring:
      fetch → decode → register read → ALU → write-back
- [ ] Wire the immediate generator output to ALU input B (via mux with
      rs2 data)
- [ ] Wire data memory: address from ALU result, write data from rs2,
      read data to register write-back (via mux with ALU result)
- [ ] Add a mux to select write-back source: ALU result vs memory read
- [ ] Write test program (`sw/test_first.s`):
      ```
      addi x1, x0, 2    # x1 = 2
      addi x2, x0, 3    # x2 = 3
      add  x3, x1, x2   # x3 = 5
      sw   x3, 0(x0)    # mem[0] = 5
      lw   x4, 0(x0)    # x4 = mem[0] = 5
      ```
- [ ] Assemble test program to hex file
- [ ] Create `tb/core_tb.sv` — runs the program, checks x3=5 and x4=5
- [ ] Run testbench — x3 and x4 both read as 5
- [ ] Inspect waveform — no `X` or `Z` values in any signal
- [ ] Draw a block diagram of the datapath (for the blog post)
- [ ] Write Blog Post 3: "My CPU Ran Its First Program"
    - [ ] Show the waveform
    - [ ] Trace data through each stage cycle by cycle
    - [ ] Include the block diagram
- [ ] Publish blog post

### Pass/fail gate

- [ ] A hardcoded program runs:
      ```
      addi x1, x0, 2    # x1 = 2
      addi x2, x0, 3    # x2 = 3
      add  x3, x1, x2   # x3 = 5
      sw   x3, 0(x0)    # mem[0] = 5
      lw   x4, 0(x0)    # x4 = mem[0] = 5
      ```
- [ ] x3 and x4 both read as 5 at end of simulation
- [ ] No `X` or `Z` values in any signal during execution

### What you'll need to learn

- How to assemble RISC-V assembly to hex (using `riscv64-unknown-elf-as`
  and `objcopy`)
- Mux-based datapath design — which signals select which paths
- Single-cycle timing: everything happens in one clock period

---

## Stage 4 — Control Unit + Branches

### Checklist

- [ ] Create `rtl/control.sv` — generates control signals from opcode:
    - [ ] RegWrite (write to register file?)
    - [ ] MemRead (read from data memory?)
    - [ ] MemWrite (write to data memory?)
    - [ ] Branch (is this a branch instruction?)
    - [ ] ALUSrc (ALU input B = register or immediate?)
    - [ ] ALUOp (which ALU operation?)
    - [ ] MemToReg (write-back from ALU or memory?)
- [ ] Write the control unit truth table (on paper first, then in SV)
- [ ] Create `rtl/branch_comp.sv` — branch comparator:
    - [ ] BEQ (equal)
    - [ ] BNE (not equal)
    - [ ] BLT (less than, signed)
    - [ ] BGE (greater or equal, signed)
    - [ ] BLTU (less than, unsigned)
    - [ ] BGEU (greater or equal, unsigned)
- [ ] Add jump logic — JAL, JALR:
    - [ ] JAL: PC = PC + imm, rd = PC + 4
    - [ ] JALR: PC = (rs1 + imm) & ~1, rd = PC + 4
- [ ] Update PC logic: next PC = PC+4 / branch target / jump target
- [ ] Wire control unit into `core.sv`
- [ ] Write factorial test program (`sw/test_factorial.s`):
    - [ ] Compute 5! = 120 using loops and branches
    - [ ] (No MUL in RV32I — implement multiply via repeated addition)
    - [ ] Store result in memory
- [ ] Assemble and create hex file
- [ ] Create `tb/branch_tb.sv` — runs factorial, checks mem[0] = 120
- [ ] Run testbench — final value in memory = 120
- [ ] Verify program terminates (doesn't loop forever) — add a cycle
      limit to the testbench
- [ ] Write Blog Post 4: "Teaching My CPU to Make Decisions"
    - [ ] Show the control unit truth table
    - [ ] Trace a branch taken vs not-taken
    - [ ] Explain why branches make a CPU more than a calculator
- [ ] Publish blog post

### Pass/fail gate

- [ ] Iterative factorial program computes 5! = 120
- [ ] Final value in memory = 120
- [ ] Program terminates (doesn't loop forever)

### What you'll need to learn

- Control signal design — how opcodes map to datapath behavior
- Branch target calculation: PC + sign-extended immediate
- How to implement multiply without a MUL instruction (nested loops)

---

## Stage 5 — Full Single-Cycle RV32I

### Checklist

- [ ] Implement remaining R-type instructions (if not already done)
- [ ] Implement LUI (load upper immediate)
- [ ] Implement AUIPC (add upper immediate to PC)
- [ ] Implement remaining load widths: LB, LH, LBU, LHU
- [ ] Implement remaining store widths: SB, SH
- [ ] Implement remaining branch variants (all 6 should work from
      Stage 4 — verify each)
- [ ] Implement remaining I-type ALU instructions: ANDI, ORI, XORI,
      SLTI, SLTIU, SLLI, SRLI, SRAI
- [ ] Update control unit for all new instruction types
- [ ] Download riscv-tests compliance suite
- [ ] Write a test harness that runs riscv-tests hex files and checks
      pass/fail
- [ ] Run at least these 8 riscv-tests: ADD, SUB, AND, OR, BEQ, JAL,
      LW, SW
- [ ] Fix any failing tests
- [ ] Run `make test` — all tests pass with clear PASS/FAIL output
- [ ] Run `make lint` — no warnings
- [ ] Refactor: clean up module interfaces, consistent naming, add
      comments
- [ ] Write Blog Post 5: "All 37 Instructions"
    - [ ] Show the compliance test results
    - [ ] Reflect on what it took to get here
    - [ ] This is the "complete single-cycle CPU" milestone
- [ ] Publish blog post

### Pass/fail gate

- [ ] Pass at least 8 riscv-tests: ADD, SUB, AND, OR, BEQ, JAL, LW, SW
- [ ] All tests run via `make test` with clear PASS/FAIL output
- [ ] No lint warnings

### What you'll need to learn

- How riscv-tests work (pass/fail convention: write to `tohost`)
- LUI/AUIPC — how upper-immediate instructions build 32-bit constants
- Byte and halfword loads: sign extension vs zero extension

---

## Stage 6 — Pipeline: IF/ID Split

### Checklist

- [ ] Create `rtl/pipe_reg_if_id.sv` — pipeline register between IF
      and ID stages, clocked fields:
    - [ ] `instruction` (32 bits)
    - [ ] `pc` (32 bits)
- [ ] Modify `core.sv`: insert pipeline register between fetch and
      decode
- [ ] Ensure decoder reads from pipeline register output, not directly
      from instruction memory
- [ ] Add pipeline register flush/stall control inputs (active low
      enable, synchronous clear) — not used yet, but the ports are there
- [ ] Re-run all Stage 5 tests — all must still pass
- [ ] Open waveform viewer — verify instruction appears in pipeline
      register one cycle after fetch
- [ ] Write Blog Post 6: "Splitting the Datapath"
    - [ ] Explain pipelining by analogy (laundry, assembly line)
    - [ ] Show before/after timing diagrams
    - [ ] Explain why this split alone doesn't speed anything up yet
- [ ] Publish blog post

### Pass/fail gate

- [ ] All Stage 5 tests still pass (no regressions)
- [ ] Waveform shows instruction moving through pipeline register with
      one cycle delay

### What you'll need to learn

- Pipeline registers: what they hold, when they latch
- The difference between structural pipelining (adding registers) and
  getting performance from it (handling hazards)

---

## Stage 7 — Full 5-Stage Pipeline

### Checklist

- [ ] Create `rtl/pipe_reg_id_ex.sv` — pipeline register between ID
      and EX, fields:
    - [ ] Control signals (RegWrite, MemRead, MemWrite, Branch, ALUSrc,
          ALUOp, MemToReg)
    - [ ] rs1 data, rs2 data, rd address
    - [ ] Immediate value
    - [ ] PC
    - [ ] funct3, funct7
- [ ] Create `rtl/pipe_reg_ex_mem.sv` — pipeline register between EX
      and MEM, fields:
    - [ ] Control signals (RegWrite, MemRead, MemWrite, MemToReg, Branch)
    - [ ] ALU result, rs2 data (for store), rd address
    - [ ] Zero flag, branch target
- [ ] Create `rtl/pipe_reg_mem_wb.sv` — pipeline register between MEM
      and WB, fields:
    - [ ] Control signals (RegWrite, MemToReg)
    - [ ] ALU result, memory read data, rd address
- [ ] Refactor `core.sv` to route signals through all 4 pipeline
      registers
- [ ] Create NOP-padded versions of earlier test programs (insert 3 NOPs
      between dependent instructions)
- [ ] Run NOP-padded tests — all produce correct results
- [ ] Open waveform — verify 5 instructions are in-flight simultaneously
      in different pipeline stages
- [ ] Write Blog Post 7: "Why CPUs Overlap Work"
    - [ ] Show the pipeline diagram (5 stages, instructions overlapping)
    - [ ] Count cycles: single-cycle vs pipelined on same NOP-padded
          program
    - [ ] Explain why the speedup isn't great yet (NOPs waste slots)
- [ ] Publish blog post

### Pass/fail gate

- [ ] NOP-padded versions of earlier test programs produce correct results
- [ ] Waveform shows 5 instructions in-flight simultaneously

### What you'll need to learn

- Pipeline stage boundaries: what computation belongs in which stage
- How control signals must travel with the instruction through the
  pipeline (they don't just come from the decoder anymore)
- NOP encoding in RISC-V: `addi x0, x0, 0` = `0x00000013`

---

## Stage 8 — Hazard Detection + Forwarding

### Checklist

- [ ] Create `rtl/hazard_unit.sv` — detects RAW (Read After Write)
      data dependencies:
    - [ ] Compare EX/MEM.rd with ID/EX.rs1 and ID/EX.rs2
    - [ ] Compare MEM/WB.rd with ID/EX.rs1 and ID/EX.rs2
    - [ ] Detect load-use hazard (EX/MEM.MemRead && rd matches)
- [ ] Create `rtl/forward_unit.sv` — forwarding mux control:
    - [ ] ForwardA / ForwardB selects: no forward, forward from EX/MEM,
          forward from MEM/WB
- [ ] Add forwarding muxes to EX stage ALU inputs
- [ ] Add stall logic for load-use hazard:
    - [ ] Freeze IF/ID pipeline register (don't latch new instruction)
    - [ ] Freeze PC (don't increment)
    - [ ] Insert bubble (NOP) into ID/EX pipeline register
- [ ] Remove all NOP padding from test programs
- [ ] Create `tb/hazard_tb.sv` with specific hazard test cases:
    - [ ] Back-to-back ADD: `add x1, x2, x3; add x4, x1, x5`
          (EX→EX forwarding)
    - [ ] Two-apart dependency: `add x1, x2, x3; nop; add x4, x1, x5`
          (MEM→EX forwarding)
    - [ ] Load-use: `lw x1, 0(x0); add x2, x1, x3`
          (stall + forward)
    - [ ] Store after load: `lw x1, 0(x0); sw x1, 4(x0)`
          (forwarding to store data)
- [ ] Run hazard tests — all produce correct results
- [ ] Re-run all Stage 5 compliance tests (without NOP padding) — all
      still pass
- [ ] Inspect waveforms — no `X` values in forwarded data
- [ ] Write Blog Post 8: "When the Pipeline Lies to Itself"
    - [ ] Explain data hazards with a concrete example
    - [ ] Show what goes wrong without forwarding (stale value)
    - [ ] Draw the forwarding mux diagram
    - [ ] Explain load-use stall — why forwarding alone isn't enough
- [ ] Publish blog post

### Pass/fail gate

- [ ] Remove all NOP padding from test programs — results still correct
- [ ] Specifically test:
  - Back-to-back ADD (x1 = x2 + x3; x4 = x1 + x5) — forwarding
  - Load followed by use (LW x1; ADD x2, x1, x3) — stall + forward
- [ ] No `X` values in forwarded data

### What you'll need to learn

- RAW / WAR / WAW hazard taxonomy (only RAW matters for in-order
  pipelines)
- Forwarding path timing: which stage produces, which consumes
- Why load-use needs a stall (data isn't available until MEM stage, but
  EX needs it the cycle after ID)

---

## Stage 9 — Branch Handling

### Checklist

- [ ] Move branch resolution to EX stage (compare rs1 and rs2, compute
      branch target)
- [ ] Implement flush logic:
    - [ ] On taken branch: clear IF/ID and ID/EX pipeline registers
          (squash the two instructions fetched after the branch)
    - [ ] Feed branch target back to PC
- [ ] Implement static branch prediction: predict not-taken
    - [ ] Always fetch PC+4 after a branch
    - [ ] If branch is taken: flush and redirect
    - [ ] If branch is not taken: no penalty
- [ ] Add a flush counter / mispredict counter to the testbench
      (count how many times the pipeline flushes)
- [ ] Write bubble sort test program (`sw/test_sort.s`):
    - [ ] Sort a 10-element array in data memory
    - [ ] Store sorted result back to memory
- [ ] Run bubble sort — verify output is sorted correctly
- [ ] Check mispredict count — verify it matches expected taken-branch
      count
- [ ] Remove ALL NOP padding from ALL test programs — verify everything
      still works with full hazard + branch handling
- [ ] Re-run all compliance tests — all pass
- [ ] Write Blog Post 9: "Guessing the Future"
    - [ ] Explain branch penalty (2-cycle flush on mispredict)
    - [ ] Show predict-not-taken strategy
    - [ ] Count mispredicts on bubble sort
    - [ ] Tease dynamic prediction as a future topic
- [ ] Publish blog post

### Pass/fail gate

- [ ] Bubble sort on a 10-element array produces sorted output
- [ ] Count flushed instructions — verify it matches expected mispredicts
- [ ] No NOP padding anywhere — full hazard + branch handling

### What you'll need to learn

- Control hazards vs data hazards
- Branch penalty: how many cycles are wasted on a mispredict
- Why branch prediction matters (and why static is a reasonable start)

---

## Stage 10 — Integration + Benchmarking

### Checklist

- [ ] Add a cycle counter register to the core (counts clock cycles from
      reset)
- [ ] Add an instruction counter (counts retired instructions)
- [ ] Choose a benchmark program: bubble sort, Fibonacci, or similar
- [ ] Run the benchmark on the single-cycle core (Stage 5 version):
    - [ ] Record total cycles
    - [ ] Record total instructions
- [ ] Run the same benchmark on the pipelined core (Stage 9 version):
    - [ ] Record total cycles
    - [ ] Record total instructions
    - [ ] Record stall count (from hazard unit)
    - [ ] Record flush count (from branch handling)
- [ ] Calculate CPI (cycles per instruction) for both versions
- [ ] Run `make test` — all tests from all stages pass
- [ ] Final cleanup: consistent code style, comments on every module,
      README updated
- [ ] Write Blog Post 10: "Benchmarking the Pipeline"
    - [ ] Show the cycle/instruction/CPI numbers
    - [ ] Break down overhead: stalls vs flushes
    - [ ] Discuss: was pipelining worth it?
    - [ ] Show the final block diagram of the complete pipeline
- [ ] Publish blog post
- [ ] Update README with links to all 11 blog posts

### Pass/fail gate

- [ ] Program produces correct output
- [ ] Cycle count comparison printed: single-cycle vs pipelined
- [ ] `make test` runs all tests from all stages — all pass

### What you'll need to learn

- CPI (cycles per instruction) — the key metric for pipeline performance
- How to instrument a hardware design for performance measurement
- How to present benchmark data clearly (this is a blog skill)

---

## Stage 11 — FPGA Port (Stretch Goal)

**Requires:** Tang Nano 9K (~$15)

### Checklist

- [ ] Install open-source FPGA toolchain:
    - [ ] Yosys (synthesis)
    - [ ] nextpnr-gowin (place & route for Gowin FPGAs)
    - [ ] openFPGALoader (programming the board)
- [ ] Create `fpga/constraints.cst` — pin constraints for Tang Nano 9K:
    - [ ] Map clock input to 27 MHz on-board oscillator
    - [ ] Map LED outputs to on-board LEDs
    - [ ] (Optional) Map UART TX to a GPIO pin
- [ ] Create `fpga/top_fpga.sv` — FPGA top-level wrapper:
    - [ ] Clock divider (27 MHz → something visible for LEDs)
    - [ ] Reset synchronizer
    - [ ] Instantiate your core
    - [ ] Wire LED outputs to register values or memory contents
- [ ] Replace generic instruction/data memory with Gowin BSRAM instances
      (or let Yosys infer them)
- [ ] Create `fpga/Makefile` with `synth`, `pnr`, and `flash` targets
- [ ] Run synthesis — verify it completes without errors
- [ ] Check resource usage — verify it fits in the 9K LUT budget
- [ ] Write a simple LED blink program in RISC-V assembly:
    - [ ] Loop that toggles a memory-mapped register connected to LEDs
    - [ ] Delay loop for visible blink rate
- [ ] Flash the board — verify LED blinks
- [ ] (Stretch) Implement UART TX module:
    - [ ] Memory-mapped: write a byte to a specific address → sends it
          over UART
    - [ ] 115200 baud, 8N1
- [ ] (Stretch) Write a "Hello, World!" program that sends bytes over
      UART
- [ ] (Stretch) Connect a USB-serial adapter and verify output in a
      terminal
- [ ] Take a photo/video of the board running your CPU
- [ ] Write Blog Post 11: "From Simulation to Silicon"
    - [ ] Explain the synthesis flow
    - [ ] Show resource usage (LUTs, registers, BRAM)
    - [ ] Include photo/video
    - [ ] This is the Hacker News post
- [ ] Publish blog post

### Pass/fail gate

- [ ] Design synthesizes without errors
- [ ] Fits within the 9K LUT budget
- [ ] LED blinks in a pattern controlled by a program running on your CPU
- [ ] (Stretch) UART TX prints a message to a serial terminal

### What you'll need to learn

- FPGA synthesis flow: RTL → netlist → place & route → bitstream
- Gowin BSRAM: how to instantiate or infer block RAM
- Clock domain considerations: your sim had an ideal clock, real hardware
  has timing constraints
- Memory-mapped I/O: how hardware peripherals look like memory addresses
  to the CPU

---

## Definition of "Done" (Whole Project)

The project is **done** when:

1. ✅ A 5-stage pipelined RV32I core exists in SystemVerilog
2. ✅ It handles data hazards (forwarding + stalls) and control hazards
   (branch flush)
3. ✅ It passes at least 8 riscv-tests compliance tests
4. ✅ It runs a non-trivial program (sorting or similar) correctly
5. ✅ 10+ blog posts are published documenting the build
6. ✅ The repo README links to every blog post
7. 🔲 (Stretch) Running on Tang Nano 9K FPGA

Items 1–6 are the real definition of done. Item 7 is a bonus that makes
the blog dramatically more shareable.

---

## Blog → Revenue Connection

This project is the **content engine** for the passive income stack:

| After you finish... | You can create... |
|---|---|
| Stage 0–3 | Blog Post 0: publish, start SEO clock |
| Stage 5 | Study guide: "RV32I Instruction Set Cheat Sheet" (sell on Gumroad) |
| Stage 8 | Email course: "Build a CPU in 10 Emails" (lead magnet) |
| Stage 10 | Snippet pack: "RISC-V Testbench Recipes" (sell on Gumroad) |
| Stage 11 | Interview prep: "Hardware Interview Problems — Pipeline Edition" |
| Any time | Notion template: "RTL Project Tracker" based on your own workflow |

The CPU project generates the expertise. The blog documents it. The
products monetize the audience the blog attracts. Each piece feeds
the others.

---

## Tools & References

- [RISC-V Unprivileged Spec](https://riscv.org/technical/specifications/)
  — Chapter 2 only for RV32I
- [Verilator](https://www.veripool.org/verilator/) — open-source SV
  simulator
- [riscv-tests](https://github.com/riscv-software-src/riscv-tests) —
  compliance test suite
- [Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
  — $15 FPGA board
- [Yosys](https://github.com/YosysHQ/yosys) + [nextpnr-gowin](https://github.com/YosysHQ/nextpnr)
  — open-source synthesis
