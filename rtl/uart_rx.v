module uart_rx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE = 115_200
)(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg [7:0] rx_data,
    output reg rx_done,
    output reg framing_error,
    output reg busy
);

    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer HALF_BIT = CLKS_PER_BIT / 2;
    localparam integer COUNTER_W =
        (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

    localparam [1:0] IDLE  = 2'd0,
                     START = 2'd1,
                     DATA  = 2'd2,
                     STOP  = 2'd3;

    reg [1:0] state;
    reg [COUNTER_W-1:0] baud_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    // Synchronize the asynchronous UART input.
    reg rx_meta;
    reg rx_sync;

    always @(posedge clk) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
            state <= IDLE;
            baud_count <= 0;
            bit_index <= 0;
            data_reg <= 0;
            rx_data <= 0;
            rx_done <= 0;
            framing_error <= 0;
            busy <= 0;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;

            rx_done <= 1'b0;
            framing_error <= 1'b0;

            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    baud_count <= 0;

                    if (rx_sync == 1'b0) begin
                        state <= START;
                        busy <= 1'b1;
                    end
                end

                START: begin
                    if (baud_count == HALF_BIT - 1) begin
                        baud_count <= 0;

                        if (rx_sync == 1'b0) begin
                            bit_index <= 0;
                            state <= DATA;
                        end else begin
                            busy <= 1'b0;
                            state <= IDLE;
                        end
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        data_reg[bit_index] <= rx_sync;

                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1'b1;
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        busy <= 1'b0;
                        state <= IDLE;

                        if (rx_sync == 1'b1) begin
                            rx_data <= data_reg;
                            rx_done <= 1'b1;
                        end else begin
                            framing_error <= 1'b1;
                        end
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
