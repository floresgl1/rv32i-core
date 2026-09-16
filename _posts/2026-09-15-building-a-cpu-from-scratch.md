---
layout: post
title: "I'm Building a CPU from Scratch"
date: 2026-09-15
---


## Why am I building a CPU from Scratch

The reason that I decided to pursue this specific project is that I realized that I have not really had any dedicated hardware projects under my belt. I have built a couple of software related projects on the side but there is a hardware specific gap in my portfolio that I would like to close at least a little bit.

## What RV32I is (the 40-instruction base integer ISA)

RV32I is the base 32 bit integer instruction set for RISC-V architecture. It is a load store architecture with fixed 32-bit instruction lengths, 32 general purpose registers. It supports arithmetic, logic, memory access and control flow

I chose this specifically because RV32I is minimal but also complete which allows learning to build a fully functional CPU with minimal instructions & makes it perfect for FPGA implementation without the microarchitecture of ISAs like x86 or ARM.
RV32I breaks down as RV (RISC-V), 32 (32-bit wide registers), I (integer base).

## What tools I will use and why

The tools I will use are Verilator, Yosys, nextpnr-gowin and RISC-V GNU toolchain. I choose all of these tools because they are all free and all open-sourced.
Verilator is open-sourced and supports System Verilog.
Yosys is a framework for Verilog RTL synthesis and has extensive support.
nextpnr-gowin is a portable FPGA place and route tool
RISC-V GNU toolchain is a pre-compiled family of GNU toolchains for RISC-V development.

## What the end goal looks like

The end goal is a fully functioning CPU built on RV32I that follows each of these stages. This project will follow 12 gates that each follow specific steps and tasks that will test my knowledge at each gate before moving onto the next. By the end I will have 5 stage pipelined RV32I core in System Verilog that handles data hazards and control hazards. The project is done when it passes at least 8 riscv-tests, runs non-trivial program correctly, at least 10+ blog post and the repo README links to every blog post.