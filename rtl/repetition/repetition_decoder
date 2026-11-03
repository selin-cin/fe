`timescale 1ns / 1ps

// Repetition (15,1) decoder used during reconstruction. Compares the helper
// re-derived from the noisy chunk with the stored helper and corrects the
// key bit by majority vote (up to 7 bit errors per chunk).
module repetition_decoder (
    input  logic        enable_i,
    input  logic        r_rep_i,
    input  logic [13:0] h_rep_enc_i,
    input  logic [13:0] h_rep_nvm_i,
    output logic        r_rep_o
);

    logic [13:0] h_diff;
    logic [4:0]  diff_ones;
    logic        msb_flip;

    repetition_core u_dec_core (
        .in1_i (h_rep_enc_i),
        .in2_i (h_rep_nvm_i),
        .out_o (h_diff)
    );

    always_comb begin
        diff_ones = 5'd0;
        for (int i = 0; i < 14; i++) begin
            diff_ones = diff_ones + {4'b0, h_diff[i]};
        end
    end

    assign msb_flip = (diff_ones >= 5'd8);
    assign r_rep_o  = enable_i ? (r_rep_i ^ msb_flip) : 1'b0;

endmodule
