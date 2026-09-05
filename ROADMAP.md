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

### What you build

1. **Repo structure** — directories, Makefile, linting config
2. **Blog** — GitHub Pages site (Jekyll or Hugo, minimal theme)
3. **Blog Post 0** — "I'm Building a RISC-V CPU from Scratch"
   - Why you're doing this
   - What RV32I is (the 40-instruction base integer ISA)
   - What tools you'll use and why (all free/open-source)
   - What the end goal looks like
4. **Simulation environment** — Verilator installed, a trivial "hello"
   module that compiles and runs

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

### What you build

- **Instruction memory** — a ROM loaded from a hex file
- **Program counter** — register, increments by 4 each cycle
- **Fetch unit** — PC → instruction memory → 32-bit instruction
- **Decoder** — splits the instruction into opcode, rd, rs1, rs2, funct3,
  funct7, and immediate (correctly sign-extended for each format)

### Pass/fail gate

- [ ] Testbench loads a hex file with at least one of each format type
      (R, I, S, B, U, J) and prints decoded fields
- [ ] All decoded fields match hand-calculated expected values
- [ ] `make sim STAGE=1` runs clean with zero warnings

### Blog post: "Decoding RISC-V Instructions by Hand"

Walk through the instruction encoding table. Show a hex instruction,
decode it bit by bit, then show the hardware doing the same thing.

---

## Stage 2 — ALU + Register File

### What you build

- **Register file** — 32 registers × 32 bits. Two read ports, one write
  port. x0 hardwired to zero.
- **ALU** — supports all RV32I operations: ADD, SUB, AND, OR, XOR, SLT,
  SLTU, SLL, SRL, SRA

### Pass/fail gate

- [ ] Write a value to every register, read it back — all match
- [ ] Write to x0, read x0 — always returns 0
- [ ] Every ALU operation tested against at least 3 input pairs
      (including edge cases: negative numbers, shift by 0, shift by 31)
- [ ] All tests automated in testbench — no manual inspection

### Blog post: "The Arithmetic Heart of a CPU"

