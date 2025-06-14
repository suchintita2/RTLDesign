# RISC-V RTL Processor Design

This project implements three microarchitectures of a 32-bit RISC-V processor using Verilog:
- ✅ Single-cycle
- ✅ Multi-cycle
- ⚠️ Pipelined (Work in Progress)

The goal is to understand and compare the datapath and control logic complexities involved in these architectures, and to simulate the execution of basic RISC-V instructions.

---

## 🧠 Architectures Overview

| Core Type     | Status          | Highlights |
|--------------|-----------------|------------|
| Single-cycle | ✅ Functional    | All instructions execute in 1 clock cycle |
| Multi-cycle  | ✅ Functional    | FSM-based control with shared datapath units |
| Pipelined    | ⚠️ In Progress   | Forwarding logic added; branch/store handling under debugging |


![Single-Cycle Microarchitecture](images/Single-cycle_Processor.png)
Single-Cycle Processor

![Multicycle Microarchitecture](images/Multicycle_Processor.png)
Multipath Processor

![Pipelined Microarchitecture](images/Pipelined_Processor.png)
Pipelined Processor

---

## 🧰 Tools Used

- **Language**: Verilog HDL
- **Simulation**: ModelSim 
- **ISA**: RISC-V RV32I (Integer Base Instruction Set)
- **Diagram References**: Based on *Computer Organization and Design – Patterson & Hennessy*

---

## 📁 Folder Structure


RTLDesign/
├── single_cycle/
├── multi_cycle/
├── pipelined/      <– (Work in Progress)
├── memfile.hex     <– Instructions
└── README.md

## 👩‍💻 Author

Suchintita Ghosh  
4th Year B.Tech ECE, VIT Vellore  
---
