#include <map>
#include <string>
#include <stdint.h>

// This is an "instruction bank" that holds a complete
// set of isntructions for hardware testing individual
// modules.

const std::map<std::string, uint32_t> r_instruction =
    {
        {"add x1, x2, x3", 0x003100b3},
        {"add x0, x0, x0", 0x00000033},
        {"add x31, x31, x31", 0x01ff8fb3},
        {"sub x1, x2, x3", 0x403100b3},
        {"sub x0, x0, x0", 0x40000033},
        {"sub x31, x31, x31", 0x41ff8fb3},
        {"sll x1, x2, x3", 0x003110b3},
        {"sll x0, x0, x0", 0x00001033},
        {"sll x31, x31, x31", 0x01ff9fb3},
        {"slt x1, x2, x3", 0x003120b3},
        {"slt x0, x0, x0", 0x00002033},
        {"slt x31, x31, x31", 0x01ffafb3},
        {"sltu x1, x2, x3", 0x003130b3},
        {"sltu x0, x0, x0", 0x00003033},
        {"sltu x31, x31, x31", 0x01ffbfb3},
        {"xor x1, x2, x3", 0x003140b3},
        {"xor x0, x0, x0", 0x00004033},
        {"xor x31, x31, x31", 0x01ffcfb3},
        {"srl x1, x2, x3", 0x003150b3},
        {"srl x0, x0, x0", 0x00005033},
        {"srl x31, x31, x31", 0x01ffdfb3},
        {"sra x1, x2, x3", 0x403150b3},
        {"sra x0, x0, x0", 0x40005033},
        {"sra x31, x31, x31", 0x41ffdfb3},
        {"or x1, x2, x3", 0x003160b3},
        {"or x0, x0, x0", 0x00006033},
        {"or x31, x31, x31", 0x01ffefb3},
        {"and x1, x2, x3", 0x003170b3},
        {"and x0, x0, x0", 0x00007033},
        {"and x31, x31, x31", 0x01ffffb3}};

const std::map<std::string, uint32_t> i_instruction =
    {
        {"addi x1, x2, 3", 0x00310093},
        {"addi x0, x0, 31", 0x01f00013},
        {"addi x31, x31, 31", 0x01ff8f93},
        {"slti x1, x2, 3", 0x00312093},
        {"slti x0, x0, 31", 0x01f02013},
        {"slti x31, x31, 31", 0x01ffaf93},
        {"sltiu x1, x2, 3", 0x00313093},
        {"sltiu x0, x0, 31", 0x01f03013},
        {"sltiu x31, x31, 31", 0x01ffbf93},
        {"xori x1, x2, 3", 0x00314093},
        {"xori x0, x0, 31", 0x01f04013},
        {"xori x31, x31, 31", 0x01ffcf93},
        {"ori x1, x2, 3", 0x00316093},
        {"ori x0, x0, 31", 0x01f06013},
        {"ori x31, x31, 31", 0x01ffef93},
        {"andi x1, x2, 3", 0x00317093},
        {"andi x0, x0, 31", 0x01f07013},
        {"andi x31, x31, 31", 0x01ffff93},
        {"slli x1, x2, 3", 0x00311093},
        {"slli x0, x0, 31", 0x01f01013},
        {"slli x31, x31, 31", 0x01ff9f93},
        {"srli x1, x2, 3", 0x00315093},
        {"srli x0, x0, 31", 0x01f05013},
        {"srli x31, x31, 31", 0x01ffdf93},
        {"srai x1, x2, 3", 0x40315093},
        {"srai x0, x0, 31", 0x41f05013},
        {"srai x31, x31, 31", 0x41ffdf93},
        {"jalr x1, x2, 3", 0x003100e7},
        {"jalr x0, x0, 31", 0x01f00067},
        {"jalr x31, x31, 31", 0x01ff8fe7}};

const std::map<std::string, uint32_t> s_instruction =
    {
        {"sb x1, 3(x2)", 0x001101a3},
        {"sb x0, 63(x0)", 0x02000fa3},
        {"sb x31, 63(x31)", 0x03ff8fa3},
        {"sh x1, 3(x2)", 0x001111a3},
        {"sh x0, 63(x0)", 0x02001fa3},
        {"sh x31, 63(x31)", 0x03ff9fa3},
        {"sw x1, 3(x2)", 0x001121a3},
        {"sw x0, 63(x0)", 0x02002fa3},
        {"sw x31, 63(x31)", 0x03ffafa3}};

const std::map<std::string, uint32_t> b_instruction =
    {
        {"beq x1, x2, 8", 0x00208463},
        {"beq x0, x0, 8", 0x00000463},
        {"beq x31, x31, 8", 0x01ff8463},
        {"bne x1, x2, 8", 0x00209463},
        {"bne x0, x0, 8", 0x00001463},
        {"bne x31, x31, 8", 0x01ff9463},
        {"blt x1, x2, 8", 0x00114463},
        {"blt x0, x0, 8", 0x00004463},
        {"blt x31, x31, 8", 0x01ffc463},
        {"bge x1, x2, 8", 0x00115463},
        {"bge x0, x0, 8", 0x00005463},
        {"bge x31, x31, 8", 0x01ffd463},
        {"bltu x1, x2, 8", 0x00116463},
        {"bltu x0, x0, 8", 0x00006463},
        {"bltu x31, x31, 8", 0x01ffe463},
        {"bgeu x1, x2, 8", 0x00117463},
        {"bgeu x0, x0, 8", 0x00007463},
        {"bgeu x31, x31, 8", 0x01fff463}};

const std::map<std::string, uint32_t> u_instruction =
    {
        {"lui x1, 2", 0x000020b7},
        {"lui x0, 1000", 0x003e8037},
        {"lui x31, 1000", 0x003e8fb7},
        {"auipc x1, 2", 0x00002097},
        {"auipc x0, 1000", 0x003e8017},
        {"auipc x31, 1000", 0x003e8f97}};

const std::map<std::string, uint32_t> j_instruction =
    {
        {"jal x1, 2", 0x000000ef},
        {"jal x0, 1000", 0x0000006f},
        {"jal x31, 1000", 0x00000fef}};