Explain what an ALU actually is (not just "it does math"). Show the
hardware structure: a mux selecting between operations. Discuss why
x0 is hardwired to zero (it's a design trick, not a waste).

---

## Stage 3 — Single-Cycle Datapath

### What you build

- **Immediate generator** — decodes the immediate value for each format
- **Datapath wiring** — fetch → decode → register read → ALU → write-back
- **Data memory** — for load/store instructions (LW/SW only to start)
- **Top-level module** — wires everything together

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

### Blog post: "My CPU Ran Its First Program"

The most satisfying post. Show the waveform. Trace the data through
each stage. This is the moment it stops being "some logic" and starts
being "a computer."

---

## Stage 4 — Control Unit + Branches

### What you build

- **Control unit** — generates control signals (RegWrite, MemRead,
  MemWrite, Branch, ALUSrc, ALUOp, MemToReg) from the opcode
- **Branch comparator** — BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Jump logic** — JAL, JALR
- **PC update logic** — next PC = PC+4, or branch target, or jump target

### Pass/fail gate

- [ ] Iterative factorial program:
      ```
      # Compute 5! = 120
      addi x1, x0, 5     # n = 5
      addi x2, x0, 1     # result = 1
      loop:
        mul ... — wait, RV32I has no MUL.
        # Use repeated addition or shift-add for multiply
        beq x1, x0, done
        # multiply result by x1 using add loop
        ...
        addi x1, x1, -1
        jal x0, loop
      done:
        sw x2, 0(x0)      # mem[0] = 120
      ```
      (Exact program TBD — the point is a loop with branches)
- [ ] Final value in memory = 120
- [ ] Program terminates (doesn't loop forever)

### Blog post: "Teaching My CPU to Make Decisions"

Explain branches as the thing that makes a CPU more than a calculator.
Show the control unit truth table. Trace a branch taken vs not-taken.

---

## Stage 5 — Full Single-Cycle RV32I

### What you build

- All remaining RV32I instructions: LUI, AUIPC, all load/store widths
  (LB, LH, LBU, LHU, SB, SH), all branch variants
- Clean up and refactor

### Pass/fail gate

- [ ] Pass at least 8 riscv-tests: ADD, SUB, AND, OR, BEQ, JAL, LW, SW
- [ ] All tests run via `make test` with clear PASS/FAIL output
- [ ] No lint warnings

### Blog post: "All 37 Instructions"

Reflect on what it took. Show the compliance test results. This is the
"complete single-cycle CPU" milestone.

---

## Stage 6 — Pipeline: IF/ID Split

### What you build

- Pipeline register between IF and ID
- Clock the instruction through the register
- No hazard handling — just the structural split

### Pass/fail gate

- [ ] All Stage 5 tests still pass (no regressions)
- [ ] Waveform shows instruction moving through pipeline register with
      one cycle delay

### Blog post: "Splitting the Datapath"

Explain pipelining by analogy (laundry, assembly line). Show before/after
timing diagrams. This is the "why" post before the "how" posts.

---

## Stage 7 — Full 5-Stage Pipeline

### What you build

- Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB
- Each stage does its piece and passes results forward
- **No hazard handling yet** — only test with programs that have no
  dependencies between adjacent instructions (pad with NOPs if needed)

### Pass/fail gate

- [ ] NOP-padded versions of earlier test programs produce correct results
- [ ] Waveform shows 5 instructions in-flight simultaneously

### Blog post: "Why CPUs Overlap Work"

Show the pipeline diagram. Count cycles: single-cycle vs pipelined on
the same NOP-padded program. The speedup isn't dramatic yet (NOPs waste
slots), but the structure is there.

---

## Stage 8 — Hazard Detection + Forwarding

### What you build

- **Hazard detection unit** — detects RAW dependencies
- **Forwarding paths** — EX→EX and MEM→EX
- **Stall logic** — load-use hazard inserts a bubble

### Pass/fail gate

- [ ] Remove all NOP padding from test programs — results still correct
- [ ] Specifically test:
  - Back-to-back ADD (x1 = x2 + x3; x4 = x1 + x5) — forwarding
  - Load followed by use (LW x1; ADD x2, x1, x3) — stall + forward
- [ ] No `X` values in forwarded data

### Blog post: "When the Pipeline Lies to Itself"

Explain data hazards. Show what goes wrong without forwarding (read stale
register value). Show the forwarding mux. This is the hardest concept in
the series — draw diagrams.

---

## Stage 9 — Branch Handling

### What you build

- Branch resolution in EX stage
- Flush logic — squash instructions fetched after a taken branch
- Simple static prediction: predict not-taken

### Pass/fail gate

- [ ] Bubble sort on a 10-element array produces sorted output
- [ ] Count flushed instructions — verify it matches expected mispredicts
- [ ] No NOP padding anywhere — full hazard + branch handling

### Blog post: "Guessing the Future"

Explain the branch penalty. Show predict-not-taken. Count mispredicts
on the bubble sort. Tease: "real CPUs use dynamic predictors, but that's
a future post."

---

## Stage 10 — Integration + Benchmarking

### What you build

- Run a meaningful program: bubble sort, Fibonacci sequence, or similar
- Instrument cycle counter
- Compare single-cycle (Stage 5) vs pipelined (Stage 9) on the same
  program

### Pass/fail gate

- [ ] Program produces correct output
- [ ] Cycle count comparison printed: single-cycle vs pipelined
- [ ] `make test` runs all tests from all stages — all pass

### Blog post: "Benchmarking the Pipeline"

Show the numbers. Discuss CPI (cycles per instruction). Was pipelining
worth it? (Spoiler: yes, but the forwarding and stall logic eat into
the gains.)

---

## Stage 11 — FPGA Port (Stretch Goal)

**Requires:** Tang Nano 9K (~$15)

### What you build

- Synthesis constraints for Gowin GW1NR-9
- Clock domain: use the on-board 27 MHz oscillator
- I/O mapping: LEDs for status, optional UART TX for serial output
- Memory: use on-chip BSRAM for instruction + data memory

### Pass/fail gate

- [ ] Design synthesizes without errors
- [ ] Fits within the 9K LUT budget
- [ ] LED blinks in a pattern controlled by a program running on your CPU
- [ ] (Stretch) UART TX prints a message to a serial terminal

### Blog post: "From Simulation to Silicon"

The grand finale. Photo of the board. Video of the LED. This is the post
that gets shared on Hacker News.

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
