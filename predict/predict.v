module predict (
    input clk,
    input reset,
    input [9:0] instruction,    
    input branch_result,       
    input branch_corrected,     
    output reg taken_or_nottaken 
);
    reg [1:0] predict_mem [1023:0];  
    integer i;
    
    // On reset, initialize all saturating counters to 2'b10 (weakly taken)
    always @(posedge reset) begin
        for (i = 0; i < 1024; i = i + 1)
            predict_mem[i] <= 2'b10;
    end

    always @(posedge clk) begin
        if (branch_corrected) begin
            case (predict_mem[instruction])
                2'b00: predict_mem[instruction] <= (branch_result) ? 2'b01 : 2'b00; 
                2'b01: predict_mem[instruction] <= (branch_result) ? 2'b10 : 2'b00; 
                2'b10: predict_mem[instruction] <= (branch_result) ? 2'b11 : 2'b01; 
                2'b11: predict_mem[instruction] <= (branch_result) ? 2'b11 : 2'b10;
            endcase
        end

        // The output guess: if the counter is 2'b10 or 2'b11, predict taken.
        taken_or_nottaken <= (predict_mem[instruction] >= 2'b10);
    end
endmodule