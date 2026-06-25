module decoder(inst, ra_i, rb_i, rd_i, immi, immj, opfn);
    input [15:0] inst;
    output [2:0] ra_i, rb_i, rd_i;
    output [6:0] immi;
    output [7:0] immj;
    output reg [4:0] opfn;

    // Taking the instruction as the input and pulling components out
    assign ra_i = inst[5:3];
    assign rb_i = inst[2:0];
    assign rd_i = inst[8:6];
    assign immi = inst[12:6];
    assign immj = inst[7:0];

    // Assigning opfn signal based on the OpCode of instruction and ALUFn
    always @(*) begin
        opfn[4:2] = inst[15:13];
        if (inst[15:13] == 3'b000) begin
            opfn[1:0] = inst[12:11]; // Added missing semicolon here
        end else begin
            opfn[1:0] = 2'b00;       // Changed 2'bxx to 2'b00 for cleaner synthesis
        end
    end
endmodule