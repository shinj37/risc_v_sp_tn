# RV32I RISC-V Pipelined Processor

## Overview
5-stage pipelined processor implementing subset of RV32I instruction set.

## Architecture
```
[IF] → [IF/ID] → [ID] → [ID/EX] → [EX] → [EX/MEM] → [MEM] → [MEM/WB] → [WB]
```

## Hazard Handling
- **Data Forwarding:** MEM→EX and WB→EX paths
- **Load-Use Detection:** Automatic stall insertion
- **Control Hazard:** Branch flush

## Supported Instructions
- R-type: ADD, SUB, AND, OR
- I-type: ADDI, LD
- S-type: SD
- B-type: BEQ

## Current Status
Core pipeline architecture complete with hazard handling infrastructure.
Active development on verification and instruction set expansion.

## Files
- `control.sv` - Control unit (opcode decoder)
- `hazard_detection.sv` - Hazard detection unit
- `forwarding.sv` - Forwarding unit
- `fetch_decode.sv` - IF/ID pipeline register
- `decode_execute.sv` - ID/EX pipeline register
- `execute_mem.sv` - EX/MEM pipeline register
- `mem_wb.sv` - MEM/WB pipeline register
