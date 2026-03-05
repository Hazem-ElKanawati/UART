# FPGA UART (TX + RX)

This project implements a basic UART transmitter and receiver in VHDL.

## Features
- FSM-based UART RX and TX modules
- Configurable baud rate divider
- Start/Stop bit handling (8N1 format)
- Designed for 50 MHz system clock
- Synthesizable on Intel/Altera Cyclone IV FPGA

## Architecture
- Separate RX and TX modules
- Single clock domain
- Counter-based baud rate generation
- Mid-bit sampling for reliable reception
