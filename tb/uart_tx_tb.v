`timescale 1ns/1ps

module uart_tx_tb;

    localparam integer CLK_FREQ_HZ = 50_000_000;
    localparam integer BAUD_RATE = 115_200;
    localparam integer BIT_TIME_NS =
        (CLK_FREQ_HZ / BAUD_RATE) * 20;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;

    wire tx;
    wire busy;
    wire done;

    always #10 clk = ~clk;

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    task automatic send_and_check(input [7:0] value);
        integer i;
        begin
            @(negedge clk);
            tx_data = value;
            tx_start = 1'b1;

            @(negedge clk);
            tx_start = 1'b0;

            // Sample the middle of the start bit.
            #(BIT_TIME_NS / 2);

            if (tx !== 1'b0 || busy !== 1'b1)
                $fatal(1, "FAIL: invalid start bit");

            // Verify eight data bits, LSB first.
            for (i = 0; i < 8; i = i + 1) begin
                #(BIT_TIME_NS);

                if (tx !== value[i])
                    $fatal(1, "FAIL: data bit %0d", i);
            end

            // Verify the stop bit.
            #(BIT_TIME_NS);

            if (tx !== 1'b1)
                $fatal(1, "FAIL: invalid stop bit");

            // Verify completion.
            #(BIT_TIME_NS / 2 + 1);

            if (done !== 1'b1 || busy !== 1'b0)
                $fatal(1, "FAIL: transfer did not finish");

            $display("PASS: transmitted 0x%02h", value);
        end
    endtask

    initial begin
        $dumpfile("waves/uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        repeat (5) @(negedge clk);
        rst = 0;

        repeat (2) @(negedge clk);

        send_and_check(8'h55);
        send_and_check(8'hA5);

        $display("PASS: UART TX tests completed");
        $finish;
    end

    initial begin
        #500000;
        $fatal(1, "FAIL: simulation timeout");
    end

endmodule
