`timescale 1ns/1ps

module uart_rx_error_tb;

    localparam integer CLK_FREQ_HZ = 50_000_000;
    localparam integer BAUD_RATE = 115_200;
    localparam integer CLKS_PER_BIT =
        CLK_FREQ_HZ / BAUD_RATE;

    reg clk = 0;
    reg rst = 1;
    reg rx = 1;

    wire [7:0] rx_data;
    wire rx_done;
    wire framing_error;
    wire busy;

    integer done_count = 0;
    integer error_count = 0;

    always #10 clk = ~clk;

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .framing_error(framing_error),
        .busy(busy)
    );

    // Count one-cycle event pulses.
    always @(posedge rx_done)
        done_count = done_count + 1;

    always @(posedge framing_error)
        error_count = error_count + 1;

    // Drive exactly one UART bit period.
    // The caller starts on a falling clock edge.
    task automatic drive_bit(input level);
        begin
            rx = level;
            repeat (CLKS_PER_BIT) @(negedge clk);
        end
    endtask

    // Send a UART 8N1 frame with a configurable stop bit.
    task automatic drive_frame(
        input [7:0] value,
        input stop_bit
    );
        integer i;
        begin
            @(negedge clk);

            drive_bit(1'b0);

            for (i = 0; i < 8; i = i + 1)
                drive_bit(value[i]);

            drive_bit(stop_bit);

            // Restore idle and allow receiver recovery.
            rx = 1'b1;
            repeat (CLKS_PER_BIT) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("waves/uart_rx_error.vcd");
        $dumpvars(0, uart_rx_error_tb);

        repeat (5) @(negedge clk);
        rst = 0;

        repeat (5) @(negedge clk);

        // TEST 1: short false-start pulse.
        @(negedge clk);
        rx = 1'b0;

        repeat (2) @(negedge clk);
        rx = 1'b1;

        repeat (CLKS_PER_BIT) @(negedge clk);

        if (done_count != 0 || error_count != 0 || busy)
            $fatal(1, "FAIL: false start was accepted");

        $display("PASS: false start rejected");

        // TEST 2: invalid stop bit.
        drive_frame(8'hA5, 1'b0);

        if (error_count != 1 || done_count != 0)
            $fatal(1, "FAIL: framing error not handled");

        $display("PASS: framing error detected");

        // TEST 3: valid frame after the error.
        drive_frame(8'h5A, 1'b1);

        if (done_count != 1 ||
            error_count != 1 ||
            rx_data !== 8'h5A)
            $fatal(1, "FAIL: receiver did not recover");

        $display("PASS: receiver recovered after error");
        $display("PASS: UART RX negative tests completed");

        $finish;
    end

    initial begin
        #500000;
        $fatal(1, "FAIL: simulation timeout");
    end

endmodule
