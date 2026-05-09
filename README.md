# 🚦 Smart 4 Way Traffic Light Controller using FSM (Verilog)

## 📌 Project Overview
This project implements a **Traffic Light Controller** using a Finite State Machine (FSM) in Verilog.  
The design manages traffic flow for **North-South (NS)** and **East-West (EW)** directions, while supporting:

- 🚶 Pedestrian crossing requests  
- 🚑 Emergency vehicle priority  
- 🔁 Fair arbitration using round-robin  

The system ensures **safe, efficient, and prioritized traffic control** under different real-world scenarios.

---

## ⚙️ Features

- ✅ Normal traffic light sequencing (Green → Yellow → Red)
- 🚶 Pedestrian crossing support
- 🚑 Emergency vehicle override (highest priority)
- 🔁 Round-robin arbitration when multiple emergencies occur
- ⏱️ Configurable timing for all states
- 🧪 Fully verified using testbench

---

## 🧠 FSM States

| State | Description |
|------|------------|
| `S_NS_GREEN`  | North-South traffic allowed |
| `S_NS_YELLOW` | NS transitioning to stop |
| `S_EW_GREEN`  | East-West traffic allowed |
| `S_EW_YELLOW` | EW transitioning to stop |
| `S_PED`       | Pedestrian crossing active |
| `S_EMERGENCY` | Emergency override mode |

---

## 🚑 Emergency Handling

- Emergency inputs:
  - `emergency_n`, `emergency_s` → NS direction
  - `emergency_e`, `emergency_w` → EW direction

### Behavior:
- Single emergency → that direction gets green
- Both directions → **round-robin arbitration**
- Fixed time slice (`T_EMERGENCY`) for fairness

---

## 🚶 Pedestrian Handling

- `ped_req` signal registers a request
- Served after current cycle completes
- All directions turn **RED**
- `ped_walk = 1` during crossing

---

## ⏱️ Timing Parameters


T_GREEN     = 8;
T_YELLOW    = 3;
T_PED       = 5;
T_EMERGENCY = 6;



---

## 📂 Project Structure
traffic-light-fsm/
│
├── traffic_light_controller.v       # RTL Design
├── traffic_light_controller_tb.v    # Testbench
├── README.md
├── simulation_log.txt               #TCL Console output
└── images/
    └── waveform.png                # Simulation waveform

---

🧪 Testbench Description

The testbench verifies multiple real-world scenarios using tasks:

✔ Test Cases Covered
1.Normal operation
2.Single emergency (NS)
3.Single emergency (EW)
4.Both emergencies (Round-robin case 1)
5.Both emergencies (Round-robin case 2)
6.Pedestrian request
7.Pedestrian + Emergency combination

---

## 📊 Simulation Output
🔹 Waveform
![Waveform](images/waveform.png)

---
## TCL Console Output
Full simulation logs are available in 'simulation_log.txt'

---

## 🔧 Design Highlights
Hybrid FSM (state-based + conditional logic)
Clean separation of:
  1.State register
  2.Next-state logic
  3.Output logic

Priority handling:

      Emergency > Pedestrian > Normal Traffic

---

## 🚀 How to Run
1.Open project in Xilinx Vivado
2.Add RTL and testbench files
3.Run:  Run Behavioral Simulation
4.Observe:
           -> Waveforms
           -> Console output

---
## Tools Used
  -> Verilog HDL
  -> Xilinx Vivado Simulator
---

## 📜 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author
**SHAIK ABDUL MATHEEN**

---

## Acknowledgement

This project was developed as a part of learing digital design and FSM implementation.














