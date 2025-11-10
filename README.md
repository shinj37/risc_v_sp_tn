# RV32I RISC-V Processor with planned SIMD Extensions

A hardware implementation of the RISC-V RV32I instruction set with planned SIMD (Single Instruction, Multiple Data) extensions, targeting the Tang Nano 20K FPGA development board.

## Disclaimer: This is a new working repository, that is why there are such few commits. There were issues with the previous one, so had to make a new one.  

## Overview

This project implements a 32-bit RISC-V processor core conforming to the RV32I base integer instruction set. The design is written in SystemVerilog and is optimized for the Gowin GW2AR-18 FPGA found on the Tang Nano 20K board. SIMD extensions for parallel data processing will be added to enhance multimedia and DSP capabilities.

### Current Features

- **RV32I Base ISA**: Implementation of the 32-bit RISC-V integer instruction set
- **SystemVerilog Design**: Modern HDL with enhanced verification capabilities
- **Modular Architecture**: Separate instruction memory, data memory, and register file modules
- **Quartus Prime Support**: Project files configured for Altera/Intel toolchain
- **ModelSim Simulation**: Complete testbench and simulation scripts

### Planned Features

- **SIMD Extensions**: Custom parallel processing instructions for vector operations
- **Performance Optimizations**: Pipeline improvements and hazard handling
- **Enhanced Peripherals**: UART, GPIO, and timer modules
- **Tang Nano 20K Port**: Migration from Quartus to Gowin EDA toolchain

## Target Hardware

**Board**: Sipeed Tang Nano 20K
- **FPGA**: Gowin GW2AR-LV18QN88C8/I7
- **Logic Elements**: 20,736 LUTs
- **Memory**: 828 Kbit BSRAM
- **Clock**: 27 MHz onboard oscillator
- **I/O**: 44 user GPIOs, HDMI output capability

**Current Development Platform**: Intel/Altera FPGA (via Quartus Prime)

## Architecture

### Single-Cycle Datapath

The processor follows the classic single-cycle RISC-V datapath design from Patterson & Hennessy's "Computer Organization and Design" (Figure 4.17). All instructions complete in one clock cycle.

