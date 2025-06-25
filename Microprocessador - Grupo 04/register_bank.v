// Banco de Registradores
// 8 registradores de 32 bits cada (R0 a R7)
module register_bank(
    input wire clk,
    input wire reset,
    input wire reg_write,          // Sinal de controle para escrita
    input wire [2:0] read_reg1,    // Endereço do registrador rs1
    input wire [2:0] read_reg2,    // Endereço do registrador rs2  
    input wire [2:0] write_reg,    // Endereço do registrador rd
    input wire [31:0] write_data,  // Dados para escrita
    output wire [31:0] read_data1, // Dados do registrador rs1
    output wire [31:0] read_data2  // Dados do registrador rs2
);

    // Array de 8 registradores de 32 bits
    reg [31:0] registers [0:7];
    
    // Inicialização dos registradores
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[0] <= 32'h00000000; // R0 (ZERO) - sempre 0
            registers[1] <= 32'h00000000; // R1 (AT)
            registers[2] <= 32'h00000000; // R2 (V0)
            registers[3] <= 32'h00000000; // R3 (A0)
            registers[4] <= 32'h00000000; // R4 (A1)
            registers[5] <= 32'h00000000; // R5 (T0)
            registers[6] <= 32'h00000000; // R6 (T1)
            registers[7] <= 32'h00000000; // R7 (SP) - Link register for JAL
        end
        else if (reg_write && write_reg != 3'b000) begin // R0 is hardwired to 0 by not writing to it
            registers[write_reg] <= write_data;
        end
    end
    
    // Leitura dos registradores (combinacional)
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
    // R0 is guaranteed to be 0 because:
    // 1. It's reset to 0.
    // 2. The write logic 'write_reg != 3'b000' prevents it from being an explicit target of a write.

endmodule