module WB (
    input         clk,
    input         reset,
    input  [31:0] final_result_in,
    input         regwrite_in,
    input  [4:0]  RD_in,
    input         zero_in,
    output [31:0] write_data,
    output [4:0]  write_reg,
    output        reg_write
);
  assign write_data = final_result_in;
  assign write_reg  = RD_in;
  assign reg_write  = regwrite_in;
endmodule