![Datapath Diagram](https://github.com/user-attachments/assets/68eecff0-229b-4c35-ad2a-fa75159a6ddc)

### Datapath Components

#### Implemented Modules

1. **Program Counter (PC)**: Holds address of current instruction (to be implemented in topmodule.sv)
2. **Instruction Memory (inst_mem.sv)**: ✓ Stores program instructions
3. **Register File (reg_file.sv)**: ✓ 32 general-purpose registers (x0-x31)
4. **Data Memory (data_mem.sv)**: ✓ Load/store data memory

#### To Be Implemented

5. **Control Unit**: Generates control signals based on opcode
6. **ALU (Arithmetic Logic Unit)**: Performs arithmetic and logical operations
7. **Immediate Generator**: Extracts and sign-extends immediate values
8. **Branch Comparator**: Evaluates branch conditions
9. **Multiplexers**: Select between PC+4, branch target, ALU result, memory data

### Control Signals

The control unit will generate the following signals based on instruction opcode:

| Signal | Purpose |
|--------|---------|
| `ALUSrc` | Select ALU input (register vs immediate) |
| `MemtoReg` | Select write-back data (ALU result vs memory) |
| `RegWrite` | Enable register file write |
| `MemRead` | Enable data memory read |
| `MemWrite` | Enable data memory write |
| `Branch` | Instruction is a branch |
| `ALUOp` | ALU operation type |

### Instruction Flow

1. **Fetch**: PC addresses instruction memory, instruction is read
2. **Decode**: Instruction fields extracted, registers read, immediate generated
3. **Execute**: ALU performs operation (arithmetic, logic, address calculation)
4. **Memory**: Data memory accessed for load/store instructions
5. **Write-back**: Result written to register file
6. **PC Update**: PC incremented or updated with branch/jump target

### Current Modules

1. **topmodule.sv**: Top-level integration (control logic and datapath to be completed)
2. **inst_mem.sv**: Instruction memory module ✓
3. **data_mem.sv**: Data memory for load/store operations ✓
4. **reg_file.sv**: 32-register register file (x0-x31) ✓

## Directory Structure

```
.
├── db/                          # Database files (Quartus)
│   ├── RV321_RISC_V.db_info
│   └── RV321_RISC_V.quiproj.12880.rdr.flock
├── doc/                         # Documentation
│   └── README.md
├── rtl/                         # RTL source files
│   ├── data_mem.sv             # Data memory module
│   ├── data_mem.sv.bak         # Backup
│   ├── inst_mem.sv             # Instruction memory module
│   ├── inst_mem.sv.bak         # Backup
│   ├── reg_file.sv             # Register file module
│   ├── reg_file.sv.bak         # Backup
│   ├── topmodule.sv            # Top-level integration
│   └── topmodule.sv.bak        # Backup
├── sim/                         # Simulation scripts
│   ├── compile.do              # ModelSim compile script
│   ├── run.do                  # ModelSim run script
│   ├── save.do                 # Save simulation state
│   ├── setenv.do               # Environment setup
│   └── waves.do                # Waveform configuration
├── syn/                         # Synthesis files
│   ├── RV321_RISC_V.qpf        # Quartus project file
│   └── RV321_RISC_V.qsf        # Quartus settings file
└── tb/                          # Testbenches
    └── testbench.sv            # Main testbench
```

## RV32I Instruction Set

### Supported Instructions (Implementation Status)

#### Integer Computational Instructions
- **Arithmetic**: `ADD`, `SUB`, `ADDI`
- **Logical**: `AND`, `OR`, `XOR`, `ANDI`, `ORI`, `XORI`
- **Shifts**: `SLL`, `SRL`, `SRA`, `SLLI`, `SRLI`, `SRAI`
- **Compare**: `SLT`, `SLTU`, `SLTI`, `SLTIU`
- **Upper Immediate**: `LUI`, `AUIPC`

#### Control Transfer Instructions
- **Unconditional Jumps**: `JAL`, `JALR`
- **Conditional Branches**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`

#### Load and Store Instructions
- **Loads**: `LB`, `LH`, `LW`, `LBU`, `LHU`
- **Stores**: `SB`, `SH`, `SW`

#### System Instructions
- `FENCE`, `ECALL`, `EBREAK`

## SIMD Extensions (Planned)

The SIMD unit will extend the RV32I ISA with custom instructions for parallel operations on packed data types.

### Proposed SIMD Instructions

#### Vector Arithmetic
- `VADD.B` / `VADD.H`: Parallel addition (4×8-bit or 2×16-bit)
- `VSUB.B` / `VSUB.H`: Parallel subtraction
- `VMUL.B` / `VMUL.H`: Parallel multiplication
- `VMAX.B` / `VMAX.H`: Parallel maximum
- `VMIN.B` / `VMIN.H`: Parallel minimum

#### Vector Logical Operations
- `VAND`, `VOR`, `VXOR`: Bitwise vector operations
- `VNOT`: Vector bitwise NOT

#### Vector Compare & Select
- `VSEQ`, `VSNE`: Vector equality/inequality comparison
- `VSLT`, `VSLE`: Vector less than (signed)
- `VSLTU`, `VSLEU`: Vector less than (unsigned)

#### Vector Pack/Unpack
- `VPACK.H`: Pack two 16-bit values into 32-bit register
- `VUNPACK.H`: Unpack 32-bit value into two 16-bit values

### SIMD Programming Model

SIMD operations reuse the existing 32 general-purpose registers (x0-x31), with data interpreted as packed vectors:
- **4×8-bit mode**: Four 8-bit elements per register
- **2×16-bit mode**: Two 16-bit elements per register

Example:
```
Register x5: [byte3|byte2|byte1|byte0]
             or [half1|half0]
```

## Getting Started

### Prerequisites

#### Current Setup (Quartus)
- **Quartus Prime**: Intel FPGA development software
- **ModelSim**: For simulation (comes with Quartus)
- **RISC-V Toolchain**: `riscv32-unknown-elf-gcc` for software compilation

#### Future Setup (Tang Nano 20K)
- **Gowin EDA**: Download from [Gowin Semiconductor](https://www.gowinsemi.com/en/support/download_eda/)
- **RISC-V Toolchain**: `riscv32-unknown-elf-gcc`

### Building and Simulating

#### 1. Clone the Repository
```bash
git clone https://github.com/shinj37/rv321_riscv
cd RV321_RISC_V
```

#### 2. Compile and Simulate with ModelSim
```bash
cd sim

# Set up environment
vsim -do setenv.do

# Compile design files
vsim -do compile.do

# Run simulation
vsim -do run.do

# View waveforms
vsim -do waves.do
```

#### 3. Synthesize with Quartus Prime
```bash
cd syn

# Open Quartus project
quartus RV321_RISC_V.qpf

# Compile the design
quartus_sh --flow compile RV321_RISC_V
```

### Testbench Usage

The testbench (`tb/testbench.sv`) provides a verification environment for the processor core. Modify the testbench to add custom test vectors and instruction sequences.

```systemverilog
// Example test pattern
initial begin
    // Test ADD instruction
    // Test LOAD/STORE
    // Test branches
end
```

## Development Workflow

### Adding New Instructions

1. Update instruction decoder in `topmodule.sv`
2. Implement execution logic in ALU
3. Add test cases in `testbench.sv`
4. Run simulation to verify
5. Update documentation

### Simulation Best Practices

- Use `compile.do` to compile all design files
- Use `run.do` to execute testbenches
- Use `waves.do` to configure signal viewing
- Save checkpoints with `save.do` for long simulations

## Migration to Tang Nano 20K

The project is currently developed using Quartus Prime but will be migrated to Gowin EDA for Tang Nano 20K deployment.

### Migration Steps (Planned)

1. Create Gowin project file (`.gprj`)
2. Add constraint file for Tang Nano 20K pin assignments (`.cst`)
3. Adjust memory inference for Gowin BSRAM blocks
4. Optimize for Gowin architecture
5. Test on actual hardware

### Pin Assignment (To Be Defined)

Constraint file will map signals to Tang Nano 20K pins:
- Clock input: 27 MHz onboard oscillator
- Reset button
- UART TX/RX for program loading
- LED indicators for debugging
- GPIO for general I/O

## Performance Targets

### Resource Utilization Goals

| Resource | Target | Tang Nano 20K Available |
|----------|--------|-------------------------|
| LUTs     | <8,000 | 20,736                 |
| FFs      | <6,000 | 15,552                 |
| BSRAM    | <256 Kb| 828 Kb                 |

### Timing Goals

- **Clock Frequency**: 50 MHz minimum
- **CPI (Cycles Per Instruction)**: 
  - Single-cycle: 1 CPI (ideal)
  - Pipelined: Approaching 1 CPI with hazard handling

### SIMD Performance Multiplier

- **8-bit operations**: 4× throughput vs scalar
- **16-bit operations**: 2× throughput vs scalar

## Roadmap

### Phase 1: Core RV32I Implementation ✓
- [x] Register file module
- [x] Instruction memory
- [x] Data memory
- [x] Project structure
- [x] Complete instruction decoder
- [x] ALU implementation
- [x] Control unit
- [x] Branch/Jump logic

### Phase 2: Verification & Testing
- [ ] Comprehensive testbenches
- [ ] Instruction set verification
- [ ] Compliance testing with RISC-V tests
- [ ] Code coverage analysis

### Phase 3: SIMD Extensions
- [ ] SIMD unit architecture design
- [ ] Vector ALU implementation
- [ ] Instruction encoding for SIMD ops
- [ ] SIMD testbenches

### Phase 4: Tang Nano 20K Port
- [ ] Gowin EDA project setup
- [ ] Pin constraints
- [ ] Memory optimization
- [ ] On-board testing

### Phase 5: Peripherals & Software
- [ ] UART for serial communication
- [ ] GPIO controller
- [ ] Timer/Counter
- [ ] Bootloader
- [ ] Example programs
- [ ] SIMD benchmarks

## Resources

### RISC-V Documentation
- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RV32I Base Integer Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
- [RISC-V Assembly Programmer's Manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/master/riscv-asm.md)

### Development Tools
- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [Quartus Prime](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html)
- [Gowin EDA](https://www.gowinsemi.com/en/support/download_eda/)

### Tang Nano 20K Resources
- [Tang Nano 20K Wiki](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html)
- [Tang Nano 20K Schematic](https://dl.sipeed.com/shareURL/TANG/Nano_20K)
- [Gowin FPGA User Guide](https://www.gowinsemi.com/en/support/home/)

### SIMD & Vector Processing
- [RISC-V Vector Extension](https://github.com/riscv/riscv-v-spec)
- [DSP and SIMD Design Patterns](https://en.wikipedia.org/wiki/SIMD)

## Contributing

Contributions are welcome! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

## Acknowledgments

- RISC-V Foundation for the open ISA specification
- Sipeed for the Tang Nano 20K development board
- Intel/Altera for Quartus Prime tools
- Open-source RISC-V community

## Contact

For questions, issues, or suggestions:
- **Issues**: Use the GitHub issue tracker
- **Discussions**: Start a discussion in the repository

---

**Project Status**: 🚧 Under Active Development

This is an educational and experimental project. The core RV32I implementation is in progress, with SIMD extensions planned for future phases.
