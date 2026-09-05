// Testbench for the 8-bit up counter.
//
// Exercises:
//   - synchronous reset takes effect on the clock edge
//   - counting while enabled
//   - hold while disabled
//   - wrap-around from 255 back to 0
`timescale 1ns/1ps

module upcounter_tb;

    reg        clk = 0;
    reg        rst = 0;
    reg        en  = 0;
    wire [7:0] count;

    upcounter dut(
        .clk(clk),
        .rst(rst),
        .en(en),
        .count(count)
    );

    // 10 ns clock period
    always #5 clk <= ~clk;

    integer errors = 0;

    task check(input [7:0] expected, input string desc);
        if (count !== expected) begin
            $display("FAIL @ %0t: %0s — expected %0d, got %0d",
                     $time, desc, expected, count);
            errors = errors + 1;
        end else begin
            $display("PASS @ %0t: %0s — count = %0d", $time, desc, count);
        end
    endtask

    initial begin
        $dumpfile("upcounter_wave.vcd");
        $dumpvars(0, upcounter_tb);

        // Hold in reset for a couple of cycles
        rst = 1; en = 0;
        #10;  // one full clock edge
        check(8'd0, "reset asserted");

        // Release reset, still disabled
        rst = 0;
        #10;
        check(8'd0, "reset released, en=0 (held)");

        // Enable counting
        en = 1;
        #10; check(8'd1,  "count 1");
        #10; check(8'd2,  "count 2");
        #10; check(8'd3,  "count 3");

        // Disable mid-count — should hold
        en = 0;
        #10; check(8'd3,  "en=0 (held at 3)");
        #10; check(8'd3,  "en=0 (held at 3)");

        // Re-enable
        en = 1;
        #10; check(8'd4,  "count 4");

        // Fast-forward toward wrap-around
        repeat (251) #10;
        check(8'd255, "count 255");

        // Wrap back to 0
        #10;
        check(8'd0, "wrap to 0");

        // Synchronous reset in the middle of counting
        en  = 1;
        #10; check(8'd1, "count 1");
        rst = 1;
        #10; check(8'd0, "sync reset mid-count");

        if (errors == 0)
            $display("upcounter_tb finished — ALL TESTS PASSED");
        else
            $display("upcounter_tb finished — %0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule