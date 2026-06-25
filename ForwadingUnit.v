`timescale 1ns / 1ps

module ForwardingUnit(
    input [2:0] ID_EX_RegisterRs, // Source register A in Execute stage
    input [2:0] ID_EX_RegisterRt, // Source register B in Execute stage
    input [2:0] EX_MEM_RegisterRd, // Destination register in L3 latch
    input [2:0] MEM_WB_RegisterRd, // Destination register in L4 latch
    input EX_MEM_RegWrite,         // RegWrite signal from L3 latch
    input MEM_WB_RegWrite,         // RegWrite signal from L4 latch
    output reg [1:0] ForwardA,     // Control signal for Operand A MUX
    output reg [1:0] ForwardB      // Control signal for Operand B MUX
);

    always @(*) begin
        // --- Forwarding for Operand A ---
        // EX Hazard: Most recent instruction in L3 is writing to Rs
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 3'b000) && (EX_MEM_RegisterRd == ID_EX_RegisterRs)) begin
            ForwardA = 2'b10; // Forward from ALU output (EX/MEM)
        end
        // MEM Hazard: Older instruction in L4 is writing to Rs
        else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 3'b000) && (MEM_WB_RegisterRd == ID_EX_RegisterRs)) begin
            ForwardA = 2'b01; // Forward from Writeback bus (MEM/WB)
        end
        else begin
            ForwardA = 2'b00; // No forwarding; use original Register File value
        end

        // --- Forwarding for Operand B ---
        // EX Hazard: Most recent instruction in L3 is writing to Rt
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 3'b000) && (EX_MEM_RegisterRd == ID_EX_RegisterRt)) begin
            ForwardB = 2'b10; // Forward from ALU output (EX/MEM)
        end
        // MEM Hazard: Older instruction in L4 is writing to Rt
        else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 3'b000) && (MEM_WB_RegisterRd == ID_EX_RegisterRt)) begin
            ForwardB = 2'b01; // Forward from Writeback bus (MEM/WB)
        end
        else begin
            ForwardB = 2'b00; // No forwarding; use original Register File value
        end
    end
endmodule