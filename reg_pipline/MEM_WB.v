module MEM_WB (
    input         clk,
    input         reset,
    input         flush,

    input  [31:0] final_result_in,
    input         regwrite_in,
    input  [4:0]  RD_in,
    input         branch_in,
    input         zero_in,
    output reg [31:0] final_result_out,
    output reg        regwrite_out,
    output reg [4:0]  RD_out,
    output reg        zero_out
);
  always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
      final_result_out <= 32'd0;
      regwrite_out     <= 1'b0;
      RD_out           <= 5'd0;
      zero_out         <= 1'b0;
    end else begin
      final_result_out <= final_result_in;
      regwrite_out     <= regwrite_in;
      RD_out           <= RD_in;
      zero_out         <= zero_in;
    end
  end
endmodule