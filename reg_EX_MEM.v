module reg_EX_MEM (clk_i, rst_n,
	// From EX
	RegWrite_i,
	MemtoReg_i,
	Branch_i,
	MemRead_i,
	MemWrite_i,
	program_after_branch_i,
	BeqBne_i,
	ALU_Shifter_result_i,
	readData2_i,
	writeReg_addr_i,
	// To MEM
	RegWrite_o,
	MemtoReg_o,
	Branch_o,
	MemRead_o,
	MemWrite_o,
	program_after_branch_o,
	BeqBne_o,
	ALU_Shifter_result_o,
	readData2_o,
	writeReg_addr_o
);

input RegWrite_i, MemtoReg_i, Branch_i, MemRead_i, MemWrite_i, BeqBne_i;
input [31:0] program_after_branch_i, ALU_Shifter_result_i,
readData2_i;
input [4:0] writeReg_addr_i;

output reg RegWrite_o, MemtoReg_o, Branch_o, MemRead_o, MemWrite_o, BeqBne_o;
output reg [31:0] program_after_branch_o, ALU_Shifter_result_o,
readData2_o;
output reg [4:0] writeReg_addr_o;

always@(posedge clk_i or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		RegWrite_o <= 1'd0;
		MemtoReg_o <= 1'd0;
		Branch_o <= 1'd0;
		MemRead_o <= 1'd0;
		MemWrite_o <= 1'd0;
		program_after_branch_o <= 32'd0;
		BeqBne_o <= 1'd0;
		ALU_Shifter_result_o <= 32'd0;
		readData2_o <= 32'd0;
		writeReg_addr_o <= 5'd0;
	end
	else
	begin
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
		Branch_o <= Branch_i;
		MemRead_o <= MemRead_i;
		MemWrite_o <= MemWrite_i;
		program_after_branch_o <= program_after_branch_i;
		BeqBne_o <= BeqBne_i;
		ALU_Shifter_result_o <= ALU_Shifter_result_i;
		readData2_o <= readData2_i;
		writeReg_addr_o <= writeReg_addr_i;
	end
end

endmodule
