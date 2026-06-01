module ID_EX_REG (
    input         clk,
    input         reset,
    input         stall,
    input         flush,

    input  [31:0] valueRs_in,
    input  [31:0] valueRt_in,
    input  [4:0]  RD_in,
    input  [4:0]  RS_in,
    input  [4:0]  RT_in,
    input  [31:0] Immediate_in,
    input         branch_in,
    input         memread_in,
    input         MemtoReg_in,
    input  [2:0]  aluop_in,
    input         memwwrite_in,
    input         alusrc_in,
    input         regwrite_in,
    input  [7:0]  PC_in,
    input  [5:0]  func_in,
    input  [4:0]  shiftAmount_in,
    output reg [31:0] valueRs_out,
    output reg [31:0] valueRt_out,
    output reg [4:0]  RD_out,
    output reg [4:0]  RS_out,
    output reg [4:0]  RT_out,
    output reg [31:0] Immediate_out,
    output reg        branch_out,
    output reg        memread_out,
    output reg        MemtoReg_out,
    output reg [2:0]  aluop_out,
    output reg        memwwrite_out,
    output reg        alusrc_out,
    output reg        regwrite_out,
    output reg [7:0]  PC_out,
    output reg [5:0]  func_out,
    output reg [4:0]  shiftAmount_out
);
  always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
      valueRs_out     <= 32'd0;
      valueRt_out     <= 32'd0;
      RD_out          <= 5'd0;
      RS_out          <= 5'd0;
      RT_out          <= 5'd0;
      Immediate_out   <= 32'd0;
      branch_out      <= 1'b0;
      memread_out     <= 1'b0;
      MemtoReg_out    <= 1'b0;
      aluop_out       <= 3'd0;
      memwwrite_out   <= 1'b0;
      alusrc_out      <= 1'b0;
      regwrite_out    <= 1'b0;
      PC_out          <= 8'd0;
      func_out        <= 6'd0;
      shiftAmount_out <= 5'd0;
    end else if (stall) begin
      valueRs_out     <= valueRs_out;
      valueRt_out     <= valueRt_out;
      RD_out          <= RD_out;
      RS_out          <= RS_out;
      RT_out          <= RT_out;
      Immediate_out   <= Immediate_out;
      branch_out      <= branch_out;
      memread_out     <= memread_out;
      MemtoReg_out    <= MemtoReg_out;
      aluop_out       <= aluop_out;
      memwwrite_out   <= memwwrite_out;
      alusrc_out      <= alusrc_out;
      regwrite_out    <= regwrite_out;
      PC_out          <= PC_out;
      func_out        <= func_out;
      shiftAmount_out <= shiftAmount_out;
    end else begin
      valueRs_out     <= valueRs_in;
      valueRt_out     <= valueRt_in;
      RD_out          <= RD_in;
      RS_out          <= RS_in;
      RT_out          <= RT_in;
      Immediate_out   <= Immediate_in;
      branch_out      <= branch_in;
      memread_out     <= memread_in;
      MemtoReg_out    <= MemtoReg_in;
      aluop_out       <= aluop_in;
      memwwrite_out   <= memwwrite_in;
      alusrc_out      <= alusrc_in;
      regwrite_out    <= regwrite_in;
      PC_out          <= PC_in;
      func_out        <= func_in;
      shiftAmount_out <= shiftAmount_in;
    end
  end
endmodule