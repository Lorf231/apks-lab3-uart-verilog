`timescale 1ns/1ps

module uart_loopback_tb;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire uart_line;
    wire tx_busy;
    wire tx_done;
    wire rx_busy;
    wire rx_done;
    wire rx_error;
    wire [7:0] rx_data;

    always #10 clk = ~clk;

    uart_tx #(
        .CLK_FREQ_HZ(50_000_000),
        .BAUD_RATE(115_200)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_line),
        .busy(tx_busy),
        .done(tx_done)
    );

    uart_rx #(
        .CLK_FREQ_HZ(50_000_000),
        .BAUD_RATE(115_200)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(uart_line),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .framing_error(rx_error),
        .busy(rx_busy)
    );

    task automatic send_and_verify(input [7:0] value);
        begin
            @(negedge clk);
            tx_data = value;
            tx_start = 1'b1;

            @(negedge clk);
            tx_start = 1'b0;

            @(posedge rx_done);

            if (rx_error !== 1'b0)
                $fatal(1, "FAIL: framing error");

            if (rx_data !== value)
                $fatal(1,
                    "FAIL: expected 0x%02h, received 0x%02h",
                    value, rx_data);

            $display(
                "PASS: sent 0x%02h, received 0x%02h",
                value, rx_data
            );

            @(posedge tx_done);
            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("waves/uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);

        repeat (5) @(negedge clk);
        rst = 0;

        repeat (2) @(negedge clk);

        send_and_verify(8'h55);
        send_and_verify(8'hA5);
        send_and_verify(8'h00);
        send_and_verify(8'hFF);

        $display("PASS: UART TX/RX loopback completed");
        $finish;
    end

    initial begin
        #500000;
        $fatal(1, "FAIL: simulation timeout");
    end

endmodule
