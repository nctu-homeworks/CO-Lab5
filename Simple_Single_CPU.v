module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
reg [63:0] reg_IF_ID;
reg [191:0] reg_ID_EX;

wire [32-1:0] IF_instruction, ID_instruction, regWriteData, ID_readData1, EX_readData1, ID_readData2, EX_readData2, 
				ALU_result, Shifter_result, ALU_Shifter_result;
wire [20:0] EX_instruction;
wire ID_RegDst, EX_RegDst, ID_RegWrite, EX_RegWrite, ID_ALUSrc, EX_ALUSrc, ID_Branch, EX_Branch, ID_BranchType, EX_BranchType, ID_MemWrite, EX_MemWrite, ID_MemRead, EX_MemRead, ID_MemtoReg, EX_MemtoReg, ALU_zero;
wire [3-1:0] ID_ALUOP, EX_ALUOP;
wire [32-1:0] ID_instance_signExtend, EX_instance_signExtend, ID_instance_zeroFilled, EX_instance_zeroFilled;

//modules
wire [32-1:0] program_now, IF_program_suppose, ID_program_suppose, EX_program_suppose, program_next,
			program_after_branch;

always@(posedge clk_i)
begin
	reg_IF_ID[63:32] <= IF_program_suppose;
	reg_IF_ID[31:0] <= IF_instruction;

	ID_program_suppose <= reg_IF_ID[63:32];
	ID_instruction <= reg_IF_ID[31:0];
end

always@(posedge clk_i)
begin
	reg_ID_EX[191] <= ID_MemtoReg;
	reg_ID_EX[190] <= ID_MemRead;
	reg_ID_EX[189] <= ID_MemWrite;
	reg_ID_EX[188] <= ID_Branch;
	reg_ID_EX[187] <= ID_RegWrite;
	reg_ID_EX[186] <= ID_BranchType;
	reg_ID_EX[185] <= ID_RegDst;
	reg_ID_EX[184:182] <= ID_ALUOP;
	reg_ID_EX[181] <= ID_ALUSrc;
	reg_ID_EX[180:149] <= ID_program_suppose;
	reg_ID_EX[148:117] <= ID_readData1;
	reg_ID_EX[116:85] <= ID_readData2;
	reg_ID_EX[84:53] <= ID_instance_signExtend;
	reg_ID_EX[52:21] <= ID_instance_zeroFilled;
	reg_ID_EX[20:0] <= ID_instruction[20:0];
	
	EX_MemtoReg <= reg_ID_EX[191];
	EX_MemRead <= reg_ID_EX[190];
	EX_MemWrite <= reg_ID_EX[189];
	EX_Branch <= reg_ID_EX[188];
	EX_RegWrite <= reg_ID_EX[187];
	EX_BranchType <= reg_ID_EX[186];
	EX_RegDst <= reg_ID_EX[185];
	EX_ALUOP <= reg_ID_EX[184:182];
	EX_ALUSrc <= reg_ID_EX[181];
	EX_program_suppose <= reg_ID_EX[180:149];
	EX_readData1 <= reg_ID_EX[148:117];
	EX_readData2 <= reg_ID_EX[116:85];
	EX_instance_signExtend <= reg_ID_EX[84:53];
	EX_instance_zeroFilled <= reg_ID_EX[52:21];
	EX_instruction <= reg_ID_EX[20:0];
end

Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(program_next) ,   
	    .pc_out_o(program_now) 
	    );
	
Adder Adder_counter_add_4(
        .src1_i(program_now),     
	    .src2_i(32'd4),
	    .sum_o(IF_program_suppose)    
	    );
		
Adder Add_branch_address(
		.src1_i(EX_program_suppose),
		.src2_i({instance_signExtend[29:0], 2'b00}),
		.sum_o(program_after_branch)
		);

Mux2to1 #(.size(32)) Mux_branch_or_not(
        .data0_i(IF_program_suppose),
        .data1_i(program_after_branch),
        .select_i(EX_Branch & (ALU_zero ^ EX_BranchType)),
        .data_o(program_next)
        );

Instr_Memory IM(
        .pc_addr_i(program_now),  
	    .instr_o(IF_instruction)    
	    );

wire [5-1:0] writeReg_addr;
		
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(EX_instruction[20:16]),
        .data1_i(EX_instruction[15:11]),
        .select_i(EX_RegDst),
        .data_o(writeReg_addr)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(ID_instruction[25:21]) ,  
        .RTaddr_i(ID_instruction[20:16]) ,  
        .RDaddr_i(writeReg_addr) ,  
        .RDdata_i(regWriteData)  , 
        .RegWrite_i(EX_RegWrite),
        .RSdata_o(ID_readData1) ,  
        .RTdata_o(ID_readData2)   
        );
	
Decoder Decoder(
        .instr_op_i(ID_instruction[31:26]), 
	    .RegWrite_o(ID_RegWrite), 
	    .ALUOp_o(ID_ALUOP),   
	    .ALUSrc_o(ID_ALUSrc),   
	    .RegDst_o(ID_RegDst),
		.Branch_o(ID_Branch),
		.BranchType_o(ID_BranchType),
		.MemRead_o(ID_MemRead),
		.MemWrite_o(ID_MemWrite),
		.MemtoReg_o(ID_MemtoReg)
		);

wire [5-1:0] ALU_operation;
wire [2-1:0] FURslt;
		
ALU_Ctrl AC(
        .funct_i(EX_instruction[5:0]),   
        .ALUOp_i(EX_ALUOP),   
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );

Sign_Extend SE(
        .data_i(ID_instruction[15:0]),
        .data_o(ID_instance_signExtend)
        );

Zero_Filled ZF(
        .data_i(ID_instruction[15:0]),
        .data_o(ID_instance_zeroFilled)
        );
		
wire [32-1:0] ALUinp2;
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(EX_readData2),
        .data1_i(EX_instance_signExtend),
        .select_i(EX_ALUSrc),
        .data_o(ALUinp2)
        );	
		
ALU ALU(
		.aluSrc1(EX_readData1),
	    .aluSrc2(ALUinp2),
	    .ALU_operation_i(ALU_operation),
		.result(ALU_result),
		.zero(ALU_zero),
		.overflow()
	    );
		
wire [32-1:0] shift_amt;
		
Mux2to1 #(.size(32)) Mux_Shift_v(
        .data0_i({27'd0,EX_instruction[10:6]}),
        .data1_i(EX_readData1),
        .select_i(ALU_operation[1]),
        .data_o(shift_amt)
        );	
		
Shifter shifter( 
		.result(Shifter_result), 
		.leftRight(ALU_operation[0]),
		.shamt(shift_amt),
		.sftSrc(ALUinp2) 
		);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(ALU_result),
        .data1_i(Shifter_result),
		.data2_i(EX_instance_zeroFilled),
        .select_i(FURslt),
        .data_o(ALU_Shifter_result)
        );

wire [32-1:0] MemReadData;
		
Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(ALU_Shifter_result),
		.data_i(EX_readData2),
		.MemRead_i(EX_MemRead),
		.MemWrite_i(EX_MemWrite),
		.data_o(MemReadData)
		);		

Mux2to1 #(.size(32)) Mux_FURslt_or_Memory(
		.data0_i(ALU_Shifter_result),
		.data1_i(MemReadData),
		.select_i(EX_MemtoReg),
		.data_o(regWriteData)
		);
endmodule



