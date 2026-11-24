module SYNC_LATCH #(parameter DATA_WIDTH=32)
   (
      input enable_in,
      input [DATA_WIDTH-1:0] data_in,
      output [DATA_WIDTH-1:0] data_out
   );

genvar i;
generate
   for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_latch
      (* keep = "true" *) wire q_fb;

      // Truth table for: q_fb = (enable_in & data_in[i]) | (~enable_in & q_fb)
      // I2 = enable_in, I1 = data_in[i], I0 = q_fb
      LUT3 #(
         .INIT(8'hCA)
      ) latch_lut (
         .O(q_fb),
         .I0(q_fb),
         .I1(data_in[i]),
         .I2(enable_in)
      );

      assign data_out[i] = q_fb;
   end
endgenerate

endmodule

