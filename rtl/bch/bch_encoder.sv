`timescale 1ns / 1ps

// Systematic BCH(255,139,15) encoder. Computes the 116-bit parity with an
// LFSR, one message bit per cycle.
module bch_encoder(
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         start_i,
    input  logic [138:0] received_i,
    output logic [115:0] parity_o,
    output logic         ready_o,
    output logic         done_o
);

    // generator polynomial without its leading term
    localparam logic [115:0] G_LOWER = 116'h3180F68607DB8DE3A5D853CAEEF25;

    typedef enum logic [1:0] {
        ST_IDLE = 2'd0,
        ST_PROC = 2'd1,
        ST_DONE = 2'd2
    } state_t;

    state_t state_q, state_d;

    logic [138:0] received_q, received_d;
    logic [115:0] lfsr_q, lfsr_d;
    logic [7  :0] cnt_q, cnt_d;
    logic         feedback_flag;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q    <= ST_IDLE;
            received_q <= 139'd0;
            lfsr_q     <= 116'd0;
            cnt_q      <= 8'd0;
        end
        else begin
            state_q    <= state_d;
            received_q <= received_d;
            lfsr_q     <= lfsr_d;
            cnt_q      <= cnt_d;
        end
    end

    always_comb begin
        state_d    = state_q;
        received_d = received_q;
        lfsr_d     = lfsr_q;
        cnt_d      = cnt_q;

        case (state_q)
            ST_IDLE: begin
                if (start_i) begin
                    state_d    = ST_PROC;
                    received_d = received_i;
                    lfsr_d     = 116'd0;
                end
            end

            ST_PROC: begin
                lfsr_d      = {lfsr_q[114:0],     1'b0} ^ (feedback_flag ? G_LOWER : 116'h0);
                received_d  = {received_q[137:0], 1'b0};
                cnt_d       = cnt_q + 1;
                if (cnt_q == 8'd138) begin
                    state_d = ST_DONE;
                end
            end

            ST_DONE: begin
                cnt_d    = 8'd0;
                state_d  = ST_IDLE;
            end

            default: begin
                state_d = ST_IDLE;
            end
        endcase
    end

    assign feedback_flag = received_q[138] ^ lfsr_q[115];

    assign parity_o = (state_q == ST_DONE) ? lfsr_q : 116'd0;
    assign done_o   = (state_q == ST_DONE);
    assign ready_o  = (state_q == ST_IDLE);

endmodule
