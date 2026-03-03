module uart_rx (
    input wire clk,
    input wire rst,
    input wire rx,              // serial input
    output reg [7:0] data_out,  // received byte
    output reg data_ready       // high for 1 clk when byte is valid
);

    parameter BAUD_DIV = 500;
    parameter HALF_BAUD = 250;

    // Synchronizer
    reg rx_sync_0, rx_sync_1;

    always @(posedge clk) begin
        rx_sync_0 <= rx;
        rx_sync_1 <= rx_sync_0;
    end

    wire rx_clean = rx_sync_1;

    // State encoding
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;

    reg [8:0] baud_counter = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            baud_counter <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            data_out <= 0;
            data_ready <= 0;
        end else begin

            data_ready <= 0;  // default

            case (state)

                IDLE: begin
                    baud_counter <= 0;
                    bit_index <= 0;

                    if (rx_clean == 0) begin
                        state <= START;
                    end
                end

                START: begin
                    if (baud_counter == HALF_BAUD - 1) begin
                        baud_counter <= 0;

                        if (rx_clean == 0) begin
                            state <= DATA;
                        end else begin
                            state <= IDLE; // false start
                        end

                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                DATA: begin
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 0;

                        shift_reg[bit_index] <= rx_clean;
                        bit_index <= bit_index + 1;

                        if (bit_index == 7) begin
                            state <= STOP;
                        end

                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                STOP: begin
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 0;

                        if (rx_clean == 1) begin
                            data_out <= shift_reg;
                            data_ready <= 1;
                        end

                        state <= IDLE;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

            endcase
        end
    end

endmodule