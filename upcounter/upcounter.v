// 8-bit synchronous up counter
//
// Counts from 0 up to 255, wrapping back to 0 on the next clock
// when enabled.  `rst` is a synchronous, active-high reset that
// forces the count back to 0 on the next rising clock edge.
//
// Ports:
//   clk   - clock input
//   rst   - synchronous active-high reset
//   en    - count enable (hold when 1'b0 to freeze the count)
//   count - 8-bit count output

module upcounter(
    input        clk,
    input        rst,
    input        en,
    output [7:0] count
);

    reg [7:0] count_reg;

    always @(posedge clk) begin
        if (rst)
            count_reg <= 8'd0;
        else if (en)
            count_reg <= count_reg + 8'd1;
    end

    assign count = count_reg;

endmodule