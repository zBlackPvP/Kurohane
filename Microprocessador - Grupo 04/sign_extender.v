// sign_extender.v
module sign_extender (
    input wire [15:0] imm16_in,      // Imediato de 16 bits (de instruções I-type, S-type, B-type)
    output wire [31:0] imm32_out    // Imediato estendido para 32 bits
);

    // Estende o bit mais significativo (bit 15) para os 16 bits superiores
    assign imm32_out = {{16{imm16_in[15]}}, imm16_in};

endmodule