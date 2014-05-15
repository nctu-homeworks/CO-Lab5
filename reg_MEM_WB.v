module reg_MEM_WB (clk_i, rst_n,
	// From MEM
	RegWrite_i,
	MemtoReg_i,
	MemReadData_i,
	ALU_Shifter_result_i,
	writeReg_addr_i,
	// To WB
	RegWrite_o,
	MemtoReg_o,
	MemReadData_o,
	ALU_Shifter_result_o,
	writeReg_addr_o
);

input clk_i, rst_n;
input RegWrite_i, MemtoReg_i;
input [31:0] MemReadData_i, ALU_Shifter_result_i;
input [4:0] writeReg_addr_i;

output reg RegWrite_o, MemtoReg_o;
output reg [31:0] MemReadData_o, ALU_Shifter_result_o;
output reg [4:0] writeReg_addr_o;

always@(posedge clk_i or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		RegWrite_o <= 1'd0;
		MemtoReg_o <= 1'd0;
		MemReadData_o <= 32'd0;
		ALU_Shifter_result_o <= 32'd0;
		writeReg_addr_o <= 5'd0;
	end
	else
	begin
		RegWrite_o <= RegWrite_i;
		MemtoReg_o <= MemtoReg_i;
		MemReadData_o <= MemReadData_i;
		ALU_Shifter_result_o <= ALU_Shifter_result_i;
		writeReg_addr_o <= writeReg_addr_i;
	end
end

endmodule
