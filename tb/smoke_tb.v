`timescale 1ns/1ps

module smoke_tb;

    reg clk = 0;

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/smoke.vcd");
        $dumpvars(0, smoke_tb);

        #100;
        $display("SIMULATION OK");
        $finish;
    end

endmodule
