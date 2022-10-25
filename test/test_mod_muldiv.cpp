#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vmod_muldiv.h"               // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <stdint.h>
#include <stdio.h>
#include <typeinfo>   //for debugging
#include "defines.h"

Vmod_muldiv* mod_muldiv;                      // Instantiation of model
VerilatedVcdC* m_trace; 

vluint64_t sim_time = 0;

void test_mod_muldiv(uint8_t opcode, uint8_t funct3, uint32_t rs0, uint32_t rs1){

    for(int i = 0; i < 34; i++){
        mod_muldiv->opcode_i = opcode;
        mod_muldiv->funct3_i = funct3;
        mod_muldiv->funct7_i = 1;
        mod_muldiv->muldiv_rs1_i = rs1;
        mod_muldiv->muldiv_rs0_i = rs0; 

        mod_muldiv->clk_i ^= 1;       // Toggle clock
        mod_muldiv->eval();            // Evaluate model
        m_trace->dump(sim_time);
        sim_time++;
        mod_muldiv->clk_i ^= 1;       // Toggle clock
        mod_muldiv->eval();            // Evaluate model
        m_trace->dump(sim_time);
        sim_time++;
    }
}

int main(int argc, char** argv) 
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true); 
    mod_muldiv = new Vmod_muldiv;             // Create model
    m_trace = new VerilatedVcdC;
    mod_muldiv->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    std::cout << "Beginning simulation...\n";
    mod_muldiv->rst_i = 0;
    mod_muldiv->clk_i = 0;
    mod_muldiv->eval();
    m_trace->dump(sim_time);
    sim_time++;

    //MUL
    //lower signed * signed
    //negative * negative
    test_mod_muldiv(OP_MULDIV,FUNCT3_MUL,0xFFFFFA30,0xFFF82AEB); //expect 2D868A10
    //positive * negative
    test_mod_muldiv(OP_MULDIV,FUNCT3_MUL,0x7FFFFA30,0xFFF82AEB); //expect AD868A10
    // //zero * zero
    test_mod_muldiv(OP_MULDIV,FUNCT3_MUL,0x0,0x0); //expect 0
    // //zero * signed
    test_mod_muldiv(OP_MULDIV,FUNCT3_MUL,0x0,0xFFF82AEB); //expect 0
    // //signed * zero
    test_mod_muldiv(OP_MULDIV,FUNCT3_MUL,0x7FFFFA30,0x0); //expect 0

    // //upper signed * signed
    // //positive * positive
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0x7FFFFA30,0x7F9821EB); //expect 3FCC0E0F
    // //positive * negative
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0x7FFFFA30,0xFFF82AEB); //expect FFFC1575
    // //negative * negative
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0xFFFFFA30,0xFFF82AEB); //expect 0
    // // //zero * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0x0,0x0); //expect 0
    // // //zero * signed
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0x0,0xFFF82AEB); //expect 0
    // // //signed * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULH,0x7FFFFA30,0x0); //expect 0

    // //upper unsigned * unsigned
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0xFFFFFA30,0xFFF82AEB); //expect FFF8251B
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0x7FFFFA30,0x7F9821EB); //expect 3FCC0E0F
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0x7FFFFA30,0xFFF82AEB); //expect 7FFC0FA5
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0xFFF82AEB,0x7FFFFA30); //expect 7FFC0FA5
    // //zero * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0x0,0x0); //expect 0
    // //zero * unsigned
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0x0,0xFFF82AEB); //expect 0
    // //unsigned * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHU,0x7FFFFA30,0x0); //expect 0

    // //upper signed * unsigned
    // //positive * positive
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x7F8F3A14,0xAEF8BA32); //expect 572F4900
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x7F6B61E4,0x7E28B132); //expect 3ECB1B27
    // //negative * positive
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0xE3BF5017,0xA1F34A81); //expect EE2077BE
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0xE3BF5017,0x71F34A81); //expect F36C98BA
    // //zero * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x0,0x0); //expect 0
    // //zero * unsigned
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x0,0xFFF82AEB); //expect 0
    // //unsigned * zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x7FFFFA30,0x0); //expect 0

    // //DIV
    // //unsigned / unsigned
    // //nonzero divide by zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x7FFFFA30,0x0); //expect FFFFFFFF
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x7FFFFA30,0x0); //expect 7FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x8FFFFA30,0x0); //expect FFFFFFFF
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x8FFFFA30,0x0); //expect 8FFFFA30
    // //zero divide by nonzero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x0,0x7FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x0,0x7FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x0,0x8FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x0,0x8FFFFA30); //expect 0
    // //|dividend| < |divisor|
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x7FFFFA30,0x8FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x7FFFFA30,0x8FFFFA30); //expect 7FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x1,0x73285FC1); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x1,0x73285FC1); //expect 1
    // //nonzero / nonzero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x7FFFFA30,0x1); //expect 7FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x7FFFFA30,0x1); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x8FFFFA30,0x1); //expect 8FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x8FFFFA30,0x1); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x8FFFFA30,0x157); //expect 6B79A3
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x8FFFFA30,0x157); //expect CB
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIVU,0x7FFFFA30,0x18789); //expect 53B0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REMU,0x7FFFFA30,0x18789); //expect 16100

    // // //signed / signed
    // // //nonzero divide by zero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x7FFFFA30,0x0); //expect FFFFFFFF
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x7FFFFA30,0x0); //expect 7FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x8FFFFA30,0x0); //expect FFFFFFFF
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x8FFFFA30,0x0); //expect 8FFFFA30
    // // //zero divide by nonzero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x0,0x7FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x0,0x7FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x0,0x8FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x0,0x8FFFFA30); //expect 0
    // //|dividend| < |divisor|
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x4FFFFA30,0x7FFFFA30); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x4FFFFA30,0x7FFFFA30); //expect 4FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0xFFFFFFFE,0xFFFFFFFD); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0xFFFFFFFE,0xFFFFFFFD); //expect FFFFFFFE
    // //nonzero / nonzero
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x8FFFFA30,0x1); //expect 8FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x8FFFFA30,0x1); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x7FFFFA30,0x1); //expect 7FFFFA30
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x7FFFFA30,0x1); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x7FFFFA30,0xFFFFFFFF); //expect 800005D0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x7FFFFA30,0xFFFFFFFF); //expect 0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x8FFFFA30,0xFFFFFFFF); //expect 700005D0
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x8FFFFA30,0xFFFFFFFF); //expect 0
    
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x8000B517,0xFFFF253F); //expect 95CA
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x8000B517,0xFFFF253F); //expect FFFFA661
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x8000B517,0xCF3); //expect FFF61D8E
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x8000B517,0xCF3); //expect FFFFFF4D
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x7E40B585,0xFFFF253F); //expect FFFF6C41
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x7E40B585,0xFFFF253F); //expect AC86
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x77823732,0x36725); //expect 231E
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x77823732,0x36725); //expect 211DC

    // //edge case: overflow
    // test_mod_muldiv(OP_MULDIV,FUNCT3_DIV,0x80000000,0xFFFFFFFF); //expect 80000000
    // test_mod_muldiv(OP_MULDIV,FUNCT3_REM,0x80000000,0xFFFFFFFF); //expect 0

    // //debug
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x7F8F3A14,0xAEF8BA32); //expect 572F4900
    // test_mod_muldiv(OP_MULDIV,FUNCT3_MULHSU,0x1F6C00,0x1CE400); 

    

    m_trace->close();
    mod_muldiv->final();               // Done simulating
    delete mod_muldiv;
    std::cout << "Ending simulation...\n";
}