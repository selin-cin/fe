`timescale 1ns / 1ps

// Repetition (15,1) encoder for one 15-bit PUF chunk. The MSB is the key bit,
// and the helper is the remaining 14 bits XORed with it.
module repetition_encoder (
    input  logic        enable_i,
    input  logic [14:0] message_i,
    output logic [13:0] h_rep_o,
    output logic        r_rep_o,
    output logic        done_o
);

    logic [13:0] h_enc;

    repetition_core u_enc_core (
        .in1_i ({14{message_i[14]}}),
        .in2_i (message_i[13:0]),
        .out_o (h_enc)
    );

    assign r_rep_o = enable_i ? message_i[14] : 1'b0;
    assign h_rep_o = enable_i ? h_enc         : 14'd0;
    assign done_o  = enable_i;

endmodule
