# RISC-V CPU

This repository contains an implementation of a RISC-V processor, designed by James, Justin, Jacky and Vlad during
the Summer 2022 IAC Reshaping UROP.  
This processor will hopefully become the model answer for students doing the IAC module in upcoming years.  

The processor implements the RV32IM ISA, with subsets from other extensions to accomodate for interrupt handling.

## Directory structure
- ```rtl``` - contains the HDL code of the CPU
- ```test``` - contains Verilator C++ testbenches

## Style Guide
All HDL code in this project follows the [lowRISC Verilog style guide](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md).
