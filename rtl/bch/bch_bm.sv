`timescale 1ns / 1ps

// Berlekamp-Massey solver for BCH(255,139,15) over GF(2^8).
// Each iteration takes two cycles (discrepancy, then update) so that no
// cycle chains two GF multiplies. Latency: 4*T cycles.
module bch_bm
    import gf_math_pkg::*;
#(
    parameter integer T = 15
)(
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       start_i,
    input  logic [7:0] synd_i   [2*T],
    output logic [7:0] lambda_o [T+1],
    output logic [7:0] l_degree_o,
    output logic       done_o
);

    localparam integer ITER = 2*T;

    logic [7:0] synd_r [0:2*T-1];
    logic [7:0] Lambda [T+1];
    logic [7:0] B      [T+1];
    logic [7:0] L_len;
    logic [7:0] L_len_next;
    logic [7:0] bm_cnt;
    logic       running;
    logic       phase_q;   // 0: discrepancy, 1: update

    logic [7:0] delta_q;

    logic [7:0] bm_delta_c;
    logic [7:0] bm_Lambda_new_c [T+1];
    logic       b_update_c;

    // Discrepancy for the current iteration
    always_comb begin
        bm_delta_c = synd_r[bm_cnt];
        for (int j = 1; j <= T; j = j + 1) begin
            if (bm_cnt >= 8'(j)) begin
                bm_delta_c = bm_delta_c ^ gf_mul(Lambda[j], synd_r[bm_cnt - 8'(j)]);
            end
        end
    end

    // Next Lambda(x) and length, using the registered discrepancy
    always_comb begin
        bm_Lambda_new_c[0] = Lambda[0];
        for (int j = 1; j <= T; j = j + 1) begin
            bm_Lambda_new_c[j] = Lambda[j] ^ gf_mul(delta_q, B[j-1]);
        end

        b_update_c = ((L_len << 1) <= bm_cnt) && (delta_q != 8'h00);
        L_len_next = b_update_c ? (bm_cnt + 8'h01 - L_len) : L_len;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            running    <= 1'b0;
            phase_q    <= 1'b0;
            done_o     <= 1'b0;
            l_degree_o <= 8'd0;
            bm_cnt     <= 8'd0;
            L_len      <= 8'd0;
            delta_q    <= 8'h00;
            for (int i = 0; i <= T; i++) begin
                Lambda[i]   <= 8'h00;
                B[i]        <= 8'h00;
                lambda_o[i] <= 8'h00;
            end
        end
        else begin
            done_o <= 1'b0;

            if (start_i && !running) begin
                running   <= 1'b1;
                phase_q   <= 1'b0;
                bm_cnt    <= 8'd0;
                L_len     <= 8'd0;
                delta_q   <= 8'h00;

                Lambda[0] <= 8'h01;
                B[0]      <= 8'h01;

                for (int i = 1; i <= T; i++) begin
                    Lambda[i] <= 8'h00;
                    B[i]      <= 8'h00;
                end

                for (int i = 0; i < 2*T; i++) begin
                    synd_r[i] <= synd_i[i];
                end
            end
            else if (running) begin

                if (!phase_q) begin
                    delta_q <= bm_delta_c;
                    phase_q <= 1'b1;
                end
                else begin
                    for (int i = 0; i <= T; i++) begin
                        Lambda[i] <= bm_Lambda_new_c[i];
                    end

                    // B(x) = Lambda(x) / delta on a length change, otherwise x * B(x)
                    if (b_update_c) begin
                        for (int i = 0; i <= T; i++) begin
                            B[i] <= gf_mul(gf_inv(delta_q), Lambda[i]);
                        end
                    end
                    else begin
                        for (int i = T; i > 0; i = i - 1) begin
                            B[i] <= B[i-1];
                        end
                        B[0] <= 8'h00;
                    end

                    L_len   <= L_len_next;

                    bm_cnt  <= bm_cnt + 8'h01;
                    phase_q <= 1'b0;

                    if (bm_cnt == 8'(ITER - 1)) begin
                        running    <= 1'b0;
                        done_o     <= 1'b1;
                        l_degree_o <= L_len_next;

                        for (int i = 0; i <= T; i++) begin
                            lambda_o[i] <= bm_Lambda_new_c[i];
                        end
                    end
                end
            end
        end
    end

endmodule
