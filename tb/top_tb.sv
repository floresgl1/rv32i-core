module top_tb;

    logic clk, rst_n;

    always #5 clk = ~clk;

    top u_top (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        #20 rst_n = 1;
        repeat(10) @(posedge clk);
        $display("PASS");
        $finish;
    end

endmodule
