// microcontroller_top.v
module microcontroller_top (
    input wire clk,
    input wire rst
);

    // Fios para conectar Datapath e Control Unit
    wire pc_write_en_s;
    wire pc_src_sel_s;
    wire reg_write_en_s;
    wire [1:0] mem_to_reg_sel_s;
    wire mem_read_en_s;
    wire mem_write_en_s;
    wire alu_src_b_sel_s;
    wire [4:0] alu_control_op_s; 
    wire [1:0] reg_dst_s;        

    wire [4:0] opcode_s;         
    wire zero_flag_s;

    // Instância do Datapath
    datapath dp_unit (
        .clk(clk),
        .rst(rst),
        .pc_write_en(pc_write_en_s),
        .pc_src_sel(pc_src_sel_s),
        .reg_write_en(reg_write_en_s),
        .mem_to_reg_sel(mem_to_reg_sel_s),
        .mem_read_en(mem_read_en_s),
        .mem_write_en(mem_write_en_s),
        .alu_src_b_sel(alu_src_b_sel_s),
        .alu_control_op(alu_control_op_s),
        .reg_dst_in(reg_dst_s),         
        .opcode_out(opcode_s),          
        .zero_flag_out(zero_flag_s)
    );

    // Instância da Control Unit
    control_unit ctrl_unit (
        .clk(clk), 
        .reset(rst), 
        .opcode(opcode_s),           
        .zero_flag(zero_flag_s),     
        .pc_write(pc_write_en_s),       
        .pc_source(pc_src_sel_s),      
        .mem_read(mem_read_en_s),       
        .mem_write(mem_write_en_s),      
        .reg_write(reg_write_en_s),      
        .alu_src_a(), // alu_src_a from CU not currently used by datapath logic (operand A fixed to rs1)
        .alu_src_b(alu_src_b_sel_s),      
        .reg_dst(reg_dst_s),           
        .mem_to_reg(mem_to_reg_sel_s),   
        .alu_control(alu_control_op_s), 
        .branch(), // branch signal from CU not used at this top level
        .jump()    // jump signal from CU not used at this top level
    );

endmodule