module IF_ID_REG (
    input         reset,
    input         clk_in,
    input         stall,
    input         flush,

    input  [31:0] Instruction_in,
    input  [7:0]  PC_in,
    output reg [31:0] Instruction_out,
    output reg [7:0]  PC_out
);
  always @(posedge clk_in or posedge reset) begin
    if (reset || flush) begin
      Instruction_out <= 32'd0;
      PC_out          <= 8'd0;
    end else if (stall) begin
      Instruction_out <= Instruction_out;
      PC_out          <= PC_out;
    end else begin
      Instruction_out <= Instruction_in;
      PC_out          <= PC_in;
    end
  end
endmodule