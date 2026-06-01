module InstructionDecode (
    input         clk,
    input  [31:0] Instruction_in,
    input  [7:0]  PC_in,
    input         reset,
    input  [31:0] wb_write_data,
    input  [4:0]  wb_write_reg,
    input         wb_reg_write,
    output reg [31:0] valueRs,
    output reg [31:0] valueRt,
    output reg [4:0]  RD,
    output reg [4:0]  RS,
    output reg [4:0]  RT,
    output reg [31:0] Immediate,
    output reg        jump,
    output reg        branch,
    output reg        memread,
    output reg        MemtoReg,
    output reg [2:0]  aluop,
    output reg        memwwrite,
    output reg        alusrc,
    output reg        regwrite,
    output reg [7:0]  PC_out,
    output reg [5:0]  func,
    output reg [4:0]  shiftAmount
);
  wire [5:0] opcode = Instruction_in[31:26];
  wire [4:0] rs     = Instruction_in[25:21];
  wire [4:0] rt     = Instruction_in[20:16];
  wire [4:0] rdR    = Instruction_in[15:11];

  wire        regdst;
  wire        cJump;
  wire        cBranch;
  wire        cMemRead;
  wire        cMemtoReg;
  wire [2:0]  cALUOp;
  wire        cMemWrite;
  wire        cALUSrc;
  wire        cRegWrite;
  wire        cBranchNotEqual; 

  control_unit CU (
      .opcode(opcode),
      .RegWrite(cRegWrite),
      .MemtoReg(cMemtoReg),
      .MemRead(cMemRead),
      .MemWrite(cMemWrite),
      .RegDst(regdst),
      .ALUSrc(cALUSrc),
      .ALUOp(cALUOp),
      .jump(cJump),
      .Branch(cBranch),
      .BranchNotEqual(cBranchNotEqual)
  );

  wire [4:0] writeReg = (regdst) ? rdR : rt;

  wire [31:0] outRs;
  wire [31:0] outRt;
  reg_file RF (
      .clk(clk),
      .rs(rs),
      .rt(rt),
      .write_reg(wb_write_reg),
      .write_data(wb_write_data),
      .reg_write(wb_reg_write),
      .read_data_1(outRs),
      .read_data_2(outRt),
      .reset(reset)
  );

  always @(*) begin
    if (reset) begin
      valueRs     = 32'd0;
      valueRt     = 32'd0;
      RD          = 5'd0;
      RS          = 5'd0;
      RT          = 5'd0;
      Immediate   = 32'd0;
      PC_out      = 8'd0;
      jump        = 1'b0;
      branch      = 1'b0;
      memread     = 1'b0;
      MemtoReg    = 1'b0;
      aluop       = 3'd0;
      memwwrite   = 1'b0;
      alusrc      = 1'b0;
      regwrite    = 1'b0;
      func        = 6'd0;
      shiftAmount = 5'd0;
    end else begin
      valueRs     = outRs;
      valueRt     = outRt;
      RD          = writeReg;
      RS          = rs;
      RT          = rt;
      Immediate   = {{16{Instruction_in[15]}}, Instruction_in[15:0]};
      PC_out      = PC_in;
      jump        = cJump;
      branch      = cBranch;
      memread     = cMemRead;
      MemtoReg    = cMemtoReg;
      aluop       = cALUOp;
      memwwrite   = cMemWrite;
      alusrc      = cALUSrc;
      regwrite    = cRegWrite;
      func        = Instruction_in[5:0];
      shiftAmount = Instruction_in[10:6];
    end
  end
endmodule

module control_unit(
    input  [5:0] opcode,
    output reg RegWrite,
    output reg MemtoReg,
    output reg MemRead,
    output reg MemWrite,
    output reg RegDst,
    output reg ALUSrc,
    output reg [2:0] ALUOp,
    output reg jump,
    output reg Branch,
    output reg BranchNotEqual
);
  always @(*) begin
    RegWrite      = 1'b0;
    MemtoReg      = 1'b0;
    MemRead       = 1'b0;
    MemWrite      = 1'b0;
    RegDst        = 1'b0;
    ALUSrc        = 1'b0;
    ALUOp         = 3'b000;
    jump          = 1'b0;
    Branch        = 1'b0;
    BranchNotEqual= 1'b0;

    case(opcode)
      6'b000000: begin // R-type
        RegWrite = 1'b1;
        RegDst   = 1'b1;
        ALUOp    = 3'b010; // R-type
      end
      6'b100011: begin // lw
        RegWrite = 1'b1;
        MemtoReg = 1'b1;
        MemRead  = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 3'b000; // add
      end
      6'b101011: begin // sw
        MemWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 3'b000; // add
      end
      6'b000100: begin // beq
        Branch   = 1'b1;
        ALUOp    = 3'b001; // sub for comparison
        // BranchNotEqual = 0
      end
      6'b000101: begin // bne
        Branch   = 1'b1;
        ALUOp    = 3'b001; // sub
        BranchNotEqual=1'b1;
      end
      6'b000010: begin // jump
        jump = 1'b1;
      end
      6'b001000: begin // addi
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 3'b000; // add
      end
      default: ; // do nothing
    endcase
  end
endmodule

module reg_file(
    input         clk,
    input  [4:0]  rs,
    input  [4:0]  rt,
    input  [4:0]  write_reg,
    input  [31:0] write_data,
    input         reg_write,
    output [31:0] read_data_1,
    output [31:0] read_data_2,
    input         reset
);
  reg [31:0] registers[31:0];
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1)
        registers[i] <= 32'd0;
    end else begin
      if (reg_write && (write_reg != 5'd0))
        registers[write_reg] <= write_data;
    end
  end

  assign read_data_1 = (rs != 0) ? registers[rs] : 32'd0;
  assign read_data_2 = (rt != 0) ? registers[rt] : 32'd0;
endmodule