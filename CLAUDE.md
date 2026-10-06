# CLAUDE.md — rv32i-core

Read ROADMAP.md at the repo root for full context, the stage-by-stage
build plan, pass/fail gates, and checklists. ROADMAP.md is the single
source of truth. This file is guardrails that apply every session.

## This is a hardware project

This repo is SystemVerilog RTL — not software. Before writing any SV:

1. **Describe the hardware first.** What registers, what muxes, what
   datapath, what control signals? Sketch the block diagram (even ASCII)
   before opening a `.sv` file.
2. **Think about timing.** What happens on each clock edge? What's
   combinational vs sequential? Don't let SV read like C.
3. **Plan verification before implementation.** What does the testbench
   need to check? What are the corner cases? Write or outline the `_tb.sv`
   before or alongside the module, never after.

## This is a learning project

The owner is building this to learn CPU architecture from the ground up.

- **Default to hints and skeleton code**, not complete implementations.
  The owner needs to understand every line.
- **Only give the full solution when explicitly asked.** If unsure
  whether they want the answer or a hint, ask.
- **Explain the "why"** behind every design decision — not just what
  to type. Each stage feeds a blog post, so the reasoning matters as
  much as the code.

## Stage discipline

- Work **one stage at a time** per ROADMAP.md. Don't jump ahead.
- Each stage has a checklist and pass/fail gate. The gate must pass
  before moving on.
- Every stage produces a **blog post**. Don't skip the writing.

## Knowledge checks

A multiple-choice quiz tests recognition, not recall, so it is a
warm-up, not the gate. Every stage's knowledge check has three parts,
in order. All three must pass, along with the stage's own gate in
ROADMAP.md, before moving on. All three cover the hardware concepts,
design decisions, and "why" behind the implementation, not syntax or
trivia.

1. **Warm-up quiz.** A quiz widget, at least 90% to pass. If the owner
   fails, generate a new quiz with different questions before another
   attempt. For every missed question, the owner explains the correct
   answer in their own words before moving on.
2. **Predict, then simulate.** Before running `make sim` or opening a
   waveform, the owner writes down the expected values: signal values
   cycle by cycle (PC, instruction word, control signals, register
   writes) for a short instruction sequence, and the expected PASS/FAIL
   cases. Then run it and compare. Any mismatch is a gap in the mental
   model of the hardware: find the wrong assumption before continuing.
   Don't accept "close enough" on a cycle count or a bit field.
3. **Explain it out loud.** Open questions with no options to pick from,
   for example: "trace `addi x1, x0, 5` through the datapath, naming every
   mux select", or "what's combinational here, what's registered, and
   why?" Push on anything vague or memorized-sounding until it's
   explained plainly or admitted unknown. Treat it like a hardware
   interview deep-dive. It passes when the stage's core "why" questions
   are answered without prompting.

No moving to the next stage until all three pass. Update the ROADMAP
checklist once they do.

## Directory conventions

```
rtl/     SystemVerilog source — the CPU modules
tb/      Testbenches — one *_tb.sv per module
sim/     Simulation scripts + Makefile
sw/      Test programs (RISC-V assembly)
docs/    Blog drafts, diagrams, notes
fpga/    FPGA constraints + build (Tang Nano 9K, Stage 11)
```

## Development loop

```
make lint   →  Verilator lint check (must pass, no warnings)
make sim    →  Compile + run testbench (must print PASS)
```

Every module must pass both before committing.

## Tool conventions

- **Verilator** for simulation (not iverilog, not ModelSim)
- **Yosys + nextpnr-gowin** for FPGA synthesis (Stage 11 only)
- **RISC-V GNU toolchain** for assembling test programs
- All tools are free and open-source — keep it that way

## Things to never do

- Don't skip the testbench. No untested modules.
- Don't "fix" something in a future stage to unblock the current one.
  If the gate doesn't pass, the current stage isn't done.
- Don't add extensions (M, C, Zicsr, etc.). This is RV32I base only —
  37 instructions, nothing more.
- Don't optimize for clock speed or area before the pipeline works.
  Correctness first, performance second.
