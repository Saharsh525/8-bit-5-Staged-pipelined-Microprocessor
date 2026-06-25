`timescale 1ns / 1ps

module HazardDetectionUnit(
    input [2:0] IF_ID_RegisterRs, // Source register A in Decode stage
    input [2:0] IF_ID_RegisterRt, // Source register B in Decode stage
    input [2:0] ID_EX_RegisterRd, // Destination register of current Execute instruction
    input ID_EX_MemRead,          // Is the instruction in Execute stage a Load?
    output reg PCWrite,           // Controls freeze on PC register
    output reg IF_ID_Write,       // Controls freeze on L1 (IF/ID) pipeline register
    output reg StallControlMUX    // Selects a 0 (bubble/NOP) for control signals
);

    always @(*) begin
        // Detect Load-Use Hazard
        if (ID_EX_MemRead && ((ID_EX_RegisterRd == IF_ID_RegisterRs) || (ID_EX_RegisterRd == IF_ID_RegisterRt))) begin
            // Freeze the pipeline
            PCWrite = 1'b0;          // Keep PC from advancing
            IF_ID_Write = 1'b0;      // Don't let new instruction overwrite L1
            StallControlMUX = 1'b1;  // Inject a NOP (bubble) into the execution stream
        end 
        else begin
            // Normal pipeline flow
            PCWrite = 1'b1;          // PC advances normally
            IF_ID_Write = 1'b1;      // L1 updates normally
            StallControlMUX = 1'b0;  // Pass normal control signals
        end
    end
endmodule
