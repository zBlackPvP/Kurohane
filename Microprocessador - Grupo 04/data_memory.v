// Memória de Dados
module data_memory(
    input wire clk,
    input wire mem_read,           // Sinal de controle para leitura
    input wire mem_write,          // Sinal de controle para escrita
    input wire [31:0] address,     // Endereço de memória
    input wire [31:0] write_data,  // Dados para escrita
    output reg [31:0] read_data    // Dados lidos
);

    // Memória de dados com 1024 posições de 32 bits
    reg [31:0] dmem [0:1023];

    integer i;
    
    // Inicialização da memória
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            dmem[i] = 32'h00000000;
        end
    end
    
    // Operações de memória
    always @(posedge clk) begin
        if (mem_write) begin
            dmem[address[11:2]] <= write_data; // Escrita (word addressing)
        end
    end
    
    always @(*) begin // Combinational read
        if (mem_read) begin
            read_data = dmem[address[11:2]]; // Leitura (word addressing)
        end
        else begin
            read_data = 32'hxxxxxxxx; // Undefined when not reading
        end
    end

endmodule