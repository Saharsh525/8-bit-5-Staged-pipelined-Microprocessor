`timescale 1ns / 1ps

module Advanced_ALU_MUX(
    input [7:0] RegFileOutput,    // Data from Register File
    input [7:0] WriteBackData,    // Forwarded data from Writeback stage
    input [7:0] ExMemAluResult,   // Forwarded data from Memory stage
    input [1:0] ForwardSelect,    // 2-bit control signal from ForwardingUnit
    output reg [7:0] MuxOutput
);

    always @(*) begin
        case(ForwardSelect)
            2'b00: MuxOutput = RegFileOutput;
            2'b01: MuxOutput = WriteBackData;
            2'b10: MuxOutput = ExMemAluResult;
            default: MuxOutput = RegFileOutput;
        endcase
    end
endmodule