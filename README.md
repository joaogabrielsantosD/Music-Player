# Project Overview

```bash
project/
├── src/           # .vhd (VHDL source), .bdf (block diagrams) files and .cmp (Component files)
│   ├── top.vhd    # Top-level Entity
│   └── modules/   # Reusable modules
├── test/          # Unity tests
├── sim/           # Testbenches and simulation vectors (.vwf, .tbl)
├── constraints/   # Pinout files (.tcl, .acf)
├── docs/          # Schematics, specifications
├── output/        # Output folder to Quartus compilation
└── README.md
```

- Can use the ```src/top.vhd``` (VHDL file) or ```tests/subtop_test.bdf``` (Block Diagram file) to flash the firmware.

### Top RTL connection using Blocks Diagrams
[<img src="docs/subtop_test.png" alt="Top RTL Block Diagram" width="500" />](docs/subtop_test.png)