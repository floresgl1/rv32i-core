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

Before clearing any stage gate, quiz the owner on the key concepts from
that stage. The quiz must:

- Cover the hardware concepts, design decisions, and "why" behind the
  implementation — not just syntax or trivia
- Require at least 90% to pass
- If the owner fails, generate a new quiz with different questions
  before allowing another attempt
- No moving to the next stage until the quiz is passed
- Create the quiz as a widget on each pass
- Update ROADMAP checklist after knowledge check is passed.

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
