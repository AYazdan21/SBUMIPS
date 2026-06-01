module EX_MEM_REG (
    input         clk,
    input         reset,
    input         flush,
    input  [31:0] ALU_result_in,
    input         zero_in,
    input  [7:0]  branch_target_in,
    input         branch_in,
    input         memread_in,
    input         MemtoReg_in,
    input         memwwrite_in,
    input         regwrite_in,
    input  [4:0]  RD_in,
    input  [4:0]  RS_in,
    input  [4:0]  RT_in,
    input  [31:0] valueRt_in,
    output reg [31:0] ALU_result_out,
    output reg        zero_out,
    output reg [7:0]  branch_target_out,
    output reg        branch_out,
    output reg        memread_out,
    output reg        MemtoReg_out,
    output reg        memwwrite_out,
    output reg        regwrite_out,
    output reg [4:0]  RD_out,
    output reg [4:0]  RS_out,
    output reg [4:0]  RT_out,
    output reg [31:0] valueRt_out
);
  always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
      ALU_result_out    <= 32'd0;
      zero_out          <= 1'b0;
      branch_target_out <= 8'd0;
      branch_out        <= 1'b0;
      memread_out       <= 1'b0;
      MemtoReg_out      <= 1'b0;
      memwwrite_out     <= 1'b0;
      regwrite_out      <= 1'b0;
      RD_out            <= 5'd0;
      RS_out            <= 5'd0;
      RT_out            <= 5'd0;
      valueRt_out       <= 32'd0;
    end else begin
      ALU_result_out    <= ALU_result_in;
      zero_out          <= zero_in;
      branch_target_out <= branch_target_in;
      branch_out        <= branch_in;
      memread_out       <= memread_in;
      MemtoReg_out      <= MemtoReg_in;
      memwwrite_out     <= memwwrite_in;
      regwrite_out      <= regwrite_in;
      RD_out            <= RD_in;
      RS_out            <= RS_in;
      RT_out            <= RT_in;
      valueRt_out       <= valueRt_in;
    end
  end
endmodule