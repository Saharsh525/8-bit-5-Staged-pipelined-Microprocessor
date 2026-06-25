# Custom 8-Bit Pipelined RISC Processor

A custom-designed **8-bit pipelined RISC microprocessor** implemented in **Verilog HDL** with a **16-bit instruction encoding format**. The processor architecture is inspired by simplified MIPS-style datapath principles and supports arithmetic, logical, memory-access, immediate, and branch instructions through a multi-stage pipelined execution model.

---

# Project Overview

This project focuses on the RTL design and implementation of a custom pipelined processor to understand the internal architecture of modern CPUs. The processor divides instruction execution into multiple stages, enabling simultaneous instruction execution and improving instruction throughput.

The processor includes:

- Custom Instruction Set Architecture (ISA)
- Multi-stage pipelined datapath
- ALU and register file implementation
- Instruction decoding and control signal generation
- Instruction and data memory support
- Branch handling logic
- Hazard mitigation using automatic NOP insertion

The entire processor was designed and verified using Verilog HDL through simulation and waveform analysis.

---

# Architecture Specifications

| Feature | Specification |
|---|---|
| Processor Type | Custom RISC Processor |
| Datapath Width | 8-bit |
| Instruction Width | 16-bit |
| Register Width | 8-bit |
| Register Address Width | 3-bit |
| General Purpose Registers | 8 Registers |
| Architecture Style | Pipelined |
| HDL Used | Verilog HDL |

---

# Processor Architecture

The processor follows a pipelined architecture consisting of multiple execution stages:

```text
Instruction Fetch → Instruction Decode → Execute → Memory Access → Write Back
```

The architecture includes:
- Program Counter (PC)
- Instruction Register
- Decoder Unit
- Register File
- Arithmetic Logic Unit (ALU)
- Control Unit
- Data Memory
- Pipeline Registers
- Hazard Mitigation Logic

---

# Processor Schematic

<p align="center">
  <img src=""images/processor_schematic.png"" width="900" alt="Processor Schematic">
</p>

*Figure 1: Complete processor datapath and control schematic implemented in Logisim.*

# Instruction Set Architecture (ISA)

The processor implements a custom **16-bit instruction format** inspired by simplified RISC/MIPS-style architectures.

Instructions are categorized into:
- R-Type Instructions
- I-Type Instructions
- J-Type Instructions

---

## R-Type Instructions

R-Type instructions are used for register-to-register arithmetic and logical operations.

### Instruction Format

```text
| Opcode | ALUFn | Rd | Ra | Rb |
| 15:13  | 12:11 |8:6 |5:3 |2:0 |
```

### Fields

| Field | Description |
|---|---|
| Opcode | Specifies instruction category |
| ALUFn | Selects ALU operation |
| Rd | Destination register |
| Ra | Source register A |
| Rb | Source register B |

### Supported R-Type Instructions

| ALUFn | Instruction | Operation |
|---|---|---|
| 00 | ADD | `Rd = Ra + Rb` |
| 01 | SUB | `Rd = Ra - Rb` |
| 10 | AND | `Rd = Ra & Rb` |
| 11 | OR  | `Rd = Ra \| Rb` |

---

## I-Type Instructions

I-Type instructions are used for immediate operations and memory-access instructions.

### Instruction Format

```text
| Opcode | Immediate | Register |
| 15:13  |   12:6    |   5:0    |
```

### Fields

| Field | Description |
|---|---|
| Opcode | Specifies instruction category |
| Immediate | Immediate constant/address |
| Register | Register operand |

### Supported I-Type Instructions

| Opcode | Instruction | Operation |
|---|---|---|
| 001 | ADDI / MOVI | Immediate arithmetic/data transfer |
| 010 | LOAD | Load data from memory |
| 011 | STORE | Store data into memory |

---

## J-Type Instructions

J-Type instructions are used for branch and control-flow operations.

### Instruction Format

```text
| Opcode | Branch / Jump Address |
| 15:13  |        12:0          |
```

### Supported J-Type Instructions

| Opcode | Instruction | Operation |
|---|---|---|
| 100 | BRANCH | Conditional branch |
| 101 | HALT | Stops processor execution |

---

# ALU Operations

The Arithmetic Logic Unit (ALU) performs arithmetic, logical, memory-address, and comparison operations based on the ALU control signal.

| ALUFn | Operation |
|---|---|
| 000 | ADD |
| 001 | SUB |
| 010 | AND |
| 011 | OR |
| 100 | Immediate arithmetic |
| 101 | Load address calculation |
| 110 | Store address calculation |
| 111 | Equality comparison |

---

# Control Unit

The control unit generates all major datapath control signals based on the decoded opcode and ALU function fields.

Generated control signals include:

- Register Write Enable
- ALU Source Selection
- Memory Read/Write Control
- Register Destination Selection
- Memory-to-Register Selection
- Branch/Instruction Address Control

This enables proper coordination between datapath components during pipelined execution.

---

# Hazard Mitigation

The processor includes basic hazard mitigation mechanisms implemented inside the instruction register module.

## Data Hazard Handling

Read-after-write dependencies are detected and mitigated by automatically inserting NOP instructions between dependent instructions.

- 3 NOP instructions are inserted for data hazards.

## Control Hazard Handling

Branch instructions introduce control hazards, which are mitigated through automatic pipeline stalling.

- 2 NOP instructions are inserted after branch instructions.

These mechanisms ensure stable pipeline execution and correct instruction sequencing.

---

# Simulation and Verification

The processor was functionally verified using RTL simulation and waveform analysis.

Verification included:
- Arithmetic operation testing
- Memory read/write validation
- Branch execution testing
- Pipeline synchronization verification
- Hazard mitigation validation

Waveforms were analyzed to verify:
- Register updates
- ALU outputs
- Memory operations
- Control signal generation
- Pipeline stage behavior

---

# Technologies Used

- Verilog HDL
- RTL Design
- Computer Architecture
- Digital Logic Design
- Pipeline Architecture
- Hazard Mitigation Techniques
- ModelSim / Icarus Verilog
- GTKWave

---

# Future Improvements

- Data forwarding unit implementation
- Dynamic hazard detection
- Branch prediction support
- Expanded instruction set
- Cache memory integration
- FPGA implementation
- Performance optimization

---

# Learning Outcomes

This project helped in understanding:
- Pipelined processor design
- Datapath and control-path integration
- RTL hardware design methodology
- Instruction-level parallelism
- Hazard detection concepts
- Verilog HDL implementation
- Processor verification techniques

---

# Author

**Saharsh Ashish Chokhandre**  
Electrical Engineering, IIT Indore
