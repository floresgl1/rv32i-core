# rv32i-core

A pipelined RISC-V RV32I CPU core built from scratch in SystemVerilog —
documented as a blog series.

## What Is This?

A from-scratch implementation of the RISC-V RV32I (32-bit base integer)
instruction set in SystemVerilog. The build progresses from a single-cycle
design to a full 5-stage pipeline with hazard detection and forwarding.

Every stage is documented as a blog post explaining not just *what* was
built but *why* each design decision was made.

## Project Structure

```
rv32i-core/
├── rtl/           # SystemVerilog source — the CPU itself
├── tb/            # Testbenches
├── sim/           # Simulation scripts + Makefile
├── sw/            # Test programs (RISC-V assembly)
├── docs/          # Blog drafts, diagrams, notes
├── fpga/          # FPGA constraints + build (Tang Nano 9K)
├── ROADMAP.md     # Full stage-by-stage build plan with pass/fail gates
└── README.md      # You are here
```

## Toolchain

All free, all open-source:

- **[Verilator](https://www.veripool.org/verilator/)** — simulation
- **[Yosys](https://github.com/YosysHQ/yosys)** — synthesis (FPGA stage)
- **[nextpnr-gowin](https://github.com/YosysHQ/nextpnr)** — place & route
  for Tang Nano 9K
- **RISC-V GNU Toolchain** — assembling test programs

## Current Stage

**Stage 0 — Setup.** See [ROADMAP.md](ROADMAP.md) for the full plan.

## Blog

*Coming soon — link will be added here once the GitHub Pages site is live.*

## License

MIT
