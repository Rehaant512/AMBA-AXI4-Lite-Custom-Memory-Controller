# AMBA AXI4-Lite Memory Controller

A synthesizable, parameterized AMBA AXI4-Lite memory controller designed in Verilog for efficient ASIC and FPGA integration. The hierarchical RTL architecture enforces strict protocol compliance while providing byte-level write masking and robust hardware protection against out-of-bounds memory accesses.

## System Architecture

The design is split into modular components separating the AXI protocol controller, the central memory array, and the top-level interconnection wrapper.

As shown in the architecture breakdown, the design relies on:

*   **Top-Level Interconnect (`axi4_lite_top.v`):** A structural wrapper that declares the external SoC pins and wires the internal protocol controller directly to the memory subsystem using internal data and control wires.
*   **Protocol Controller (`axi4_lite_ctrl.v`):** The core finite state machine operating on `S_AXI_ACLK` and `S_AXI_ARESETN`. It handles the asynchronous dependencies of the five AXI4-Lite channels, enforces address boundary limits (`10'h200`), and translates standard AXI VALID/READY handshakes into primitive memory enable signals.
*   **Central Memory Array (`memory_array.v`):** A parameterized synchronous memory array supporting byte-level write masking via `WSTRB` and registered read outputs for zero-data-loss fetches.

## Signal Definitions

The external and internal logic utilizes the following key AXI4-Lite signals:

| Signal Name | Description |
| :--- | :--- |
| `S_AXI_ACLK` / `S_AXI_ARESETN` | Global clock / Active-low synchronous reset |
| `S_AXI_AWADDR` / `S_AXI_ARADDR` | Write address bus / Read address bus |
| `S_AXI_WDATA` / `S_AXI_RDATA` | Write data bus / Read data bus |
| `S_AXI_WSTRB` | Byte-enable strobe for partial word writes |
| `S_AXI_AWVALID` / `S_AXI_AWREADY` | Write address valid / Write address ready handshakes |
| `S_AXI_WVALID` / `S_AXI_WREADY` | Write data valid / Write data ready handshakes |
| `S_AXI_BVALID` / `S_AXI_BREADY` | Write response valid / Write response ready handshakes |
| `S_AXI_ARVALID` / `S_AXI_ARREADY` | Read address valid / Read address ready handshakes |
| `S_AXI_RVALID` / `S_AXI_RREADY` | Read data valid / Read data ready handshakes |
| `S_AXI_BRESP` / `S_AXI_RRESP` | Write response status / Read response status (e.g., OKAY, SLVERR) |

## Verification and Simulation

The design includes a comprehensive, self-checking Verilog testbench (`axi4_lite_tb.v`). It features automated task-based stimulus (`axi_write`, `axi_read`), a 200 MHz simulated clock generation, and rigorous negative testing for edge-case memory access violations.

### Waveform Analysis
The simulation proves correct non-blocking channel behavior and strict VALID/READY handshaking on the rising clock edge. It validates successful write data captures along with their corresponding `BRESP` assertions, and confirms correctly pipelined memory reads via the registered RDATA path, designed for Block RAM inference on FPGA targets.

<img width="1547" height="657" alt="Screenshot 2026-09-03 234602" src="https://github.com/user-attachments/assets/c8a17aea-1b75-486e-978b-e479a73295ec" />

### Automated Checker Results
A dedicated verification monitor checks the data and response codes (`BRESP`/`RRESP`) exactly as they exit the controller. The testbench yields dynamic success logs for valid boundary transactions and correctly flags `SLVERR` (Slave Error) during illegal out-of-bounds access attempts.

<img width="485" height="294" alt="Screenshot 2026-09-03 234624" src="https://github.com/user-attachments/assets/a5043216-3d1b-41fa-8a76-33410c765dd9" />
