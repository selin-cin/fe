`timescale 1ns / 1ps

// Chien search: evaluates Lambda(x) at all 255 positions, one per cycle,
// and marks the roots as error locations.
module bch_chien
    import gf_math_pkg::*;
#(
    parameter integer T = 15,
    parameter integer N = 255,
    parameter integer E = $clog2(N+1)
)(
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         start_i,
    input  logic [7:0]   lambda_i [T+1],
    output logic [N-1:0] error_mask_o,
    output logic [E-1:0] error_count_o,
    output logic         done_o
);

    logic [7:0] chien_regs [T+1];
    logic [7:0] chien_cnt;
    logic       running;

    logic [7:0] chien_poly_eval;

    always_comb begin : comb_eval
        chien_poly_eval = 8'h00;
        for (int i = 0; i <= T; i = i + 1) begin
            chien_poly_eval = chien_poly_eval ^ chien_regs[i];
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin : seq_chien
        if (!rst_ni) begin
            chien_cnt     <= 8'd0;
            running       <= 1'b0;
            done_o        <= 1'b0;
            error_count_o <=  'd0;
            error_mask_o  <=  'd0;
            for (int i = 0; i <= T; i++) begin
                chien_regs[i] <= 8'h00;
            end
        end else begin
            done_o <= 1'b0;

            if (start_i && !running) begin
                running       <= 1'b1;
                chien_cnt     <= 8'd0;
                error_count_o <=  'd0;
                error_mask_o  <=  'd0;

                for (int i = 0; i <= T; i++) begin
                    chien_regs[i] <= lambda_i[i];
                end
            end
            else if (running) begin

                if (chien_poly_eval == 8'h00) begin
                    error_mask_o[chien_cnt] <= 1'b1;
                    error_count_o <= error_count_o + 1'b1;
                end

                // move to the next position: term i is scaled by alpha^-i
                chien_regs[0] <= chien_regs[0];
                for (int i = 1; i <= T; i++) begin
                    chien_regs[i] <= gf_mul(chien_regs[i], gf_inv(exp_lut(8'(i))));
                end

                chien_cnt <= chien_cnt + 8'h01;

                if (chien_cnt == 8'(N - 1)) begin
                    running <= 1'b0;
                    done_o  <= 1'b1;
                end
            end
        end
    end

endmodule
