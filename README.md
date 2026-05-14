# Parameterized Weighted Round Robin Arbiter (AXI-Style Handshake)

## Overview

This project implements a fully synthesizable **Parameterized Weighted Round Robin (WRR) Arbiter** in Verilog.

The arbiter supports:

- Configurable number of masters
- Weighted bandwidth allocation
- AXI-style VALID/READY handshake
- FSM-controlled arbitration
- Fair scheduling without starvation
- Reusable SoC interconnect architecture

The design models real arbitration logic used in:

- AXI Interconnects
- NoC Routers
- DDR Controllers
- DMA Fabrics
- GPU Memory Schedulers
- Ethernet Switch Fabrics

---

# Features

- Parameterized number of requesters (`N`)
- Weighted Round Robin scheduling
- AXI VALID/READY handshake support
- FSM-based control architecture
- One-hot grant generation
- Dynamic requester rotation
- Synthesizable Verilog RTL
- Modular reusable IP design
- Scalable arbitration architecture
- Starvation-free scheduling

---

# Technologies Used

- Verilog HDL
- FSM-Based Digital Design
- AXI Handshake Concepts
- Weighted Scheduling Algorithms
- RTL Design Methodology
- Parameterized Hardware Design

---

# Architecture Overview

```text
Requesters
    ↓
Weighted Round Robin Scheduler
    ↓
FSM Arbitration Logic
    ↓
VALID/READY Handshake Control
    ↓
One-Hot Grant Output
```

---

# Core Design Concepts

## 1. Parameterized Hardware Design

The arbiter supports configurable master count using parameters.

```verilog
parameter N = 4;
```

This allows the same RTL to scale for:

- 4 masters
- 8 masters
- 16 masters
- Large NoC systems

without rewriting logic.

---

## 2. Weighted Round Robin Arbitration

Each requester is assigned a programmable weight.

Example:

```text
CPU  → Weight 4
DMA  → Weight 2
UART → Weight 1
```

Higher weight requesters receive proportionally more bandwidth.

This provides:

- Fairness
- QoS support
- Starvation prevention
- Controlled bandwidth allocation

---

# Weighted Arbitration Theory

The arbiter maintains:

- Request pointer
- Credit counters
- Service quotas

Operation:

1. Select next eligible requester
2. Grant access
3. Decrement service credit
4. Rotate after quota completion
5. Reload credits when all exhausted

This enforces long-term bandwidth fairness.

---

# FSM-Based Arbitration

The arbiter is implemented using a Finite State Machine (FSM).

## States

| State | Function |
|---|---|
| IDLE | No active requests |
| ROTATE | Search next requester |
| GRANT | Active transaction |

---

# FSM Operation

```text
IDLE
  ↓
ROTATE
  ↓
GRANT
  ↓
ROTATE
```

The FSM stores:

- Current owner
- Arbitration pointer
- Service credits
- Handshake status

This creates deterministic hardware scheduling behavior.

---

# AXI-Style VALID/READY Handshake

The arbiter follows AXI-style transfer semantics.

Transfer occurs only when:

```text
VALID && READY
```

Where:

- VALID → Arbiter has granted requester
- READY → Slave can accept transfer

---

# Why Handshake Logic Matters

Without handshake protocols:

- Data corruption may occur
- Transfers may be lost
- Timing violations become possible

The arbiter therefore:

- Holds grant stable
- Waits for READY
- Prevents mid-transfer switching
- Ensures protocol-safe operation

---

# One-Hot Grant Logic

The arbiter generates one-hot encoded grants.

Example:

```text
0001
0010
0100
1000
```

At any time:

- Only one requester is granted
- No simultaneous ownership occurs

This prevents bus contention.

---

# Request Rotation Logic

The arbiter rotates fairly between active requesters.

Example rotation:

```text
Master0 → Master1 → Master2 → Master3
```

Inactive requesters are skipped automatically.

This ensures:

- No starvation
- Dynamic fairness
- Efficient arbitration

---

# Verification & Testbench

A complete Verilog testbench was developed to validate:

- All-request-active condition
- Request removal
- Single requester behavior
- READY backpressure
- Rotation correctness
- Grant stability
- Handshake timing

---

# Simulation Scenarios

## Test 1 — All Requests Active

```text
req = 1111
```

Verified:

- Proper round robin rotation
- One-hot grants
- Fair arbitration

---

## Test 2 — Request Drop

```text
req[0] = 0
```

Verified:

- Arbiter skips inactive requester
- No invalid grants generated

---

## Test 3 — Single Active Requester

```text
req = 0100
```

Verified:

- Grant remains stable
- No unnecessary rotation

---

## Test 4 — READY Backpressure

```text
ready = 0
```

Verified:

- Grant held correctly
- No transfer during stall
- Resume after READY asserted

---

# Waveform Verification Results

Simulation confirms:

- Correct FSM behavior
- Stable sequential grants
- No combinational glitches
- Proper clocked transitions
- Correct handshake operation
- Fair weighted arbitration

Observed grant sequence:

```text
0001 → 0010 → 0100 → 1000
```

---

# Real-World Applications

This arbitration architecture is used in:

- AXI Interconnect Fabrics
- Network-on-Chip (NoC) Routers
- DDR Memory Controllers
- DMA Scheduling Systems
- GPU Memory Arbitration
- Ethernet Packet Switches
- Multi-core SoC Fabrics

---

# Engineering Concepts Demonstrated

- RTL Design
- Parameterized Hardware Design
- FSM Architecture
- Arbitration Algorithms
- QoS Scheduling
- AXI Handshake Logic
- Sequential Logic Design
- One-Hot Encoding
- Hardware Verification
- Testbench Development
- Digital System Design

---

# Skills Demonstrated

- Verilog HDL
- SoC Architecture Concepts
- Bus Arbitration Design
- Hardware Scheduling Algorithms
- Protocol-Aware RTL Design
- Simulation & Verification
- Timing-Safe Sequential Logic
- Reusable IP Development
- Scalable Hardware Architecture

---

# Industry Relevance

This project reflects real hardware structures used in:

- ARM AXI Interconnects
- High-performance SoCs
- AI Accelerators
- FPGA Interconnect Systems
- Multi-core Processors
- Embedded Computing Platforms

The architecture closely resembles practical arbitration logic used in production digital systems.

---

# Key Takeaways

- Arbitration is fundamentally an FSM problem
- Weighted Round Robin balances fairness and QoS
- VALID/READY prevents unsafe transfers
- Parameterization enables reusable RTL IP
- One-hot grants prevent bus contention
- Sequential arbitration avoids timing glitches
- Real SoCs require scalable arbitration structures

---

# Author

**Sai Srivardhan Lingala**  
Electronics Engineering Student | FPGA & Digital Design Enthusiast
