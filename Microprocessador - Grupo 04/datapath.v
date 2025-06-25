// datapath.v
module datapath (
    input wire clk,
    input wire rst,

    // Sinais de Controle da Control Unit
    input wire pc_write_en,        // Renamed from pc_write
    input wire pc_src_sel,         // Renamed from pc_source
    input wire reg_write_en,       // Renamed from reg_write
    input wire [1:0] mem_to_reg_sel, // Renamed from mem_to_reg
    input wire mem_read_en,        // Renamed from mem_read
    input wire mem_write_en,       // Renamed from mem_write
    input wire alu_src_b_sel,      // Renamed from alu_src_b
    input wire [4:0] alu_control_op, // Renamed from alu_control, width corrected
    input wire [1:0] reg_dst_in,     // Renamed from reg_dst, width corrected

    // Saídas para a Control Unit (baseadas na instrução)
    output wire [4:0] opcode_out,    // Renamed from opcode, width corrected
    output wire zero_flag_out
);

    // Fios internos
    wire [31:0] pc_current_q;
    wire [31:0] instruction_q;
    
    wire [2:0] rs1_addr_s, rt_addr_s, rd_addr_from_instr_s;
    reg  [2:0] write_reg_addr_s; // LHS in always block
    wire [31:0] reg_read_data1_s, reg_read_data2_s;
    wire [15:0] imm16_s;
    wire [31:0] sign_extended_imm_s;
    wire [31:0] alu_operand_a_s, alu_operand_b_s;
    wire [31:0] alu_result_s;
    wire [31:0] mem_read_data_s;
    reg  [31:0] reg_write_data_s; // LHS in always block
    wire [31:0] pc_plus_4_s;
    wire [31:0] branch_jump_target_addr_s;

    // 1. Contador de Programa (PC)
    pc_counter pc_unit (
        .clk(clk),
        .reset(rst), 
        .pc_write(pc_write_en),
        .pc_source(pc_src_sel),
        .branch_target(branch_jump_target_addr_s),
        .pc(pc_current_q) 
    );

    // 2. Memória de Instruções
    instruction_memory instr_mem_unit (
        .address(pc_current_q),
        .instruction(instruction_q)
    );

    // Decodificação de campos da instrução
    // Opcode: instr[31:27] (5 bits)
    // Rs1:    instr[26:24] (3 bits)
    // Rt/Rs2: instr[23:21] (3 bits)
    // Rd:     instr[20:18] (3 bits) (para R-type)
    // Imm:    instr[15:0]  (16 bits)
    assign opcode_out = instruction_q[31:27];
    assign rs1_addr_s = instruction_q[26:24];
    assign rt_addr_s  = instruction_q[23:21]; // Used as Rt for I-type, Rs2 for R-type (via alu_operand_b)
    assign rd_addr_from_instr_s = instruction_q[20:18];
    assign imm16_s    = instruction_q[15:0];

    // Cálculo PC+4 (para JAL e MUX MemToReg)
    assign pc_plus_4_s = pc_current_q + 32'd4;
    
    // 3. Extensor de Sinal
    sign_extender sign_ext_unit (
        .imm16_in(imm16_s),
        .imm32_out(sign_extended_imm_s)
    );

    // 4. Banco de Registradores
    // MUX para selecionar o endereço do registrador de escrita
    always @(*) begin
        case (reg_dst_in)
            2'b00:  write_reg_addr_s = rt_addr_s;  // I-type (ADDI, LW uses rt as dest)
            2'b01:  write_reg_addr_s = rd_addr_from_instr_s; // R-type (rd as dest)
            2'b10:  write_reg_addr_s = 3'b111;     // JAL (R7 - link register)
            default: write_reg_addr_s = 3'bxxx;    // Should not happen
        endcase
    end
    
    register_bank reg_bank_unit (
        .clk(clk),
        .reset(rst), 
        .reg_write(reg_write_en),
        .read_reg1(rs1_addr_s),    
        .read_reg2(rt_addr_s),     // For R-type, rt_addr_s acts as rs2_addr. For SW, rt_addr_s is src data reg.
        .write_reg(write_reg_addr_s), 
        .write_data(reg_write_data_s),
        .read_data1(reg_read_data1_s),
        .read_data2(reg_read_data2_s)  // This is data from register specified by rt_addr_s
    );
    
    // ULA Operand A é sempre ReadData1 do banco de registradores (rs1)
    assign alu_operand_a_s = reg_read_data1_s;

    // MUX para ULA Operand B
    // if alu_src_b_sel is 1, use immediate. if 0, use reg_read_data2_s (from rt/rs2 field).
    assign alu_operand_b_s = alu_src_b_sel ? sign_extended_imm_s : reg_read_data2_s;

    // 5. ULA (ALU)
    alu alu_unit (
        .operand_a(alu_operand_a_s),
        .operand_b(alu_operand_b_s),
        .alu_control(alu_control_op),
        .result(alu_result_s), 
        .zero_flag(zero_flag_out)
    );

    // 6. Memória de Dados
    data_memory data_mem_unit (
        .clk(clk),
        // .reset(rst), // data_memory.v does not have rst input
        .address(alu_result_s),     // Endereço vem da ULA (para LW/SW)
        .write_data(reg_read_data2_s),// Dado a escrever vem de ReadData2 (rt field for SW)
        .mem_write(mem_write_en),   
        .mem_read(mem_read_en),    
        .read_data(mem_read_data_s)
    );

    // MUX para selecionar o dado a ser escrito de volta no banco de registradores
    always @(*) begin
        case (mem_to_reg_sel)
            2'b00:  reg_write_data_s = alu_result_s;    // ALU result
            2'b01:  reg_write_data_s = mem_read_data_s; // Data from memory (LW)
            2'b10:  reg_write_data_s = pc_plus_4_s;     // PC+4 (for JAL link address)
            default: reg_write_data_s = 32'hxxxxxxxx; // Should not happen
        endcase
    end

    // Cálculo do endereço de desvio/salto (PC-relativo)
    // Branch/JAL target: PC_current (byte address) + 4 + (sign_extended_offset_words << 2)
    assign branch_jump_target_addr_s = pc_plus_4_s + (sign_extended_imm_s << 2);

endmodule