`timescale 1ns / 1ps

// One round of the Ascon permutation (NIST SP 800-232)
module ascon_round(
    input logic  [319:0] state_in,
    input logic  [7:0]   round_constant,
    output logic [319:0] state_out
);

    logic [63:0] x0, x1, x2, x3, x4;
    logic [63:0] t0, t1, t2, t3, t4;

    always_comb begin
        {x4, x3, x2, x1, x0} = state_in;

        // constant addition
        x2[7:0] = x2[7:0] ^ round_constant;

        // substitution layer (bitsliced 5-bit S-box)
        x0 = x0 ^ x4;
        x4 = x4 ^ x3;
        x2 = x2 ^ x1;

        t0 = (~x0) & x1;
        t1 = (~x1) & x2;
        t2 = (~x2) & x3;
        t3 = (~x3) & x4;
        t4 = (~x4) & x0;

        x0 = x0 ^ t1;
        x1 = x1 ^ t2;
        x2 = x2 ^ t3;
        x3 = x3 ^ t4;
        x4 = x4 ^ t0;

        x1 = x1 ^ x0;
        x0 = x0 ^ x4;
        x3 = x3 ^ x2;
        x2 = ~x2;

        // linear diffusion layer
        x0 = x0 ^ {x0[18:0], x0[63:19]} ^ {x0[27:0], x0[63:28]};
        x1 = x1 ^ {x1[60:0], x1[63:61]} ^ {x1[38:0], x1[63:39]};
        x2 = x2 ^ {x2[0]   , x2[63:1] } ^ {x2[5:0] , x2[63:6] };
        x3 = x3 ^ {x3[9:0] , x3[63:10]} ^ {x3[16:0], x3[63:17]};
        x4 = x4 ^ {x4[6:0] , x4[63:7] } ^ {x4[40:0], x4[63:41]};

        state_out = {x4, x3, x2, x1, x0};
    end

endmodule
