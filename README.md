# SBUMIPS - 6-Stage Pipelined MIPS Processor

A fully functional 6-stage pipelined MIPS processor implementation in Verilog, featuring advanced hazard detection, data forwarding, and branch prediction mechanisms.

## Architecture Overview

This processor implements a classic MIPS pipeline extended to 6 stages for enhanced performance and educational clarity:

1. **IF (Instruction Fetch)** - Fetches instructions from instruction memory
2. **ID (Instruction Decode)** - Decodes instructions, reads registers, and generates control signals
3. **EX (Execute)** - Performs ALU operations with forwarding support
4. **MEM (Memory Access)** - Handles data memory reads/writes
5. **WB (Write Back)** - Writes results back to the register file
6. **Branch Resolution** - Integrated branch prediction and correction

## Key Features

### Hazard Handling
- **Data Hazard Detection**: Automatic detection of RAW (Read-After-Write) dependencies
- **Load-Use Hazard Stalling**: Pipeline stalls when a load instruction is followed by a dependent instruction
- **Data Forwarding**: Full forwarding paths from EX/MEM and MEM/WB stages to resolve data hazards without stalling

### Branch Prediction
- **2-bit Saturating Counter Predictor**: 1024-entry branch prediction table
- **Dynamic Branch Resolution**: Corrects mispredictions and updates prediction state
- **Reduced Branch Penalty**: Minimizes pipeline flushes through accurate prediction

### Control Unit
- Supports multiple instruction types:
  - **R-type**: ADD, SUB, AND, OR, SLT, SLL, etc.
  - **I-type**: ADDI, LW, SW, BEQ, BNE
  - **J-type**: J, JAL (Jump instructions)

### Memory System
- **Instruction Memory**: 256-word capacity (8-bit PC addressing)
- **Data Memory**: 256-word capacity with synchronous read/write
- **Pre-loaded Program**: Fibonacci sequence generator included as demonstration

## Directory Structure

```
sbumips/
├── mips_topmodeule.v          # Top-level pipeline integration
├── tb.v                        # Testbench with cycle-by-cycle tracing
├── stages/
│   ├── IF.v                    # Instruction Fetch stage
│   ├── ID.v                    # Instruction Decode stage
│   ├── EX.v                    # Execute stage
│   ├── Mem.v                   # Memory Access stage
│   └── WB.v                    # Write Back stage
├── reg_pipline/
│   ├── IF_ID.v                 # IF/ID pipeline register
│   ├── ID_EX.v                 # ID/EX pipeline register
│   ├── EX_MEM.v                # EX/MEM pipeline register
│   └── MEM_WB.v                # MEM/WB pipeline register
├── hazard/
│   └── hazard_detect.v         # Hazard detection unit
├── forward/
│   └── forward_detect.v        # Data forwarding unit
└── predict/
    └── predict.v               # Branch prediction unit
```

## Getting Started

### Prerequisites
- Icarus Verilog (iverilog) or any Verilog simulator
- GTKWave (optional, for waveform viewing)

### Compilation and Simulation

```bash
# Compile the design
iverilog -o mips_topmodeule.v.out tb.v

# Run simulation
vvp mips_topmodeule.v.out

# View waveforms (optional)
gtkwave pipeline_cpu_trace.vcd
```

### Expected Output

The testbench runs a Fibonacci sequence generator and displays:
- Program Counter (PC) values at each stage
- Instruction flow through the pipeline
- ALU results and branch decisions
- Memory contents showing computed Fibonacci numbers
- Register file state changes

Example output:
```
----- Cycle 10 -----
IF Stage: PC = 40, PC+4 = 44
ID Stage: RS = 8, RT = 9, RD = 12
EX Stage: ALU_result = 2, zero = 0
MEM Stage: final_result = 2
Data Memory (addresses 0-5):
  Memory[0] = 0
  Memory[1] = 1
  Memory[2] = 1
  Memory[3] = 2
  Memory[4] = 3
  Memory[5] = 5
```

## Implementation Details

### Pipeline Registers
Each pipeline register captures and propagates:
- Data values (instructions, operands, results)
- Control signals (RegWrite, MemRead, MemWrite, etc.)
- Metadata (register addresses, PC values)

### Forwarding Logic
The forwarding unit implements priority-based forwarding:
1. **EX/MEM forwarding** (higher priority) - forwards from the previous instruction
2. **MEM/WB forwarding** (lower priority) - forwards from two instructions back

### Hazard Detection
Detects load-use hazards by comparing:
- Destination register of load instruction (ID/EX stage)
- Source registers of following instruction (IF/ID stage)

When detected, the pipeline stalls by:
- Holding IF and ID stages
- Inserting a bubble (NOP) in the EX stage

### Branch Prediction
Uses a 2-bit saturating counter with four states:
- `00`: Strongly Not Taken
- `01`: Weakly Not Taken
- `10`: Weakly Taken
- `11`: Strongly Taken

Prediction is updated on every branch resolution, reducing misprediction penalties.

## Supported Instructions

| Type | Instruction | Opcode | Description |
|------|-------------|--------|-------------|
| R-type | ADD | 000000 | Add two registers |
| R-type | SUB | 000000 | Subtract two registers |
| R-type | AND | 000000 | Bitwise AND |
| R-type | OR | 000000 | Bitwise OR |
| R-type | SLT | 000000 | Set on less than |
| I-type | ADDI | 001000 | Add immediate |
| I-type | LW | 100011 | Load word |
| I-type | SW | 101011 | Store word |
| I-type | BEQ | 000100 | Branch if equal |
| I-type | BNE | 000101 | Branch if not equal |
| J-type | J | 000010 | Jump |

## Performance Characteristics

- **CPI (Cycles Per Instruction)**: ~1.2-1.5 (depending on hazards and branches)
- **Pipeline Depth**: 6 stages
- **Maximum Frequency**: Limited by critical path in ALU stage
- **Branch Prediction Accuracy**: ~85-90% for typical programs

## Testing and Verification

The included testbench (`tb.v`) provides:
- Cycle-by-cycle execution trace
- Register file monitoring
- Memory state inspection
- VCD waveform generation for debugging

To add custom test programs, modify the `instructionSET` initialization in `stages/IF.v`.

## Educational Value

This implementation is ideal for:
- Computer architecture courses
- Understanding pipeline hazards and their solutions
- Learning Verilog HDL design patterns
- Exploring branch prediction techniques
- FPGA prototyping projects

## Future Enhancements

Potential improvements:
- [ ] Exception and interrupt handling
- [ ] Cache memory hierarchy
- [ ] Out-of-order execution
- [ ] Floating-point unit (FPU)
- [ ] Multi-cycle instruction support
- [ ] FPGA synthesis and deployment

## License

This project is open-source and available for educational purposes.

## Authors

Amirreza Yazdanpanah 

Iman Babajani 

Mahdi Karimi

## Acknowledgments

Developed as part of computer architecture coursework, demonstrating practical implementation of pipelined processor design principles.

---
