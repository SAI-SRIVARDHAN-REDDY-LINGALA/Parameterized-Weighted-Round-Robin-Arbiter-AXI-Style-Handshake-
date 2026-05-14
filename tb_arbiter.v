`timescale 1ns/1ps

module tb_weighted_rr;

    parameter N = 4;
    parameter Q = 2;
    parameter WEIGHT_W = 4;

    reg clk;
    reg rst;

    reg  [N-1:0] req;
    reg  ready;

    reg  [WEIGHT_W-1:0] weight [N-1:0];

    wire [N-1:0] grant;
    wire valid;

    // Instantiate DUT
    weighted_rr_arbiter #(
        .N(N),
        .Q(Q),
        .WEIGHT_W(WEIGHT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .ready(ready),
        .weight(weight),
        .grant(grant),
        .valid(valid)
    );

    // Clock generation
    always #5 clk = ~clk;

    // ----------------------------
    // Test Sequence
    // ----------------------------
    initial begin

        clk = 0;
        rst = 1;
        ready = 1;
        req = 0;

        // Define weights
        weight[0] = 3;   // highest priority bandwidth
        weight[1] = 1;
        weight[2] = 2;
        weight[3] = 1;

        #20;
        rst = 0;

        // ----------------------------
        // Test 1: All request active
        // ----------------------------
        $display("=== Test 1: All request active ===");
        req = 4'b1111;

        #200;

        // ----------------------------
        // Test 2: Some requests drop
        // ----------------------------
        $display("=== Test 2: Drop request[0] ===");
        req[0] = 0;

        #150;

        // ----------------------------
        // Test 3: Single requester
        // ----------------------------
        $display("=== Test 3: Only request[2] active ===");
        req = 4'b0100;

        #100;

        // ----------------------------
        // Test 4: Ready backpressure
        // ----------------------------
        $display("=== Test 4: Ready deasserted ===");
        req = 4'b1111;

        #30;
        ready = 0;    // stall
        #50;
        ready = 1;    // resume

        #200;

        $finish;
    end

    // ----------------------------
    // Monitor
    // ----------------------------
    initial begin
        $monitor("Time=%0t | req=%b | grant=%b | valid=%b",
                  $time, req, grant, valid);
    end

endmodule
