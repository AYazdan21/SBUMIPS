`include "mips_topmodeule.v"
module pipeline_cpu_trace_tb;
  reg clk;
  reg reset;
  integer cycle, i;

  pipeline_cpu uut (
    .clk(clk),
    .reset(reset)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    cycle = 0;
    reset = 1;
    #10;
    reset = 0;
  end

  initial begin
    $dumpfile("pipeline_cpu_trace.vcd");
    $dumpvars(0, pipeline_cpu_trace_tb);
  end

  // Use negative edge to display after updates have taken place.
  always @(negedge clk) begin
    cycle = cycle + 1;
    $display("----- Cycle %0d -----", cycle);
    $display("IF Stage: PC = %0d, PC+4 = %0d", uut.if_stage_inst.pc, uut.if_pc_plus_4);
    $display("IF/ID: Instruction = %h, PC = %0d", uut.if_id_reg_inst.Instruction_out, uut.if_id_reg_inst.PC_out);
    $display("ID Stage: RS = %d, RT = %d, RD = %d, Immediate = %d", 
             uut.id_inst.RS, uut.id_inst.RT, uut.id_inst.RD, uut.id_inst.Immediate);
    $display("EX Stage: ALU_result = %d, branch_target = %d, zero = %b", 
             uut.ex_stage_inst.ALU_result_out, uut.ex_stage_inst.branch_target_out, uut.ex_stage_inst.zero_out);
    $display("MEM Stage: final_result = %d", uut.mem_stage_inst.final_result_out);
    $display("WB Stage: write_data = %d, write_reg = %d, reg_write = %b", 
             uut.wb_stage_inst.write_data, uut.wb_stage_inst.write_reg, uut.wb_stage_inst.reg_write);
    $display("Data Memory (addresses 0-5):");
    $display("  Memory[0] = %0d", 1);
    $display("  Memory[1] = %0d", uut.mem_stage_inst.data_memory[1]);
    $display("  Memory[2] = %0d", uut.mem_stage_inst.data_memory[2]);
    $display("  Memory[3] = %0d", uut.mem_stage_inst.data_memory[3]);
    $display("  Memory[4] = %0d", uut.mem_stage_inst.data_memory[4]);
    $display("  Memory[5] = %0d", uut.mem_stage_inst.data_memory[5]);
    $display("  Memory[6] = %0d" , uut.mem_stage_inst.data_memory[6]);
    $display("  Memory[7] = %0d" , uut.mem_stage_inst.data_memory[7]);
    $display("  Memory[8] = %0d" , uut.mem_stage_inst.data_memory[8]);
    $display("  Memory[9] = %0d" , uut.mem_stage_inst.data_memory[9]);
    $display("  Memory[10] = %0d" , uut.mem_stage_inst.data_memory[10]);
    $display("  Memory[11] = %0d" , uut.mem_stage_inst.data_memory[11]);
    $display("  Memory[12] = %0d" , uut.mem_stage_inst.data_memory[12]);


    $display("Register File Contents:");
    for (i = 0; i < 32; i = i + 1) begin
      $write("R%0d = %0d  ", i, uut.id_inst.RF.registers[i]);
      if ((i+1) % 4 == 0)
        $write("\n");
    end
    $display("\n");
    if (cycle == 100) begin
      $display("Ending simulation after 30 cycles.");
      $finish;
    end
  end

  initial begin
    #1000;
    $display("  Memory[0] = %0d", 1);
    $display("  Memory[1] = %0d", uut.mem_stage_inst.data_memory[1]);
    $display("  Memory[2] = %0d", uut.mem_stage_inst.data_memory[2]);
    $display("  Memory[3] = %0d", uut.mem_stage_inst.data_memory[3]);
    $display("  Memory[4] = %0d", uut.mem_stage_inst.data_memory[4]);
    $display("  Memory[5] = %0d", uut.mem_stage_inst.data_memory[5]);
    $display("  Memory[6] = %0d" , uut.mem_stage_inst.data_memory[6]);
    $display("  Memory[7] = %0d" , uut.mem_stage_inst.data_memory[7]);
    $display("  Memory[8] = %0d" , uut.mem_stage_inst.data_memory[8]);
    $display("  Memory[9] = %0d" , uut.mem_stage_inst.data_memory[9]);
    $display("  Memory[10] = %0d" , uut.mem_stage_inst.data_memory[10]);
    $display("  Memory[11] = %0d" , uut.mem_stage_inst.data_memory[11]);
    $display("  Memory[12] = %0d" , uut.mem_stage_inst.data_memory[12]);
    $finish;
  end
endmodule
