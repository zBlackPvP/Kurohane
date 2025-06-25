// Memória de Instruções
module instruction_memory(
    input wire [31:0] address,     // Endereço da instrução
    output reg [31:0] instruction  // Instrução lida
);

    // Memória de instruções com 1024 posições de 32 bits
    reg [31:0] imem [0:1023];
    integer i;
    
    // Formato da Instrução Adotado (32 bits):
    // Opcode: instr[31:27] (5 bits)
    // Rs1:    instr[26:24] (3 bits)
    // Rt/Rs2: instr[23:21] (3 bits)
    // Rd:     instr[20:18] (3 bits) (para R-type)
    // Unused: instr[17:16] (2 bits) (ou shamt para R-type, mas ALU usa operand_b)
    // Imm:    instr[15:0]  (16 bits) (para I-type, JAL offset)

    // Registradores: R0 (000) a R7 (111)
    // R7 (111) é usado como link register para JAL.

    // Inicialização com programa de teste (formato corrigido)
    initial begin
        // ADDI R1, R0, 10  (R1 = R0 + 10)
        imem[0] = {5'b00011, 3'b000, 3'b001, 5'b00000, 16'd10}; 
        // ADDI R2, R0, 20  (R2 = R0 + 20)
        imem[1] = {5'b00011, 3'b000, 3'b010, 5'b00000, 16'd20};
        // ADD R3, R2, R1   (R3 = R2 + R1)
        imem[2] = {5'b00001, 3'b010, 3'b001, 3'b011, 13'b0}; // Rd is instr[20:18]
        // SUB R4, R1, R3   (R4 = R1 - R3)
        imem[3] = {5'b00010, 3'b001, 3'b011, 3'b100, 13'b0};
        // SW R2, 4(R0)     (Mem[R0+4] = R2) ; offset 4 bytes = 1 word
        imem[4] = {5'b01110, 3'b000, 3'b010, 5'b00000, 16'd4}; 
        // LW R5, 8(R0)     (R5 = Mem[R0+8]) ; offset 8 bytes = 2 words
        imem[5] = {5'b01101, 3'b000, 3'b101, 5'b00000, 16'd8}; 
        // BEQ R5, R2, +2 (Salta para imem[6+1+2] = imem[9] se R5==R2); imm is word offset from PC+4
        imem[6] = {5'b10000, 3'b101, 3'b010, 5'b00000, 16'd2}; // Offset 2 means PC_next = (PC_current+4) + (2<<2)
                                                                // Target instr addr = current_instr_addr + 1 + offset
        // JAL +3 (Salta para imem[7+1+3]=imem[11], Salva PC+4 em R7)
        imem[7] = {5'b10010, 3'b000, 3'b000, 5'b00000, 16'd3}; // rs1, rt can be unused. Target: (PC+4)+(imm<<2). R7 implicitly link.

        // NOPs (ADDI R0, R0, 0)
        imem[8]  = {5'b00011, 3'b000, 3'b000, 5'b00000, 16'd0}; 
        imem[9]  = {5'b00011, 3'b000, 3'b000, 5'b00000, 16'd0}; // Target for BEQ from imem[6]
        imem[10] = {5'b00011, 3'b000, 3'b000, 5'b00000, 16'd0}; 
        imem[11] = {5'b00011, 3'b000, 3'b000, 5'b00000, 16'd0}; // Target for JAL from imem[7]


        // Inicializar restante com NOPs (ADDI r0, r0, 0)
        for (i = 12; i < 1024; i = i + 1) begin
            imem[i] = {5'b00011, 3'b000, 3'b000, 5'b00000, 16'd0};
        end
    end
    
    always @(*) begin
        instruction = imem[address[11:2]]; // word addressing
    end

endmodule