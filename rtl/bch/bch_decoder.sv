`timescale 1ns / 1ps

// BCH(255,139,15) decoder: syndrome -> Berlekamp-Massey -> Chien search -> bit flip.
// If all syndromes are zero, BM and Chien are skipped.
module bch_decoder
    import gf_math_pkg::*;
#(
    parameter integer N = 255,
    parameter integer K = 139,
    parameter integer T = 15,
    parameter integer M = 8
)(
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         start_i,
    input  logic [N-1:0] word_i,
    output logic [N-1:0] corrected_o,
    output logic [K-1:0] k_o,
    output logic         fail_o,
    output logic         done_o
);

    localparam int E = $clog2(N+1);

    typedef enum logic [2:0] {
        ST_IDLE  = 3'd0,
        ST_SYND  = 3'd1,
        ST_BM    = 3'd2,
        ST_CHIEN = 3'd3,
        ST_DONE  = 3'd4
    } state_t;

    state_t state_r;

    logic [N-1:0] word_r;
    logic         error_mask;
    logic         fail_w;

    logic synd_start_r, bm_start_r, chien_start_r;

    logic [M-1:0] synd_out [0:2*T-1];
    logic         synd_no_err;
    logic         synd_done;

    logic [M-1:0] lambda_out  [0:T];
    logic         bm_done;
    logic [M-1:0] bm_l_degree;

    logic [N-1:0] err_vec;
    logic [E-1:0] err_cnt;
    logic         chien_done;

    logic [N-1:0] corrected_w;
    logic [K-1:0] k_out;

    bch_syndrome
    #(
        .T(T),
        .N(N),
        .M(M)
    ) u_syndrome (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .start_i       (synd_start_r),
        .received_i    (word_r),
        .syndrome_o    (synd_out),
        .no_error_o    (synd_no_err),
        .done_o        (synd_done)
    );

    bch_bm
    #(
        .T(T)
    ) u_bm (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .start_i       (bm_start_r),
        .synd_i        (synd_out),
        .lambda_o      (lambda_out),
        .l_degree_o    (bm_l_degree),
        .done_o        (bm_done)
    );

    bch_chien
    #(
        .T(T),
        .N(N),
        .E(E)
    ) u_chien (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .start_i       (chien_start_r),
        .lambda_i      (lambda_out),
        .error_mask_o  (err_vec),
        .error_count_o (err_cnt),
        .done_o        (chien_done)
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_r       <= ST_IDLE;
            word_r        <=  'd0;
            error_mask    <= 1'b0;
            synd_start_r  <= 1'b0;
            bm_start_r    <= 1'b0;
            chien_start_r <= 1'b0;
            corrected_o   <=  'd0;
            k_o           <=  'd0;
            fail_o        <= 1'b0;
            done_o        <= 1'b0;
        end
        else begin
        synd_start_r  <= 1'b0;
        bm_start_r    <= 1'b0;
        chien_start_r <= 1'b0;
        done_o        <= 1'b0;

        case (state_r)

        ST_IDLE: begin
            if (start_i) begin
                word_r       <= word_i;
                error_mask   <= 1'b0;
                synd_start_r <= 1'b1;
                fail_o       <= 1'b0;
                state_r      <= ST_SYND;
            end
        end

        ST_SYND: begin
            if (synd_done) begin
                if (synd_no_err) begin
                    error_mask <= 1'b0;
                    state_r    <= ST_DONE;
                end
                else begin
                    error_mask <= 1'b1;
                    bm_start_r <= 1'b1;
                    state_r    <= ST_BM;
                end
            end
        end

        ST_BM: begin
            if (bm_done) begin
                chien_start_r <= 1'b1;
                state_r       <= ST_CHIEN;
            end
        end

        ST_CHIEN: begin
            if (chien_done) begin
                state_r <= ST_DONE;
            end
        end

        ST_DONE: begin
            fail_o      <= fail_w;
            done_o      <= 1'b1;
            corrected_o <= corrected_w;
            k_o         <= k_out;
            state_r     <= ST_IDLE;
        end

        default: state_r <= ST_IDLE;

        endcase
        end
    end

    assign k_out       = corrected_w[N-1-:K];
    assign corrected_w = error_mask ? (word_r ^ err_vec) : word_r;

    // Uncorrectable if the locator is malformed or the number of roots
    // found does not match its degree
    assign fail_w      = error_mask              &&
                       ((lambda_out[0] != 8'h01) ||
                        (err_cnt > T)            ||
                        (err_cnt != bm_l_degree) );

endmodule
