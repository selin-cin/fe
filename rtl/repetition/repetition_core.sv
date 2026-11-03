`timescale 1ns / 1ps

module repetition_core (
  input  logic [13:0] in1_i,
  input  logic [13:0] in2_i,
  output logic [13:0] out_o
);

  always_comb begin
    out_o = in1_i ^ in2_i;
  end

endmodule
