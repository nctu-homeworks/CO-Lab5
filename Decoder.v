module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o,
				Branch_o, BranchType_o, Jump_o, MemRead_o, MemWrite_o, MemtoReg_o );
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output			RegDst_o;
output			Branch_o, BranchType_o, Jump_o, MemRead_o, MemWrite_o, MemtoReg_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire			RegDst_o;
wire			Branch_o, BranchType_o, Jump_o, MemRead_o, MemWrite_o, MemtoReg_o;

//Main function

assign RegDst_o = (instr_op_i == 6'b000000) ? 1'b1 : 1'b0;

assign RegWrite_o = (	instr_op_i == 6'b101011 ||
						instr_op_i == 6'b000100 ||
						instr_op_i == 6'b000101 ||
						instr_op_i == 6'b000010		) ? 1'b0 : 1'b1;
				  		  
assign ALUOp_o =	(instr_op_i == 6'b000000) ? 3'b010 :
					(instr_op_i == 6'b001000) ? 3'b100 :
					(instr_op_i == 6'b001111) ? 3'b101 :
					(instr_op_i == 6'b100011 || instr_op_i == 6'b101011) ? 3'b000 :
					(instr_op_i == 6'b000100) ? 3'b001 : 3'b110;

assign ALUSrc_o = (		instr_op_i == 6'b001000 ||
						instr_op_i == 6'b001111 ||
						instr_op_i == 6'b100011 ||
						instr_op_i == 6'b101011		) ? 1'b1 : 1'b0;

assign Jump_o = (instr_op_i == 6'b000010) ? 1'b1 : 1'b0;
assign Branch_o = (instr_op_i[5:1] == 5'b00010) ? 1'b1 : 1'b0;
assign BranchType_o = instr_op_i[0];
assign MemWrite_o = (instr_op_i == 6'b101011) ? 1'b1 : 1'b0;
assign MemRead_o = (instr_op_i == 6'b100011) ? 1'b1 : 1'b0;
assign MemtoReg_o = (instr_op_i == 6'b100011) ? 1'b1 : 1'b0;

endmodule
   