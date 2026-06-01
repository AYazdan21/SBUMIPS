module IF_stage (
    input         clk,
    input         reset,
    input         stall,
    input  [7:0]  next_pc,

    output [31:0] instr,
    output reg [7:0] pc_plus_4
);

  reg [7:0] pc;

  always @(posedge clk or posedge reset) begin
    if (reset)
      pc <= 8'd0;
    else if (!stall)
      pc <= next_pc;
  end

  InstructionMemory imem (
      .PC_in(pc),
      .clk(clk),
      .Instruction(instr)
  );

  always @(*) begin
    pc_plus_4 = pc + 8'd4;
  end
endmodule

module InstructionMemory (
    input  [7:0] PC_in,
    input        clk,
    output reg [31:0] Instruction
);
  reg [31:0] instructionSET [255:0];
  integer j;

  initial begin
    for (j = 0; j < 256; j = j + 1)
      instructionSET[j] = 32'd0;
  end

  always @(posedge clk) begin
    Instruction <= instructionSET[PC_in[7:2]];
  end


  initial begin

instructionSET[0]  = 32'h20080000;  // addi $t0, $zero, 0    # t0 = 0
instructionSET[1]  = 32'h20090001;  // addi $t1, $zero, 1    # t1 = 1
instructionSET[2]  = 32'h20100000;  // addi $s0, $zero, 0    # s0 = 0
instructionSET[3]  = 32'hAE080000;  // sw   $t0, 0($s0)     # Memory[0] = 0
instructionSET[4]  = 32'h220A0001;  // addi $t2, $s0, 1     # t2 = s0 + 1 => 1 --> pointer to mem
instructionSET[5]  = 32'hAD490000;  // sw   $t1, 0($t2)     # Memory[1] = 1


// Iteration #1: Store fib(2) => Memory[2]
instructionSET[6]  = 32'h01096020;  // t4 = t0 + t1
instructionSET[7]  = 32'h214A0001;  // t2 = t2 + 1
instructionSET[8]  = 32'hAD4C0000;  // sw   $t4, 0($t2)
instructionSET[9]  = 32'h01204020;  // t0 = t1
instructionSET[10] = 32'h01804820;  // t1 = t4

// Iteration #2: Store fib(3) => Memory[3]
instructionSET[11] = 32'h01096020;  
instructionSET[12] = 32'h214A0001;  
instructionSET[13] = 32'hAD4C0000;  
instructionSET[14] = 32'h01204020;  
instructionSET[15] = 32'h01804820;  

// Iteration #3: Store fib(4) => Memory[4]
instructionSET[16] = 32'h01096020; 
instructionSET[17] = 32'h214A0001;
instructionSET[18] = 32'hAD4C0000;
instructionSET[19] = 32'h01204020;
instructionSET[20] = 32'h01804820;

// Iteration #4: Store fib(5) => Memory[5]
instructionSET[21] = 32'h01096020; 
instructionSET[22] = 32'h214A0001;
instructionSET[23] = 32'hAD4C0000;
instructionSET[24] = 32'h01204020;
instructionSET[25] = 32'h01804820;

// Iteration #5: Store fib(6) => Memory[6]
instructionSET[26] = 32'h01096020; 
instructionSET[27] = 32'h214A0001;
instructionSET[28] = 32'hAD4C0000;
instructionSET[29] = 32'h01204020;
instructionSET[30] = 32'h01804820;

// Iteration #6: Store fib(7) => Memory[7]
instructionSET[31] = 32'h01096020; 
instructionSET[32] = 32'h214A0001;
instructionSET[33] = 32'hAD4C0000;
instructionSET[34] = 32'h01204020;
instructionSET[35] = 32'h01804820;

// Iteration #7: Store fib(8) => Memory[8]
instructionSET[36] = 32'h01096020; 
instructionSET[37] = 32'h214A0001;
instructionSET[38] = 32'hAD4C0000;
instructionSET[39] = 32'h01204020;
instructionSET[40] = 32'h01804820;

// Iteration #8: Store fib(9) => Memory[9]
instructionSET[41] = 32'h01096020; 
instructionSET[42] = 32'h214A0001;
instructionSET[43] = 32'hAD4C0000;
instructionSET[44] = 32'h01204020;
instructionSET[45] = 32'h01804820;

// Iteration #9: Store fib(10) => Memory[10]
instructionSET[46] = 32'h01096020; 
instructionSET[47] = 32'h214A0001;
instructionSET[48] = 32'hAD4C0000;
instructionSET[49] = 32'h01204020;
instructionSET[50] = 32'h01804820;

// Iteration #10: Store fib(11) => Memory[11]
instructionSET[51] = 32'h01096020; 
instructionSET[52] = 32'h214A0001;
instructionSET[53] = 32'hAD4C0000;
instructionSET[54] = 32'h01204020;
instructionSET[55] = 32'h01804820;

// Iteration #11: Store fib(12) => Memory[12]
instructionSET[56] = 32'h01096020; 
instructionSET[57] = 32'h214A0001;
instructionSET[58] = 32'hAD4C0000;
instructionSET[59] = 32'h01204020;
instructionSET[60] = 32'h01804820;

// Iteration #12: Store fib(13) => Memory[13]
instructionSET[61] = 32'h01096020; 
instructionSET[62] = 32'h214A0001;
instructionSET[63] = 32'hAD4C0000;
instructionSET[64] = 32'h01204020;
instructionSET[65] = 32'h01804820;

// Iteration #13: Store fib(14) => Memory[14]
instructionSET[66] = 32'h01096020; 
instructionSET[67] = 32'h214A0001;
instructionSET[68] = 32'hAD4C0000;
instructionSET[69] = 32'h01204020;
instructionSET[70] = 32'h01804820;

// Iteration #14: Store fib(15) => Memory[15]
instructionSET[71] = 32'h01096020; 
instructionSET[72] = 32'h214A0001;
instructionSET[73] = 32'hAD4C0000;
instructionSET[74] = 32'h01204020;
instructionSET[75] = 32'h01804820;

// jump to itself so we don't run off
// into random memory after computing fib(15)
  instructionSET[76] = 32'h0800004C;  // j 76 (0x4C = decimal 76)

  end
endmodule