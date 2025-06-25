// Unidade de Controle
// Implementa a máquina de estados e gera os sinais de controle
module control_unit(
    input wire clk,
    input wire reset,
    input wire [4:0] opcode,       // Opcode da instrução (5 bits)
    input wire zero_flag,          // Flag zero da ALU
    output reg pc_write,           // Controle do PC
    output reg pc_source,          // Seletor de fonte do PC: 0 for PC+4, 1 for branch_target
    output reg mem_read,           // Controle de leitura da memória
    output reg mem_write,          // Controle de escrita da memória
    output reg reg_write,          // Controle de escrita no banco de registradores
    output reg alu_src_a,          // Seletor da fonte A da ALU (0: rs1, 1: PC - not fully used by current datapath)
    output reg alu_src_b,          // Seletor da fonte B da ALU (0: rs2/rt, 1: immediate)
    output reg [1:0] reg_dst,      // Seletor do registrador de destino (00:rt, 01:rd, 10:link_reg for JAL)
    output reg [1:0] mem_to_reg,   // Seletor dos dados para escrita no registrador (00:ALU, 01:Mem, 10:PC+4 for JAL)
    output reg [4:0] alu_control,  // Controle da ALU (5 bits, matches alu.v)
    output reg branch,             // Sinal de branch (internal indicator, used for pc_write/pc_source)
    output reg jump                // Sinal de jump (internal indicator, used for pc_write/pc_source)
);

    // Estados da máquina de estados
    parameter FETCH   = 3'b000;
    parameter DECODE  = 3'b001;
    parameter EXECUTE = 3'b010;
    parameter MEMORY  = 3'b011;
    parameter WRITEBACK = 3'b100;
    
    // Estado atual
    reg [2:0] current_state, next_state;
    
    // Registrador para armazenar o opcode
    reg [4:0] opcode_reg; // Stores opcode from DECODE phase for subsequent states
    
    // Transição de estados
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= FETCH;
            opcode_reg <= 5'b00000; // Default to NOP or a safe value
        end
        else begin
            current_state <= next_state;
            if (current_state == DECODE) begin // Latch opcode in DECODE for use in EXECUTE, MEM, WB
                opcode_reg <= opcode;
            end
        end
    end
    
    // Lógica de próximo estado
    always @(*) begin
        case (current_state)
            FETCH: begin
                next_state = DECODE;
            end
            
            DECODE: begin
                next_state = EXECUTE;
            end
            
            EXECUTE: begin
                // Opcodes from alu.v parameters
                // LW: 5'b01101, SW: 5'b01110
                case (opcode_reg) // Use latched opcode_reg
                    5'b01101, 5'b01110: begin // LW, SW
                        next_state = MEMORY;
                    end
                    default: begin
                        next_state = WRITEBACK;
                    end
                endcase
            end
            
            MEMORY: begin
                next_state = WRITEBACK;
            end
            
            WRITEBACK: begin
                next_state = FETCH;
            end
            
            default: begin // Should not happen with defined states
                next_state = FETCH;
            end
        endcase
    end
    
    // Sinais de controle baseados no estado atual e opcode_reg
    always @(*) begin
        // Valores padrão (ativos em baixo ou desabilitados)
        pc_write = 1'b0;
        pc_source = 1'b0; // Default to PC+4 path if pc_write is enabled
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        alu_src_a = 1'b0; // Default to rs1 for ALU Operand A
        alu_src_b = 1'b0; // Default to register (rs2/rt) for ALU Operand B
        reg_dst = 2'b00;  // Default to rt field as destination
        mem_to_reg = 2'b00; // Default to ALU result for writeback
        alu_control = 5'b00000; // Default to NOP/zero/ADD (depends on ALU implementation of 00000)
        branch = 1'b0;    // Not a branch by default
        jump = 1'b0;      // Not a jump by default
        
        case (current_state)
            FETCH: begin
                pc_write = 1'b1;  // Enable PC update
                pc_source = 1'b0; // Select PC+4
            end
            
            DECODE: begin
                // Opcode is latched. Control signals based on opcode_reg are set in EXECUTE.
            end
            
            EXECUTE: begin
                case (opcode_reg) // Use latched opcode from DECODE phase
                    // R-type instructions (ADD, SUB, MUL, DIV, AND, OR, XOR, SLL, SRL, SRA, SLT)
                    // Opcodes: 00001,00010,00100,00101,00110,00111,01000,01010,01011,01100,10100
                    5'b00001, 5'b00010, 5'b00100, 5'b00101, 5'b00110, 
                    5'b00111, 5'b01000, 5'b01010, 5'b01011, 5'b01100, 5'b10100: begin
                        alu_src_a = 1'b0; // rs1
                        alu_src_b = 1'b0; // rs2 (from rt field in datapath)
                        alu_control = opcode_reg; // Pass opcode directly as ALU control for these R-types
                        reg_dst = 2'b01;  // rd field is destination
                    end
                    
                    // I-type immediate instructions (ADDI, XORI)
                    // Opcodes: 00011, 01001
                    5'b00011, 5'b01001: begin 
                        alu_src_a = 1'b0; // rs1
                        alu_src_b = 1'b1; // immediate
                        alu_control = opcode_reg; // Pass opcode directly as ALU control
                        reg_dst = 2'b00;  // rt field is destination
                    end
                    
                    // LW (Load Word) - Opcode: 01101
                    5'b01101: begin
                        alu_src_a = 1'b0; // rs1 (base address register)
                        alu_src_b = 1'b1; // immediate (offset)
                        alu_control = 5'b00001; // ADD_OP: Calculate address (base + offset)
                        reg_dst = 2'b00;  // rt field is destination
                    end
                    
                    // SW (Store Word) - Opcode: 01110
                    5'b01110: begin
                        alu_src_a = 1'b0; // rs1 (base address register)
                        alu_src_b = 1'b1; // immediate (offset)
                        alu_control = 5'b00001; // ADD_OP: Calculate address (base + offset)
                        // No register write for SW, reg_dst is don't care.
                    end
                    
                    // Branch instructions (BEQ, BNE) - Opcodes: 10000, 10001
                    5'b10000, 5'b10001: begin 
                        alu_src_a = 1'b0; // rs1
                        alu_src_b = 1'b0; // rs2 (from rt field in datapath)
                        alu_control = 5'b00010; // SUB_OP: For comparison (rs1 - rs2), sets zero_flag
                        branch = 1'b1;    // Indicate a branch instruction
                    end
                    
                    // JAL (Jump and Link) - Opcode: 10010
                    5'b10010: begin
                        jump = 1'b1;      // Indicate a jump instruction
                        pc_write = 1'b1;  // Enable PC update for the jump
                        pc_source = 1'b1; // Select branch_target (calculated as PC-relative offset)
                        reg_write = 1'b1; // JAL writes PC+4 to link register
                        reg_dst = 2'b10;  // Select link register (R7) as destination
                        mem_to_reg = 2'b10; // Select PC+4 as data to be written to link register
                    end
                    
                    default: begin
                        alu_control = 5'b00000; 
                    end
                endcase
            end
            
            MEMORY: begin
                case (opcode_reg) // Use latched opcode
                    5'b01101: begin // LW
                        mem_read = 1'b1; // Enable memory read
                    end
                    
                    5'b01110: begin // SW
                        mem_write = 1'b1; // Enable memory write
                    end
                endcase
            end
            
            WRITEBACK: begin
                case (opcode_reg) // Use latched opcode
                    // R-type and I-type (arithmetic/logic) that write to registers
                    5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 
                    5'b00110, 5'b00111, 5'b01000, 5'b01001, 5'b01010, 
                    5'b01011, 5'b01100, 5'b10100: begin
                        reg_write = 1'b1; // Enable register write
                        mem_to_reg = 2'b00; // Data from ALU result
                        // reg_dst was set in EXECUTE
                    end
                    
                    5'b01101: begin // LW
                        reg_write = 1'b1; // Enable register write
                        mem_to_reg = 2'b01; // Data from memory
                        // reg_dst was set in EXECUTE
                    end
                endcase
                
                if (branch) begin 
                    case (opcode_reg)
                        5'b10000: begin // BEQ
                            if (zero_flag) begin 
                                pc_write = 1'b1;  
                                pc_source = 1'b1; 
                            end
                        end
                        
                        5'b10001: begin // BNE
                            if (!zero_flag) begin 
                                pc_write = 1'b1;  
                                pc_source = 1'b1; 
                            end
                        end
                    endcase
                end
            end
        endcase
    end

endmodule