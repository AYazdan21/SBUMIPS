module hazard_detection (
    input         ID_EX_memread,
    input  [4:0]  ID_EX_RD,
    input  [4:0]  IF_ID_RS,
    input  [4:0]  IF_ID_RT,
    output reg    stall,

    input         EX_regwrite,  
    input  [4:0]  EX_RD_in,      
    input  [5:0]  IF_ID_opcode   
);

  always @(*) begin
    stall = 1'b0;

    if (ID_EX_memread && ((ID_EX_RD == IF_ID_RS) || (ID_EX_RD == IF_ID_RT))) begin
      stall = 1'b1;
    end
  end
endmodule