`timescale 1ns / 1ps

module regfile_mux(RB, RDi, RegDst, RDo);
    input [2:0] RB, RDi;
    input RegDst;
    output reg [2:0] RDo;

    always @ (*) begin
        case (RegDst)
            1'b0:    RDo = RB;  // Changed <= #2 to =
            1'b1:    RDo = RDi; // Changed <= #2 to =
            default: RDo = 3'b000; // Explicit default prevents latches
        endcase
    end
endmodule