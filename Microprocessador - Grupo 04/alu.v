// Unidade Lógica Aritmética (ALU)
// Executa todas as operações aritméticas e lógicas do processador
module alu(
    input wire [31:0] operand_a,   // Primeiro operando
    input wire [31:0] operand_b,   // Segundo operando
    input wire [4:0] alu_control,  // Sinal de controle da ALU
    output reg [31:0] result,      // Resultado da operação
    output wire zero_flag          // Flag zero (resultado = 0)
);

    // Códigos de controle da ALU (baseados no opcode)
    parameter ADD_OP  = 5'b00001;  // Adição
    parameter SUB_OP  = 5'b00010;  // Subtração
    parameter ADDI_OP = 5'b00011;  // Adição imediata
    parameter MUL_OP  = 5'b00100;  // Multiplicação
    parameter DIV_OP  = 5'b00101;  // Divisão
    parameter AND_OP  = 5'b00110;  // AND lógico
    parameter OR_OP   = 5'b00111;  // OR lógico
    parameter XOR_OP  = 5'b01000;  // XOR lógico
    parameter XORI_OP = 5'b01001;  // XOR imediato (NOT)
    parameter SLL_OP  = 5'b01010;  // Shift Left Logical
    parameter SRL_OP  = 5'b01011;  // Shift Right Logical
    parameter SRA_OP  = 5'b01100;  // Shift Right Arithmetic
    parameter SLT_OP  = 5'b10100;  // Set Less Than
    
    // Operações da ALU
    always @(*) begin
        case (alu_control)
            ADD_OP, ADDI_OP: begin
                result = operand_a + operand_b;
            end
            
            SUB_OP: begin
                result = operand_a - operand_b;
            end
            
            MUL_OP: begin
                result = operand_a * operand_b;
            end
            
            DIV_OP: begin
                if (operand_b != 0) begin
                    result = operand_a / operand_b;
                end
                else begin
                    result = 32'hFFFFFFFF; // Resultado indefinido para divisão por zero
                end
            end
            
            AND_OP: begin
                result = operand_a & operand_b;
            end
            
            OR_OP: begin
                result = operand_a | operand_b;
            end
            
            XOR_OP, XORI_OP: begin
                result = operand_a ^ operand_b;
            end
            
            SLL_OP: begin
                result = operand_a << operand_b[4:0]; // Usa apenas 5 bits para shift
            end
            
            SRL_OP: begin
                result = operand_a >> operand_b[4:0]; // Shift lógico
            end
            
            SRA_OP: begin
                result = $signed(operand_a) >>> operand_b[4:0]; // Shift aritmético
            end
            
            SLT_OP: begin
                result = ($signed(operand_a) < $signed(operand_b)) ? 32'h00000001 : 32'h00000000;
            end
            
            default: begin
                result = 32'h00000000;
            end
        endcase
    end
    
    // Flag zero
    assign zero_flag = (result == 32'h00000000);

endmodule