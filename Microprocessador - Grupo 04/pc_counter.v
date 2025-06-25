// Contador de Programa (Program Counter)
// Responsável por controlar o endereço da próxima instrução
module pc_counter(
    input wire clk,
    input wire reset,
    input wire pc_write,           // Sinal de controle para escrita no PC
    input wire pc_source,          // 0: PC+4, 1: branch/jump target
    input wire [31:0] branch_target, // Endereço de destino para branches/jumps
    output reg [31:0] pc           // Saída do Program Counter
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;  // Reset para endereço 0
        end
        else if (pc_write) begin
            if (pc_source) begin
                pc <= branch_target;  // Branch ou Jump
            end
            else begin
                pc <= pc + 32'h00000004;  // Próxima instrução (PC + 4)
            end
        end
        // Se pc_write = 0, mantém o valor atual (para stalls)
    end

endmodule