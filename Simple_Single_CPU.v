module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
wire [32-1:0] instruction, regWriteData, readData1, readData2, 
				ALU_result, Shifter_result, ALU_Shifter_result;
wire RegDst, RegWrite, ALUSrc, Jump, Branch, BranchType, MemWrite, MemRead, MemtoReg, ALU_zero;
wire [3-1:0] ALUOP;
wire [32-1:0] instance_signExtend, instance_zeroFilled;

//modules
wire [32-1:0] program_now, program_suppose, program_next,
			program_after_branch, program_no_jump;

Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(program_next) ,   
	    .pc_out_o(program_now) 
	    );
	
Adder Adder_counter_add_4(
        .src1_i(program_now),     
	    .src2_i(32'd4),
	    .sum_o(program_suppose)    
	    );
		
Adder Add_branch_address(
		.src1_i(program_suppose),
		.src2_i({instance_signExtend[29:0], 2'b00}),
		.sum_o(program_after_branch)
		);

Mux2to1 #(.size(32)) Mux_branch_or_not(
        .data0_i(program_suppose),
        .data1_i(program_after_branch),
        .select_i(Branch & (ALU_zero ^ BranchType)),
        .data_o(program_no_jump)
        );

Mux2to1 #(.size(32)) Mux_jump_or_not(
        .data0_i(program_no_jump),
        .data1_i({program_suppose[31:28], instruction[25:0], 2'b00}),
        .select_i(Jump),
        .data_o(program_next)
        );
	
Instr_Memory IM(
        .pc_addr_i(program_now),  
	    .instr_o(instruction)    
	    );

wire [5-1:0] writeReg_addr;
		
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instruction[20:16]),
        .data1_i(instruction[15:11]),
        .select_i(RegDst),
        .data_o(writeReg_addr)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(instruction[25:21]) ,  
        .RTaddr_i(instruction[20:16]) ,  
        .RDaddr_i(writeReg_addr) ,  
        .RDdata_i(regWriteData)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(readData1) ,  
        .RTdata_o(readData2)   
        );
	
Decoder Decoder(
        .instr_op_i(instruction[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALUOp_o(ALUOP),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),
		.Branch_o(Branch),
		.BranchType_o(BranchType),
		.Jump_o(Jump),
		.MemRead_o(MemRead),
		.MemWrite_o(MemWrite),
		.MemtoReg_o(MemtoReg)
		);

wire [5-1:0] ALU_operation;
wire [2-1:0] FURslt;
		
ALU_Ctrl AC(
        .funct_i(instruction[5:0]),   
        .ALUOp_i(ALUOP),   
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );

Sign_Extend SE(
        .data_i(instruction[15:0]),
        .data_o(instance_signExtend)
        );

Zero_Filled ZF(
        .data_i(instruction[15:0]),
        .data_o(instance_zeroFilled)
        );
		
wire [32-1:0] ALUinp2;
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(readData2),
        .data1_i(instance_signExtend),
        .select_i(ALUSrc),
        .data_o(ALUinp2)
        );	
		
ALU ALU(
		.aluSrc1(readData1),
	    .aluSrc2(ALUinp2),
	    .ALU_operation_i(ALU_operation),
		.result(ALU_result),
		.zero(ALU_zero),
		.overflow()
	    );
		
wire [32-1:0] shift_amt;
		
Mux2to1 #(.size(32)) Mux_Shift_v(
        .data0_i({27'd0,instruction[10:6]}),
        .data1_i(readData1),
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
		.data2_i(instance_zeroFilled),
        .select_i(FURslt),
        .data_o(ALU_Shifter_result)
        );

wire [32-1:0] MemReadData;
		
Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(ALU_Shifter_result),
		.data_i(readData2),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(MemReadData)
		);		

Mux2to1 #(.size(32)) Mux_FURslt_or_Memory(
		.data0_i(ALU_Shifter_result),
		.data1_i(MemReadData),
		.select_i(MemtoReg),
		.data_o(regWriteData)
		);
endmodule



