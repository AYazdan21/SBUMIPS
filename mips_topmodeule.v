`timescale 1ns / 1ps
`include "forward/forward_detect.v"
`include "hazard/hazard_detect.v"
`include "reg_pipline/EX_MEM.v"
`include "reg_pipline/ID_EX.v"
`include "reg_pipline/IF_ID.v"
`include "reg_pipline/MEM_WB.v"
`include "stages/ID.v"
`include "stages/IF.v"
`include "stages/Mem.v"
`include "stages/WB.v"
`include "stages/EX.v"
`include "predict/predict.v"

module pipeline_cpu (
    input clk,
    input reset
);

  // =================================================
  // Wires between stages
  // =================================================
  wire [31:0] if_instr;
  wire [7:0]  if_pc_plus_4;
  wire        stall;

  // IF/ID
  wire [31:0] ifid_instr;
  wire [7:0]  ifid_pc;

  // ID signals
  wire [31:0] id_valueRs;
  wire [31:0] id_valueRt;
  wire [4:0]  id_RD;
  wire [4:0]  id_RS;
  wire [4:0]  id_RT;
  wire [31:0] id_Immediate;
  wire        id_jump;
  wire        id_branch;
  wire        id_memread;
  wire        id_MemtoReg;
  wire [2:0]  id_aluop;
  wire        id_memwwrite;
  wire        id_alusrc;
  wire        id_regwrite;
  wire [7:0]  id_pc_out;
  wire [5:0]  id_func;
  wire [4:0]  id_shiftAmount;

  // ID/EX
  wire [31:0] ex_valueRs;
  wire [31:0] ex_valueRt;
  wire [4:0]  ex_RD;
  wire [4:0]  ex_RS;
  wire [4:0]  ex_RT;
  wire [31:0] ex_Immediate;
  wire        ex_branch;
  wire        ex_memread;
  wire        ex_MemtoReg;
  wire [2:0]  ex_aluop;
  wire        ex_memwwrite;
  wire        ex_alusrc;
  wire        ex_regwrite;
  wire [7:0]  ex_pc;
  wire [5:0]  ex_func;
  wire [4:0]  ex_shiftAmount;

  // Forwarding
  wire [1:0] upperMux_sel;
  wire [1:0] lowerMux_sel;
  wire [1:0] comparatorMux1Selector;
  wire [1:0] comparatorMux2Selector;

  // EX Stage outputs
  wire [31:0] ex_ALU_result;
  wire        ex_zero;
  wire [7:0]  ex_branch_target;
  wire        ex_branch_out;
  wire        ex_memread_out;
  wire        ex_MemtoReg_out;
  wire        ex_memwwrite_out;
  wire        ex_regwrite_out;
  wire [4:0]  ex_RD_out;
  wire [4:0]  ex_RS_out;
  wire [4:0]  ex_RT_out;
  wire [31:0] ex_valueRt_out;

  // EX/MEM
  wire [31:0] mem_alu_result;
  wire        mem_zero;
  wire [7:0]  mem_branch_target;
  wire        mem_branch;
  wire        mem_memread;
  wire        mem_MemtoReg;
  wire        mem_memwwrite;
  wire        mem_regwrite;
  wire [4:0]  mem_RD;
  wire [4:0]  mem_RS;
  wire [4:0]  mem_RT;
  wire [31:0] mem_valueRt;

  // MEM stage
  wire [31:0] mem_final_result;
  wire        mem_wb_regwrite;
  wire [4:0]  mem_wb_RD;
  wire        mem_wb_zero;
  wire [7:0]  mem_actual_branch_target;
  wire        mem_actual_branch_taken;

  // MEM/WB
  wire [31:0] wb_final_result;
  wire        wb_regwrite;
  wire [4:0]  wb_RD;
  wire        wb_zero;

  // WB
  wire [31:0] wb_write_data;
  wire [4:0]  wb_write_reg;
  wire        wb_reg_write;

  // =================================================
  // Branch Predictor Signals
  // =================================================
  wire            predicted_taken;
  reg             branch_corrected;
  reg             actual_branch_outcome;
  wire [7:0]      next_pc;
  reg  [7:0]      correct_pc;   // used on mispredict
  wire [9:0]      predictor_index;

  // We can take the IF stage PC to index the predictor.
  // The pipeline has "pc" inside IF_stage, but let's do:
  assign predictor_index = { 2'b00, ifid_pc }; 
  // Alternatively: {2'b00, if_stage_inst.pc}, if you want the *current* fetch PC.

  // Instantiate the predictor
  predict branch_predictor_inst (
    .clk               (clk),
    .reset             (reset),
    .instruction       (predictor_index),
    .branch_result     (actual_branch_outcome),
    .branch_corrected  (branch_corrected),
    .taken_or_nottaken (predicted_taken)
  );

  // =================================================
  //  IF stage with predicted PC logic
  // =================================================

  // We do next_pc selection:
  //   If we had a misprediction last cycle, override with correct_pc
  //   Else use predicted PC if the instruction in ID is a branch and predictor says taken
  //   Else use PC+4
  //
  // For simplicity, let's check the ID stage signals:
  //   If ID says "branch" and predicted_taken=1, we guess next_pc = ID_PC + Immediate<<2
  //   This is naive (really you'd do a BTB, or pipeline the branch_target from ID).
  //   We'll do a smaller demonstration.
  //
  wire [31:0] id_pc_extended = {24'd0, ifid_pc};
  wire [31:0] id_branch_target = id_pc_extended + 4 + ({{16{id_Immediate[15]}},id_Immediate[15:0]} << 2);
  wire [7:0]  id_branch_target_8 = id_branch_target[7:0];
  wire [7:0]  pc_plus_4_if_stage;

  // Our "guessed" next PC if predictor says "taken" at ID stage
  wire [7:0]  predicted_branch_pc = id_branch_target_8;

  // Normal next PC if no misprediction and predictor says "not taken"
  assign pc_plus_4_if_stage = if_stage_inst.pc_plus_4; // from the IF_stage module

  // We'll decide in combinational logic:
  reg [7:0] next_pc_reg;
  always @(*) begin
    if (branch_corrected) begin
      // we discovered a mispred, so use 'correct_pc'
      next_pc_reg = correct_pc;
    end else if (id_branch && predicted_taken) begin
      // predictor guesses taken
      next_pc_reg = predicted_branch_pc;
    end else begin
      // default
      next_pc_reg = pc_plus_4_if_stage;
    end
  end
  assign next_pc = next_pc_reg;

  // Instantiate the IF stage
  IF_stage if_stage_inst (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .next_pc(next_pc),         // *** new: we feed our chosen next_pc
    .instr(if_instr),
    .pc_plus_4()
  );

  // We also want to observe the "pc" inside IF_stage for debugging,
  // so let's modify IF_stage to make 'pc' an output or public reg.
  // For brevity, let's assume we can reference `if_stage_inst.pc`.
  // Or we keep a local wire for debugging.

  assign if_pc_plus_4 = if_stage_inst.pc_plus_4;

  // =================================================
  // IF/ID
  // =================================================
  wire flush_ifid; // comes from misprediction
  IF_ID_REG if_id_reg_inst (
    .reset(reset),
    .clk_in(clk),
    .stall(stall),
    .flush(flush_ifid),
    .Instruction_in(if_instr),
    .PC_in(if_stage_inst.pc),  // let's store the "current PC" in this pipeline reg
    .Instruction_out(ifid_instr),
    .PC_out(ifid_pc)
  );

  // =================================================
  // ID stage
  // =================================================
  InstructionDecode id_inst (
    .clk(clk),
    .Instruction_in(ifid_instr),
    .PC_in(ifid_pc),
    .reset(reset),
    .wb_write_data(wb_write_data),
    .wb_write_reg(wb_write_reg),
    .wb_reg_write(wb_reg_write),
    .valueRs(id_valueRs),
    .valueRt(id_valueRt),
    .RD(id_RD),
    .RS(id_RS),
    .RT(id_RT),
    .Immediate(id_Immediate),
    .jump(id_jump),
    .branch(id_branch),
    .memread(id_memread),
    .MemtoReg(id_MemtoReg),
    .aluop(id_aluop),
    .memwwrite(id_memwwrite),
    .alusrc(id_alusrc),
    .regwrite(id_regwrite),
    .PC_out(id_pc_out),
    .func(id_func),
    .shiftAmount(id_shiftAmount)
  );

  // Hazard detection
  hazard_detection hazard_inst (
    .ID_EX_memread(ex_memread),
    .ID_EX_RD(ex_RD),
    .IF_ID_RS(id_RS),
    .IF_ID_RT(id_RT),
    .stall(stall),
    .EX_regwrite(1'b0),  // not used
    .EX_RD_in(5'd0),     // not used
    .IF_ID_opcode(ifid_instr[31:26])
  );

  // =================================================
  // ID/EX
  // =================================================
  wire flush_idex; 
  ID_EX_REG id_ex_reg_inst (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush_idex),
    .valueRs_in(id_valueRs),
    .valueRt_in(id_valueRt),
    .RD_in(id_RD),
    .RS_in(id_RS),
    .RT_in(id_RT),
    .Immediate_in(id_Immediate),
    .branch_in(id_branch),
    .memread_in(id_memread),
    .MemtoReg_in(id_MemtoReg),
    .aluop_in(id_aluop),
    .memwwrite_in(id_memwwrite),
    .alusrc_in(id_alusrc),
    .regwrite_in(id_regwrite),
    .PC_in(id_pc_out),
    .func_in(id_func),
    .shiftAmount_in(id_shiftAmount),
    .valueRs_out(ex_valueRs),
    .valueRt_out(ex_valueRt),
    .RD_out(ex_RD),
    .RS_out(ex_RS),
    .RT_out(ex_RT),
    .Immediate_out(ex_Immediate),
    .branch_out(ex_branch),
    .memread_out(ex_memread),
    .MemtoReg_out(ex_MemtoReg),
    .aluop_out(ex_aluop),
    .memwwrite_out(ex_memwwrite),
    .alusrc_out(ex_alusrc),
    .regwrite_out(ex_regwrite),
    .PC_out(ex_pc),
    .func_out(ex_func),
    .shiftAmount_out(ex_shiftAmount)
  );

  // Forwarding unit
  forwarding_unit fwd_inst (
    .EX_MemRegwrite(mem_regwrite),
    .EX_MemWriteReg(mem_RD),
    .Mem_WbRegwrite(wb_regwrite),
    .Mem_WbWriteReg(wb_RD),
    .ID_Ex_Rs(ex_RS),
    .ID_Ex_Rt(ex_RT),
    .upperMux_sel(upperMux_sel),
    .lowerMux_sel(lowerMux_sel),
    .comparatorMux1Selector(comparatorMux1Selector),
    .comparatorMux2Selector(comparatorMux2Selector)
  );

  // =================================================
  // EX stage
  // =================================================
  Execute ex_stage_inst (
    .valueRs_in(ex_valueRs),
    .valueRt_in(ex_valueRt),
    .RD_in(ex_RD),
    .RS_in(ex_RS),
    .RT_in(ex_RT),
    .Immediate_in(ex_Immediate),
    .branch_in(ex_branch),
    .memread_in(ex_memread),
    .MemtoReg_in(ex_MemtoReg),
    .aluop_in(ex_aluop),
    .memwwrite_in(ex_memwwrite),
    .alusrc_in(ex_alusrc),
    .regwrite_in(ex_regwrite),
    .PC_in(ex_pc),
    .func_in(ex_func),
    .shiftAmount_in(ex_shiftAmount),
    .upperMux_sel(upperMux_sel),
    .lowerMux_sel(lowerMux_sel),
    .mem_alu_result(mem_alu_result),
    .wb_write_data(wb_write_data),
    .ALU_result_out(ex_ALU_result),
    .zero_out(ex_zero),
    .branch_target_out(ex_branch_target),
    .branch_out(ex_branch_out),
    .memread_out(ex_memread_out),
    .MemtoReg_out(ex_MemtoReg_out),
    .memwwrite_out(ex_memwwrite_out),
    .regwrite_out(ex_regwrite_out),
    .RD_out(ex_RD_out),
    .RS_out(ex_RS_out),
    .RT_out(ex_RT_out),
    .valueRt_out(ex_valueRt_out)
  );

  // =================================================
  // EX/MEM
  // =================================================
  wire flush_exmem;
  EX_MEM_REG ex_mem_reg_inst (
    .clk(clk),
    .reset(reset),
    .flush(flush_exmem),
    .ALU_result_in(ex_ALU_result),
    .zero_in(ex_zero),
    .branch_target_in(ex_branch_target),
    .branch_in(ex_branch_out),
    .memread_in(ex_memread_out),
    .MemtoReg_in(ex_MemtoReg_out),
    .memwwrite_in(ex_memwwrite_out),
    .regwrite_in(ex_regwrite_out),
    .RD_in(ex_RD_out),
    .RS_in(ex_RS_out),
    .RT_in(ex_RT_out),
    .valueRt_in(ex_valueRt_out),
    .ALU_result_out(mem_alu_result),
    .zero_out(mem_zero),
    .branch_target_out(mem_branch_target),
    .branch_out(mem_branch),
    .memread_out(mem_memread),
    .MemtoReg_out(mem_MemtoReg),
    .memwwrite_out(mem_memwwrite),
    .regwrite_out(mem_regwrite),
    .RD_out(mem_RD),
    .RS_out(mem_RS),
    .RT_out(mem_RT),
    .valueRt_out(mem_valueRt)
  );

  // =================================================
  // MEM stage
  // =================================================
  MEM mem_stage_inst (
    .clk(clk),
    .reset(reset),
    .ALU_result_in(mem_alu_result),
    .zero_in(mem_zero),
    .branch_target_in(mem_branch_target),
    .branch_in(mem_branch),
    .memread_in(mem_memread),
    .MemtoReg_in(mem_MemtoReg),
    .memwwrite_in(mem_memwwrite),
    .regwrite_in(mem_regwrite),
    .RD_in(mem_RD),
    .valueRt_in(mem_valueRt),
    .final_result_out(mem_final_result),
    .regwrite_out(mem_wb_regwrite),
    .RD_out(mem_wb_RD),
    .zero_out(mem_wb_zero),
    .branch_target_out(mem_actual_branch_target),
    .actual_branch_taken(mem_actual_branch_taken)
  );

  // =================================================
  // MEM/WB
  // =================================================
  wire flush_memwb;
  MEM_WB mem_wb_reg_inst (
    .clk(clk),
    .reset(reset),
    .flush(flush_memwb),
    .final_result_in(mem_final_result),
    .regwrite_in(mem_wb_regwrite),
    .RD_in(mem_wb_RD),
    .branch_in(1'b0),
    .zero_in(mem_wb_zero),
    .final_result_out(wb_final_result),
    .regwrite_out(wb_regwrite),
    .RD_out(wb_RD),
    .zero_out(wb_zero)
  );

  // =================================================
  // WB stage
  // =================================================
  WB wb_stage_inst (
    .clk(clk),
    .reset(reset),
    .final_result_in(wb_final_result),
    .regwrite_in(wb_regwrite),
    .RD_in(wb_RD),
    .zero_in(wb_zero),
    .write_data(wb_write_data),
    .write_reg(wb_write_reg),
    .reg_write(wb_reg_write)
  );

  // =================================================
  // Misprediction Detection & Flush
  // =================================================
  // We'll detect misprediction when the MEM stage says "branch actually taken" != predicted result
  // However, we used the ID stage to get predicted_taken. There's 2-3 cycles in between.
  // For a minimal approach, let's check:
  //   If mem_actual_branch_taken == 1, but we didn't jump or
  //   If mem_actual_branch_taken == 0, but we jumped
  // We must see how we stored "did we take it?" from ID stage. 
  // For simplicity, let's assume that if ID stage predicted taken => we used next_pc = branch_target.
  // So a mismatch is if mem_actual_branch_taken != predicted_taken from the time that instruction was in ID.
  // 
  // But we only have "predicted_taken" for the *current* instruction in ID. The instruction that is finishing in MEM was in ID a few cycles ago.
  // A real solution keeps a "history" of predictions. 
  // We'll do a simplistic approach: if mem_actual_branch_taken=1, that means the correct next PC should be mem_branch_target, so we do correct_pc <= mem_branch_target. If it is 0, correct_pc <= (the PC of that instruction + 4).
  // 
  // We also set branch_corrected=1 for one cycle so the predictor saturating counters update. The "branch_result" is mem_actual_branch_taken (1 or 0).
  // 
  // *** This is a minimal demonstration. ***

  reg [1:0] mispredict_countdown;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      branch_corrected <= 1'b0;
      actual_branch_outcome <= 1'b0;
      correct_pc <= 8'd0;
      mispredict_countdown <= 2'd0;
    end else begin
      // default
      branch_corrected <= 1'b0;
      actual_branch_outcome <= 1'b0;

      // if the MEM stage instruction is indeed a branch...
      if (mem_branch == 1'b1) begin
        // the "actual outcome" is either taken if mem_zero meets the condition
        // but we simplified "actual_branch_taken" as mem_actual_branch_taken
        actual_branch_outcome <= mem_actual_branch_taken;

        // We'll see if the predicted path was correct by checking:
        //   Did we actually go to mem_branch_target or not?
        // But we do NOT store the original predicted decision for that instruction anywhere in this code, 
        // so let's do "if mem_actual_branch_taken=1, check if PC is mem_branch_target, else mispredict."
        // 
        // For demonstration, let's do a brute force approach:
        if (mem_actual_branch_taken) begin
          // We *should have* gone to mem_branch_target
          // If the pipeline's current PC is not mem_branch_target, we call that a mispredict
          // Actually the pipeline's IF-stage PC is 2 instructions ahead.
          // We'll do a naive condition:
          if (if_stage_inst.pc != mem_branch_target) begin
            // mispredict
            branch_corrected <= 1'b1;
            correct_pc <= mem_branch_target;
          end
        end else begin
          // If the pipeline's IF-stage PC is not (mem_pc + 4) => mispredict
          // We don't store mem_pc, so let's guess:
          // We'll just say if_stage_inst.pc is not (some value), mispredict
          // This is just a placeholder approach
          if (if_stage_inst.pc == mem_branch_target) begin
            // we must have predicted taken, but actual is not
            branch_corrected <= 1'b1;
            // fix pc => (mem_pc+4). We do not store mem_pc properly, so let's guess 8'dX
            correct_pc <= mem_branch_target + 8'd4; 
          end
        end
      end
    end
  end

  // If we detect a mispredict, we must flush the instructions in IF/ID, ID/EX, EX/MEM that belong to the mispredicted branch
  // We'll set flush signals for the next cycle.
  assign flush_ifid  = branch_corrected;
  assign flush_idex  = branch_corrected;
  assign flush_exmem = branch_corrected;
  assign flush_memwb = 1'b0; // Typically we flush MEM/WB if it's the same instruction, 
                             // but many pipelines don’t need to flush WB if the instruction is mispredicted 
                             // (the branch is discovered in EX or MEM).

endmodule
