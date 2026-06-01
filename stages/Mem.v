module MEM (
    input         clk,
    input         reset,
    input  [31:0] ALU_result_in,
    input         zero_in,
    input  [7:0]  branch_target_in,
    input         branch_in,
    input         memread_in,
    input         MemtoReg_in,
    input         memwwrite_in,
    input         regwrite_in,
    input  [4:0]  RD_in,
    input  [31:0] valueRt_in,
    output [31:0] final_result_out,
    output        regwrite_out,
    output [4:0]  RD_out,
    output        zero_out,
    output [7:0]  branch_target_out,
    output        actual_branch_taken
);
  reg [31:0] data_memory [0:255];
  integer j;

  always @(posedge clk) begin
    if (reset) begin
      for (j = 0; j < 256; j = j + 1)
        data_memory[j] <= 32'd0;
    end else begin
      if (memwwrite_in) 
        data_memory[ALU_result_in[7:0]] <= valueRt_in;
    end
  end

  wire [31:0] mem_read_data = (memread_in)? data_memory[ALU_result_in[7:0]] : 32'd0;
  assign final_result_out   = (MemtoReg_in)? mem_read_data : ALU_result_in;
  assign regwrite_out       = regwrite_in;
  assign RD_out             = RD_in;
  assign zero_out           = zero_in;

  // Expose the actual outcome so the pipeline can detect if branch is taken
  assign branch_target_out  = branch_target_in;
  assign actual_branch_taken= branch_in;  // 1 if it’s a branch & zero_in = correct condition
endmodule
