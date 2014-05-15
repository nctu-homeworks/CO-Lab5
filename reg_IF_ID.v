module reg_IF_ID (clk_i, rst_n,
	// From IF
	program_suppose_i,
	instruction_i,
	// To ID
	program_suppose_o,
	instruction_o
);

input clk_i, rst_n;
input [31:0] program_suppose_i, instruction_i;
output reg [31:0] program_suppose_o, instruction_o;

always@(posedge clk_i or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		program_suppose_o <= 32'd0;
		instruction_o <= 32'd0;
	end
	else
	begin
		program_suppose_o <= program_suppose_i;
		instruction_o <= instruction_i;
	end
end

endmodule
