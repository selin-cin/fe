`timescale 1ns / 1ps

// Ascon-XOF128 for a fixed 139-bit input and 128-bit output.
// A single round instance is reused for all 12 rounds of each permutation.
module ascon_xof128_hardcoded (
    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic                    start_i,
    input  logic [138:0]            message_i,

    output logic                    ready_o,
    output logic                    busy_o,
    output logic                    done_o,
    output logic                    digest_valid_o,
    output logic [127:0]            digest_o
);

    localparam logic [3:0] LastRound     = 4'd11;
    localparam logic [1:0] AbsorbCntDone = 2'd2;
    localparam logic [1:0] SqueezeLast   = 2'd1;

    // Precomputed state after initialization: Ascon-p[12](IV || 0^256)
    localparam logic [63:0] XofInitS0 = 64'hda82ce768d9447eb;
    localparam logic [63:0] XofInitS1 = 64'hcc7ce6c75f1ef969;
    localparam logic [63:0] XofInitS2 = 64'he7508fd780085631;
    localparam logic [63:0] XofInitS3 = 64'h0ee0ea53416b58cc;
    localparam logic [63:0] XofInitS4 = 64'he0547524db6f0bde;

    typedef enum logic [1:0] {
        ST_INIT    = 2'b00,
        ST_ABSORB  = 2'b01,
        ST_SQUEEZE = 2'b10,
        ST_DONE    = 2'b11
    } fsm_state_e;

    fsm_state_e state_fsm_q, state_fsm_d;

    logic [319:0] state_q, state_d;
    logic [127:0] digest_q, digest_d;
    logic [138:0] message_q, message_d;

    logic [3:0]   round_cnt_q, round_cnt_d;
    logic [1:0]   absorb_cnt_q, absorb_cnt_d;
    logic [1:0]   squeeze_cnt_q, squeeze_cnt_d;

    logic         squeeze_perm_q, squeeze_perm_d;

    logic [63:0]  absorb_data;
    logic [7:0]   round_constant;
    logic [319:0] round_state_in;
    logic [319:0] round_state_out;

    function automatic logic [63:0] reverse_bytes64(input logic [63:0] value);
        reverse_bytes64 = {
            value[7:0], value[15:8], value[23:16], value[31:24],
            value[39:32], value[47:40], value[55:48], value[63:56]
        };
    endfunction

    always_comb begin
        round_constant = 8'h00;

        case (round_cnt_q)
            4'd0:  round_constant = 8'hf0;
            4'd1:  round_constant = 8'he1;
            4'd2:  round_constant = 8'hd2;
            4'd3:  round_constant = 8'hc3;
            4'd4:  round_constant = 8'hb4;
            4'd5:  round_constant = 8'ha5;
            4'd6:  round_constant = 8'h96;
            4'd7:  round_constant = 8'h87;
            4'd8:  round_constant = 8'h78;
            4'd9:  round_constant = 8'h69;
            4'd10: round_constant = 8'h5a;
            4'd11: round_constant = 8'h4b;
            default: round_constant = 8'h00;
        endcase
    end

    ascon_round u_ascon_round (
        .state_in       (round_state_in),
        .round_constant (round_constant),
        .state_out      (round_state_out)
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_fsm_q    <= ST_INIT;
            state_q        <= 320'd0;
            digest_q       <= '0;
            message_q      <= '0;
            round_cnt_q    <= '0;
            absorb_cnt_q   <= '0;
            squeeze_cnt_q  <= '0;
            squeeze_perm_q <= 1'b0;
        end else begin
            state_fsm_q    <= state_fsm_d;
            state_q        <= state_d;
            digest_q       <= digest_d;
            message_q      <= message_d;
            round_cnt_q    <= round_cnt_d;
            absorb_cnt_q   <= absorb_cnt_d;
            squeeze_cnt_q  <= squeeze_cnt_d;
            squeeze_perm_q <= squeeze_perm_d;
        end
    end

    always_comb begin
        state_fsm_d    = state_fsm_q;
        state_d        = state_q;
        digest_d       = digest_q;
        message_d      = message_q;
        round_cnt_d    = round_cnt_q;
        absorb_cnt_d   = absorb_cnt_q;
        squeeze_cnt_d  = squeeze_cnt_q;
        squeeze_perm_d = squeeze_perm_q;

        ready_o        = 1'b0;
        busy_o         = 1'b0;
        done_o         = 1'b0;
        digest_valid_o = 1'b0;
        digest_o       = digest_q;

        round_state_in = state_q;
        absorb_data    = '0;

        case (state_fsm_q)

            ST_INIT: begin
                ready_o = 1'b1;

                if (start_i) begin
                    state_fsm_d = ST_ABSORB;

                    state_d = {
                        XofInitS4,
                        XofInitS3,
                        XofInitS2,
                        XofInitS1,
                        XofInitS0
                    };

                    digest_d       = '0;
                    message_d      = message_i;
                    round_cnt_d    = '0;
                    absorb_cnt_d   = '0;
                    squeeze_cnt_d  = '0;
                    squeeze_perm_d = 1'b0;
                end
            end

            // The message is encoded as 18 bytes {5'b0, message} and absorbed
            // in three 8-byte blocks; the last block carries the padding byte.
            ST_ABSORB: begin
                busy_o = 1'b1;

                case (absorb_cnt_q)
                    2'd0: begin
                        absorb_data = {
                            message_q[87:80], message_q[95:88],
                            message_q[103:96], message_q[111:104],
                            message_q[119:112], message_q[127:120],
                            message_q[135:128], 5'd0, message_q[138:136]
                        };
                    end

                    2'd1: begin
                        absorb_data = {
                            message_q[23:16], message_q[31:24],
                            message_q[39:32], message_q[47:40],
                            message_q[55:48], message_q[63:56],
                            message_q[71:64], message_q[79:72]
                        };
                    end

                    2'd2: begin
                        absorb_data = {
                            47'd0, 1'b1, message_q[7:0], message_q[15:8]
                        };
                    end

                    default: begin
                        absorb_data = 64'd0;
                    end
                endcase

                if (round_cnt_q == 4'd0) begin
                    round_state_in = {
                        state_q[319:64],
                        state_q[63:0] ^ absorb_data
                    };
                end

                state_d = round_state_out;

                if (round_cnt_q == LastRound) begin
                    round_cnt_d = 4'd0;

                    if (absorb_cnt_q == AbsorbCntDone) begin
                        absorb_cnt_d   = '0;
                        squeeze_cnt_d  = '0;
                        squeeze_perm_d = 1'b0;
                        state_fsm_d    = ST_SQUEEZE;
                    end else begin
                        absorb_cnt_d = absorb_cnt_q + 1'b1;
                    end
                end else begin
                    round_cnt_d = round_cnt_q + 1'b1;
                end
            end

            // Two 64-bit output blocks with one permutation in between
            ST_SQUEEZE: begin
                busy_o = 1'b1;

                if (!squeeze_perm_q) begin
                    case (squeeze_cnt_q)
                        2'd0: begin
                            digest_d[127:64] = reverse_bytes64(state_q[63:0]);
                        end

                        2'd1: begin
                            digest_d[63:0] = reverse_bytes64(state_q[63:0]);
                        end

                        default: begin
                            digest_d = digest_q;
                        end
                    endcase

                    if (squeeze_cnt_q == SqueezeLast) begin
                        state_fsm_d   = ST_DONE;
                        squeeze_cnt_d = '0;
                        round_cnt_d   = '0;
                    end else begin
                        squeeze_perm_d = 1'b1;
                        round_cnt_d    = '0;
                    end

                end else begin
                    state_d = round_state_out;

                    if (round_cnt_q == LastRound) begin
                        round_cnt_d    = '0;
                        squeeze_perm_d = 1'b0;
                        squeeze_cnt_d  = squeeze_cnt_q + 1'b1;
                    end else begin
                        round_cnt_d = round_cnt_q + 1'b1;
                    end
                end
            end

            ST_DONE: begin
                done_o         = 1'b1;
                digest_valid_o = 1'b1;
                state_fsm_d    = ST_INIT;
            end

            default: begin
                state_fsm_d = ST_INIT;
            end

        endcase
    end

endmodule
