module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [5-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
     
//Internal Signals
wire		[5-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;

//Main function


assign ALU_operation_o = ({ALUOp_i,funct_i} == 9'b010_100000 || ALUOp_i[1:0] == 2'b00) ? 5'b00010 : //add addi lw sw
						 ({ALUOp_i,funct_i} == 9'b010_100010 || ALUOp_i == 3'b001 || ALUOp_i == 3'b110) ? 5'b01010 : //sub beq bne
						 ({ALUOp_i,funct_i} == 9'b010_100100) ? 5'b00000 : //and
						 ({ALUOp_i,funct_i} == 9'b010_100101) ? 5'b00001 : //or
						 ({ALUOp_i,funct_i} == 9'b010_101111) ? 5'b10110 : //not
						 ({ALUOp_i,funct_i} == 9'b010_101010) ? 5'b01011 : //slt
						 ({ALUOp_i,funct_i} == 9'b010_000000) ? 5'b00001 : //sll
						 ({ALUOp_i,funct_i} == 9'b010_000010) ? 5'b00000 : //srl
						 ({ALUOp_i,funct_i} == 9'b010_000100) ? 5'b00011 : 5'b00010; //sllv srlv

						 

assign FURslt_o = 	(ALUOp_i == 3'b101) ? 2'd2 : //lui
					(ALUOp_i == 3'b010 && {funct_i[5:3],funct_i[0]} == 4'b0000) ? 2'd1 : //sll srl sllv srlv
					0; //others

endmodule     
