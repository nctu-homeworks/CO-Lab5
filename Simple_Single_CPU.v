module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
reg [63:0] reg_IF_ID;

wire [32-1:0] IF_instruction, ID_instruction, regWriteData, readData1, readData2, 
				ALU_result, Shifter_result, ALU_Shifter_result;
wire RegDst, RegWrite, ALUSrc, Branch, BranchType, MemWrite, MemRead, MemtoReg, ALU_zero;
wire [3-1:0] ALUOP;
wire [32-1:0] instance_signExtend, instance_zeroFilled;

//modules
wire [32-1:0] program_now, IF_program_suppose, ID_program_suppose, program_next,
			program_after_branch;

always@(posedge clk_i)
begin
	reg_IF_ID[63:32] <= IF_program_suppose;
	reg_IF_ID[31:0] <= IF_instruction;

	ID_program_suppose <= reg_IF_ID[63:32];
	ID_instruction <= reg_IF_ID[31:0];
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
		.src1_i(ID_program_suppose),
		.src2_i({instance_signExtend[29:0], 2'b00}),
		.sum_o(program_after_branch)
		);

Mux2to1 #(.size(32)) Mux_branch_or_not(
        .data0_i(IF_program_suppose),
        .data1_i(program_after_branch),
        .select_i(Branch & (ALU_zero ^ BranchType)),
        .data_o(program_next)
        );

Instr_Memory IM(
        .pc_addr_i(program_now),  
	    .instr_o(IF_instruction)    
	    );

wire [5-1:0] writeReg_addr;
		
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ID_instruction[20:16]),
        .data1_i(ID_instruction[15:11]),
        .select_i(RegDst),
        .data_o(writeReg_addr)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(ID_instruction[25:21]) ,  
        .RTaddr_i(ID_instruction[20:16]) ,  
        .RDaddr_i(writeReg_addr) ,  
        .RDdata_i(regWriteData)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(readData1) ,  
        .RTdata_o(readData2)   
        );
	
Decoder Decoder(
        .instr_op_i(ID_instruction[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALUOp_o(ALUOP),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),
		.Branch_o(Branch),
		.BranchType_o(BranchType),
		.MemRead_o(MemRead),
		.MemWrite_o(MemWrite),
		.MemtoReg_o(MemtoReg)
		);

wire [5-1:0] ALU_operation;
wire [2-1:0] FURslt;
		
ALU_Ctrl AC(
        .funct_i(ID_instruction[5:0]),   
        .ALUOp_i(ALUOP),   
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );

Sign_Extend SE(
        .data_i(ID_instruction[15:0]),
        .data_o(instance_signExtend)
        );

Zero_Filled ZF(
        .data_i(ID_instruction[15:0]),
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
        .data0_i({27'd0,ID_instruction[10:6]}),
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



