`timescale 1ns / 1ns
`include "instructionregister.v"
`include "decoder.v"
`include "regfile_mux.v"
`include "regfile_updated.v"
`include "SignExtender.v"
`include "B_Selector_MUX.v"
`include "alu.v"
`include "register256x8.v"
`include "mux2x1.v"
`include "adder.v"
`include "regpc.v"
`include "L1.v"
`include "L2.v"
`include "L3.v"
`include "L4.v"
`include "controlpath.v"
`include "ForwardingUnit.v"
`include "HazardDetectionUnit.v"
`include "Advanced_ALU_MUX.v"
//Including all the files for the individual components and the control unit

module Datapath(clk,rst);
    input clk, rst;
    wire NIA,RegDst,RegWrite,ALUSrc,MemWrite,MemRead,MemToReg;
    wire [2:0] ALUFn;    
    //Taking the input of the clk and a rst signal and defining all wires required in the intermediate connection 
    // of all the modules .

    wire [7:0] tDecode,tIR,Immj,A,B,MemReg,SignExtendedImm,FinalB;
    wire [15:0] tInst;
    wire [6:0] Immi;
    wire [2:0] Ra,Rb,Rd, RDo;
    wire  alubeq;
    wire [7:0] ToMux;
    wire [7:0] alu_out;
    wire compbeq;
    wire [2:0] inst_br;
    wire [7:0] br_in;
    wire [7:0] pinc,pinci,pincj,pin;
    wire [2:0] Raout,Rbout,Rdout;
    wire [7:0] immout, m1out, m2out;
    wire regdstout, regwriteout, alusrcout, memwriteout, memreadout, memtoregout; 
    wire [2:0] alufnout;
    wire L2_alusrcout,L2_memwriteout,L2_memreadout,L2_memtoregout, L2_regwrite;
    wire [2:0] L2_alufnout;
    wire [2:0] L2_regwradd;
    wire [7:0] l2immout, l2Aout, l2Bout, l2m1out, l2m2out ,l3m2out;
    wire [7:0] L3Bout, L3alu_outout;
    wire L3memwriteout, L3memreadout, L3memtoregout ,L3regwriteout;
    wire [2:0] L3_regwradd;
    wire [7:0] L4alu_in, L4mem_in;
    wire L4MemToRegmux , L4regwrite;
    wire [2:0] L4_regwradd;
    wire [4:0] OpFn;

    // --- NEW PIPELINE HAZARD CONTROL WIRES ---
    wire PCWrite;               // Freezes the program counter during a load stall
    wire IF_ID_Write;           // Freezes the L1 latch during a load stall
    wire StallControlMUX;       // Disables control path outputs during a load stall
    wire [1:0] ForwardA;        // Controls Operand A forwarding selection
    wire [1:0] ForwardB;        // Controls Operand B forwarding selection
    wire [7:0] forwarded_A;     // Output of Hazard MUX for Operand A
    wire [7:0] forwarded_B;     // Output of Hazard MUX for Operand B
    
    // Muxed control lines to handle load stall insertions (injecting bubbles/NOPs)
    wire final_RegWrite = StallControlMUX ? 1'b0 : RegWrite;
    wire final_MemWrite = StallControlMUX ? 1'b0 : MemWrite;
    wire final_MemRead  = StallControlMUX ? 1'b0 : MemRead;

    controlpath cp(
        .OpFn(OpFn), 
        .clk(clk),
        .NIA(NIA), 
        .RegDst(RegDst), 
        .RegWrite(RegWrite), 
        .ALUSrc(ALUSrc), 
        .ALUFn(ALUFn), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .MemToReg(MemToReg)
    );


   //Stage 1 

    //Program counter register, MUX and 2 adders determining the ongoing and upcoming instruction
    adder a1(.in1(tIR),.in2(8'b00000001),.out(pinc));
    adder a2(.in1(SignExtendedImm),.in2(pinc),.out(pinci));
    mux2x1 mp2(.mem_in(Immj),.alu_in(pincj),.memtoreg_sel(NIA),.mux_out(pin));
    
    // Upgraded: PC register now respects the PCWrite stall flag from Hazard Detection Unit
    pc pc1(.in(pin), .clk(clk), .rst(rst), .out(tIR)); 
    
    instreg IR(.add(tIR),.inst(tInst));    //Instruction Register
    decoder DE(.inst(tInst),.ra_i(Ra),.rb_i(Rb),.rd_i(Rd),.immi(Immi),.immj(Immj),.opfn(OpFn));   //Instruction decoder
    SignExtender SE(.Imm7(Immi),.Imm8(SignExtendedImm));   //Sign Extender which extends the 7 bit Imm part into 8 bit
 
      // Latch L1 storing all the values of stage 1 (Note: If your L1 module supports an enable pin, map IF_ID_Write to it)
    L1 l1(.clk1(clk), .Ra(Ra), .Rb(Rb), .Rd(Rd), .SignExtendedImm(SignExtendedImm), .m1(pinc), .m2(pinci), .RegDst(RegDst),.RegWrite(final_RegWrite),.ALUSrc(ALUSrc),.ALUFn(ALUFn),.MemWrite(final_MemWrite),.MemRead(final_MemRead),.MemtoReg(MemToReg), .Raout(Raout), .Rbout(Rbout), .Rdout(Rdout), .immout(immout), .m1out(m1out), .m2out(m2out), .regdstout(regdstout), .regwriteout(regwriteout), .alusrcout(alusrcout), .alufnout(alufnout), .memwriteout(memwriteout), .memreadout(memreadout), .memtoregout(memtoregout));

    //Stage 2

    regfile_mux Rmux(.RB(Rbout), .RDi(Rdout), .RegDst(regdstout), .RDo(RDo));   //MUX for determining right output into the second read port of regfile  
    RegFile RF(.RA(Raout),.RB(Rbout),.RDo(L4_regwradd),.RegWrite(L4regwrite),.A(A),.B(B),.clk(clk),.Mem_to_Reg(MemReg));     //RegFile with 8 registers of 8 bit
      //Latch L2 for storing all the values of stage 2
    L2 l2(.clk2(clk), .L1_m1(m1out), .L1_regwradd(RDo), .L1_m2(m2out), .L1_SignExtendedImm(immout), .L1_A(A), .L1_B(B), .L1_ALUSrc(alusrcout),.L1_ALUFn(alufnout),.L1_MemWrite(memwriteout),.L1_MemRead(memreadout),.L1_MemtoReg(memtoregout), .L1_RegWrite(regwriteout), .ALUSrcout(L2_alusrcout), .ALUFnout(L2_alufnout), .memwriteout(L2_memwriteout), .memreadout(L2_memreadout), .memtoregout(L2_memtoregout), .regwriteout(L2_regwrite),.immout(l2immout),.Aout(l2Aout),.Bout(l2Bout),.regwradd(L2_regwradd),.m1out(l2m1out),.m2out(l2m2out));
  
  //stage 3

    // --- NEW ADVANCED OPERAND SELECTION VIA FORWARDING MUXES ---
    // Safely intercepts register values to resolve data hazards mid-flight
    Advanced_ALU_MUX amuxA(
        .RegFileOutput(l2Aout), 
        .WriteBackData(MemReg), 
        .ExMemAluResult(L3alu_outout),
        .ForwardSelect(ForwardA), 
        .MuxOutput(forwarded_A)
    );

    Advanced_ALU_MUX amuxB(
        .RegFileOutput(l2Bout), 
        .WriteBackData(MemReg), 
        .ExMemAluResult(L3alu_outout), 
        .ForwardSelect(ForwardB), 
        .MuxOutput(forwarded_B)
    );

    // Upgraded: Selection MUX now chooses between the resolved hazard-free register data and the immediate value
    mux2x1 MI(.mem_in(forwarded_B),.alu_in(l2immout),.memtoreg_sel(L2_alusrcout),.mux_out(FinalB));  //MUX for determing right input in ALU based on instruction
    
    // Upgraded: ALU input A now receives the hazard-free forwarded_A stream
    alu AL(.Ra(forwarded_A),.Rb(FinalB),.alufn(L2_alufnout),.alubeq(alubeq),.alu_out(alu_out));  //ALU 
    
    mux2x1 mp1(.mem_in(pinc),.alu_in(l2m2out),.memtoreg_sel(alubeq),.mux_out(pincj));   //Multiplexer for determining pc value post branching 
      //Latch L3 for storing all the values of stage 3
    L3 l3(.clk1(clk), .L2_regwradd(L2_regwradd), .l2m2out(l2m2out), .L2_B(forwarded_B), .L2_alu_out(alu_out), .L2_MemWrite(L2_memwriteout), .L2_MemRead(L2_memreadout), .L2_MemtoReg(L2_memtoregout), .L2_RegWrite(L2_regwrite) ,  .Bout(L3Bout), .alu_outout(L3alu_outout), .memwriteout(L3memwriteout), .memreadout(L3memreadout), .memtoregout(L3memtoregout) , .regwriteout(L3regwriteout) , .regwradd(L3_regwradd) , .l3m2out(l3m2out));
 
  //stage 4

    register256x8 MEM(.clk(clk),.mem_read(L3memreadout),.mem_write(L3memwriteout),.aluout_in(L3Bout),.address_in(L3alu_outout),.memtoreg_out(ToMux));   //Memory of 256 Bytes 
      //Latch L4 for storing all the values of stage 4
    L4 l4(.alu_in(L4alu_in), .L3_regwradd(L3_regwradd) , .mem_in(L4mem_in), .MemToRegmux(L4MemToRegmux), .L3_Regwrite(L3regwriteout) ,.alu_out(L3alu_outout), .mem_out(ToMux), .MemToReg(L3memtoregout), .RegWrite(L4regwrite) , .regwradd(L4_regwradd), .clk2(clk));


  //stage 5
    mux2x1 MU(.mem_in(L4mem_in),.alu_in(L4alu_in),.memtoreg_sel(L4MemToRegmux),.mux_out(MemReg));  //Mux to determine if right value is being choosen for register write

    // --- INSTANTIATE ADVANCED HAZARD CONTROL ENGINES ---
    ForwardingUnit FU(
        .ID_EX_RegisterRs(Raout), 
        .ID_EX_RegisterRt(Rbout), 
        .EX_MEM_RegisterRd(L3_regwradd), 
        .MEM_WB_RegisterRd(L4_regwradd), 
        .EX_MEM_RegWrite(L3regwriteout), 
        .MEM_WB_RegWrite(L4regwrite), 
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB)
    );

    HazardDetectionUnit HDU(
        .IF_ID_RegisterRs(Ra), 
        .IF_ID_RegisterRt(Rb), 
        .ID_EX_RegisterRd(L2_regwradd), 
        .ID_EX_MemRead(L2_memreadout), 
        .PCWrite(PCWrite), 
        .IF_ID_Write(IF_ID_Write), 
        .StallControlMUX(StallControlMUX)
    );

endmodule