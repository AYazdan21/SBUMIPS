module forwarding_unit (
  input         EX_MemRegwrite,
  input  [4:0]  EX_MemWriteReg,
  input         Mem_WbRegwrite,
  input  [4:0]  Mem_WbWriteReg,
  input  [4:0]  ID_Ex_Rs,
  input  [4:0]  ID_Ex_Rt,
  output reg [1:0] upperMux_sel,
  output reg [1:0] lowerMux_sel,
  output reg [1:0] comparatorMux1Selector,
  output reg [1:0] comparatorMux2Selector
);

  always @(*) begin
    upperMux_sel           = 2'b00;
    lowerMux_sel           = 2'b00;
    comparatorMux1Selector = 2'b00;
    comparatorMux2Selector = 2'b00;

    // EX/MEM forwarding priority
    if (EX_MemRegwrite && (EX_MemWriteReg != 5'd0)) begin
      if (EX_MemWriteReg == ID_Ex_Rs) begin
        upperMux_sel           = 2'b10;
        comparatorMux1Selector = 2'b01;
      end
      if (EX_MemWriteReg == ID_Ex_Rt) begin
        lowerMux_sel           = 2'b10;
        comparatorMux2Selector = 2'b01;
      end
    end

    // MEM/WB forwarding if EX/MEM didn't apply
    if (Mem_WbRegwrite && (Mem_WbWriteReg != 5'd0)) begin
      if ((Mem_WbWriteReg == ID_Ex_Rs) && (EX_MemWriteReg != ID_Ex_Rs)) begin
        upperMux_sel           = 2'b01;
        comparatorMux1Selector = 2'b10;
      end
      if ((Mem_WbWriteReg == ID_Ex_Rt) && (EX_MemWriteReg != ID_Ex_Rt)) begin
        lowerMux_sel           = 2'b01;
        comparatorMux2Selector = 2'b10;
      end
    end
  end
endmodule