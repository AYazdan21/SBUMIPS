module Execute (
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
    // Forwarding signals
    input  [1:0]  upperMux_sel,
    input  [1:0]  lowerMux_sel,
    input  [31:0] mem_alu_result,
    input  [31:0] wb_write_data,

    output [31:0] ALU_result_out,
    output        zero_out,
    output [7:0]  branch_target_out,
    output        branch_out,
    output        memread_out,
    output        MemtoReg_out,
    output        memwwrite_out,
    output        regwrite_out,
    output [4:0]  RD_out,
    output [4:0]  RS_out,
    output [4:0]  RT_out,
    output [31:0] valueRt_out
);
  wire [31:0] operandA = (upperMux_sel == 2'b00) ? valueRs_in :
                         (upperMux_sel == 2'b01) ? wb_write_data :
                         (upperMux_sel == 2'b10) ? mem_alu_result :
                                                   valueRs_in;

  wire [31:0] forwarded_valueRt = (lowerMux_sel == 2'b00) ? valueRt_in :
                                  (lowerMux_sel == 2'b01) ? wb_write_data :
                                  (lowerMux_sel == 2'b10) ? mem_alu_result :
                                                            valueRt_in;

  wire [31:0] second_operand = (alusrc_in) ? Immediate_in : forwarded_valueRt;

  wire [3:0] alu_control_signal;//kind of operation in alu
  ALUControl alu_control_inst (
    .ALUOp(aluop_in),
    .funct(func_in),
    .ALUControl(alu_control_signal)
  );

  wire [31:0] alu_result;
  wire        alu_zero;
  ALU32Bit alu32_inst (
    .data1(operandA),
    .data2(second_operand),
    .ALUControl(alu_control_signal),
    .shiftAmount(shiftAmount_in),
    .reset(1'b0),
    .result(alu_result),
    .zero(alu_zero)
  );

  wire [31:0] PC_extended = {24'd0, PC_in};
  wire [31:0] branch_target_32 = PC_extended + 4 + (Immediate_in << 2);
  assign branch_target_out = branch_target_32[7:0];

  assign branch_out       = branch_in & (alu_zero); 
  assign ALU_result_out   = alu_result;
  assign zero_out         = alu_zero;
  assign memread_out      = memread_in;
  assign MemtoReg_out     = MemtoReg_in;
  assign memwwrite_out    = memwwrite_in;
  assign regwrite_out     = regwrite_in;
  assign RD_out           = RD_in;
  assign RS_out           = RS_in;
  assign RT_out           = RT_in;
  assign valueRt_out      = forwarded_valueRt;
endmodule

module ALUControl(
    input  [2:0] ALUOp,
    input  [5:0] funct,
    output reg [3:0] ALUControl
);
  always @(*) begin
    case (ALUOp)
      3'b000: ALUControl = 4'b0000; // add
      3'b001: ALUControl = 4'b0001; // sub
      3'b101: ALUControl = 4'b1000; // slt
      3'b010: begin // R-type
        case (funct)
          6'b100000: ALUControl = 4'b0000; // add
          6'b100010: ALUControl = 4'b0001; // sub
          6'b101010: ALUControl = 4'b1000; // slt
          default:   ALUControl = 4'b1111;
        endcase
      end
      default: ALUControl = 4'b1111;
    endcase
  end
endmodule

module ALU32Bit(
    input  wire signed [31:0] data1,
    input  wire signed [31:0] data2,
    input  wire [3:0]         ALUControl,
    input  wire [4:0]         shiftAmount,
    input  wire               reset,
    output reg                zero,
    output reg signed [31:0]  result
);
  wire [31:0] neg_data2 = -data2;
  always @(*) begin
    case (ALUControl)
      4'b0000: result = data1 + data2;       // add
      4'b0001: result = data1 + neg_data2;   // sub
      4'b1000: result = (data1 < data2)? 32'd1: 32'd0; // slt
      4'b0010: result = data1 << shiftAmount;
      default: result = 32'd0;
    endcase
    zero = (result == 32'd0);
  end
endmodule
