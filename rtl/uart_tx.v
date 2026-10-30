module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE = 115_200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        busy,
    output reg        done
);

    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
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

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            baud_count <= 0;
            bit_index  <= 0;
            data_reg   <= 0;
            tx         <= 1'b1;
            busy       <= 1'b0;
            done       <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    tx         <= 1'b1;
                    busy       <= 1'b0;
                    baud_count <= 0;

                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx       <= 1'b0;
                        busy     <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        bit_index  <= 0;
                        tx         <= data_reg[0];
                        state      <= DATA;
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;

                        if (bit_index == 7) begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            tx        <= data_reg[bit_index + 1'b1];
                        end
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        busy       <= 1'b0;
                        done       <= 1'b1;
                        state      <= IDLE;
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
