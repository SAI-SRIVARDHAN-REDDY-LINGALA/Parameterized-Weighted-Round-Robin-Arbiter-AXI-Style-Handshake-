module weighted_rr_arbiter #(
    parameter N = 4,
    parameter Q = 4,                         // Base quantum
    parameter WEIGHT_W = 4                   // Weight width
)(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [N-1:0]             req,
    input  wire                     ready,

    input  wire [WEIGHT_W-1:0]      weight [N-1:0],

    output reg  [N-1:0]             grant,
    output wire                     valid
);

    localparam PTR_W = $clog2(N);

    localparam IDLE   = 2'b00;
    localparam GRANT  = 2'b01;
    localparam ROTATE = 2'b10;

    reg [1:0] state, next_state;

    reg [PTR_W-1:0] current_ptr;
    reg [PTR_W-1:0] next_ptr;

    reg [WEIGHT_W+$clog2(Q)-1:0] qcnt;
    reg [WEIGHT_W+$clog2(Q)-1:0] max_cycles;

    integer i;
    reg found;

    assign valid = |grant;

    // -----------------------------
    // Find next requester
    // -----------------------------
    always @(*) begin
        next_ptr = current_ptr;
        found    = 0;

        for (i = 1; i <= N; i = i + 1) begin
            if (!found) begin
                if (req[(current_ptr + i) % N]) begin
                    next_ptr = (current_ptr + i) % N;
                    found = 1;
                end
            end
        end
    end

    // -----------------------------
    // FSM Next State
    // -----------------------------
    always @(*) begin
        next_state = state;

        case (state)

            IDLE: begin
                if (|req)
                    next_state = ROTATE;
            end

            GRANT: begin
                if (!req[current_ptr])
                    next_state = ROTATE;
                else if (qcnt >= max_cycles)
                    next_state = ROTATE;
            end

            ROTATE: begin
                if (found)
                    next_state = GRANT;
                else
                    next_state = IDLE;
            end

        endcase
    end

    // -----------------------------
    // Sequential Logic
    // -----------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            current_ptr <= 0;
            qcnt        <= 0;
            max_cycles  <= 0;
            grant       <= 0;
        end
        else begin
            state <= next_state;

            case (state)

                IDLE: begin
                    grant <= 0;
                    qcnt  <= 0;
                end

                ROTATE: begin
                    if (found) begin
                        current_ptr <= next_ptr;
                        qcnt        <= 1;
                        max_cycles  <= weight[next_ptr] * Q;
                        grant       <= (1 << next_ptr);
                    end
                end

                GRANT: begin
                    if (valid && ready) begin
                        if (req[current_ptr] && qcnt < max_cycles) begin
                            grant <= (1 << current_ptr);
                            qcnt  <= qcnt + 1;
                        end
                        else begin
                            grant <= 0;
                        end
                    end
                end

            endcase
        end
    end

endmodule
