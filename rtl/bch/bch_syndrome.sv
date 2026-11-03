`timescale 1ns / 1ps

// Computes the 30 syndromes S1..S30 of a 255-bit word with Horner's method,
// one bit per cycle. no_error_o is set when all syndromes are zero.
module bch_syndrome
    import gf_math_pkg::*;
#(
    parameter integer T = 15,
    parameter integer N = 255,
    parameter integer M = 8
)(
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         start_i,
    input  logic [N-1:0] received_i,
    output logic [M-1:0] syndrome_o [0:2*T-1],
    output logic         no_error_o,
    output logic         done_o
);

    localparam int SYND_CNT = 2 * T;

    typedef enum logic [1:0] {
        ST_IDLE = 2'd0,
        ST_PROC = 2'd1,
        ST_DONE = 2'd2
    } state_t;

    state_t state;

    logic [7:0]   s_regs  [SYND_CNT];
    logic [7:0]   bit_cnt;
    logic [N-1:0] received_r;

    logic no_error_comb;
    always_comb begin
        no_error_comb = 1'b1;
        for (int k = 0; k < SYND_CNT; k = k + 1) begin
            if (s_regs[k] != 8'h00) begin
                no_error_comb = 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state      <= ST_IDLE;
            bit_cnt    <= 8'd0;
            done_o     <= 1'b0;
            no_error_o <= 1'b0;
            received_r <=  'd0;

            for (int k = 0; k < SYND_CNT; k = k + 1) begin
                syndrome_o[k] <= '0;
                s_regs[k]     <= 8'h00;
            end
        end
        else begin
            done_o <= 1'b0;

            case(state)
                ST_IDLE: begin
                    if (start_i) begin
                        for (int k = 0; k < SYND_CNT; k = k + 1) begin
                            s_regs[k] <= 8'h00;
                        end

                        received_r <= received_i;
                        bit_cnt    <= 8'd254;
                        state      <= ST_PROC;
                    end
                end

                // s_k = s_k * alpha^(k+1) + r[bit], starting from the highest bit
                ST_PROC: begin
                    for (int k = 0; k < SYND_CNT; k = k + 1) begin
                        s_regs[k] <= gf_mul( s_regs[k],
                           exp_lut(byte'(k + 1))) ^ {7'b000_0000, received_r[bit_cnt]};
                    end

                    if (bit_cnt == 8'd0) begin
                        state <= ST_DONE;
                    end
                    else begin
                        bit_cnt <= bit_cnt - 8'd1;
                    end
                end

                ST_DONE: begin
                    for (int k = 0; k < SYND_CNT; k = k + 1) begin
                        syndrome_o[k] <= s_regs[k];
                    end

                    no_error_o <= no_error_comb;
                    done_o     <= 1'b1;
                    state      <= ST_IDLE;
                end

                default: begin
                    state <= ST_IDLE;
                end

            endcase
        end
    end

endmodule
