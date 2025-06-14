# Multi-Cycle RISC-V Processor

## 🧠 Architecture

Implements a 32-bit RISC-V core using a multi-cycle architecture where each instruction takes multiple clock cycles depending on the type.

### Key Features:
- Shared ALU for all operations
- Instruction cycle broken into multiple steps: IF → ID → EX → MEM → WB
- FSM-based control logic to sequence operations
- Reduced hardware area compared to single-cycle design

### Components:
- Program Counter
- Instruction Memory
- Control FSM
- Register File
- ALU with multiplexer-based control
- Data Memory
- Pipeline-like datapath register simulation (if any)

## ✅ Status

- Fully tested with basic R, I, S, and B-type instructions
- FSM transitions validated with waveform
- Branches and memory instructions handled correctly


## 🖼️ Architecture Diagram

![MultiCycle Datapath](../images/Multicycle_Processor.png)

## 📌 Notes

- Trade-off: Higher CPI, but simpler control and shared datapath
- FSM logic can be extended for more instruction types
