/*

Put any submodules you need here.

You are not allowed to implement your own submodules or functions for the addition,
subtraction, multiplication, division, comparison or getting the square
root of floating-point numbers. For such operations you can only use the
modules from the arithmetic_block_wrappers directory.

*/

module challenge
(
    input                     clk,
    input                     rst,

    input                     arg_vld,
    output                    arg_rdy,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    input  logic              res_rdy,
    output logic [FLEN - 1:0] res
);
    /*

    The Prompt:

    Finish the code of a pipelined block in the file challenge.sv. The block
    computes a formula "a ** 5 + 0.3 * b - c". Ready/valid handshakes for
    the arguments and the result follow the same rules as ready/valid in AXI
    Stream. When a block is not busy, arg_rdy should be 1, it should not
    wait for arg_vld. You are not allowed to implement your own submodules
    or functions for the addition, subtraction, multiplication, division,
    comparison or getting the square root of floating-point numbers. For
    such operations you can only use the modules from the
    arithmetic_block_wrappers directory. You are not allowed to change any
    other files except challenge.sv. You can check the results by running
    the script "simulate". If the script outputs "FAIL" or does not output
    "PASS" from the code in the provided testbench.sv by running the
    provided script "simulate", your design is not working and is not an
    answer to the challenge. When there is no backpressure, your design must
    be able to accept a new set of the inputs (a, b and c) each clock cycle
    back-to-back and generate the computation results without any stalls and
    without requiring empty cycle gaps in the input. The solution code has
    to be synthesizable SystemVerilog RTL. Your design cannot use more than
    10 arithmetic blocks from arithmetic_block_wrappers directory or more
    than 10000 D-flip-flops or other state elements outside those arithmetic
    blocks. The solution also cannot use any SRAM or other embedded memory
    blocks. A human should not help AI by tipping anything on latencies or
    handshakes of the submodules. The AI has to figure this out by itself by
    analyzing the code in the repository directories. Likewise a human
    should not instruct AI how to build a pipeline structure since it makes
    the exercise meaningless.

    */

    // Constant for 0.3 in IEEE 754 double precision
    localparam [FLEN-1:0] CONST_ZERO_DOT_THREE = 64'h3FD3333333333333;

    // Credit-based backpressure: track total in-flight transactions
    // This modern approach is more efficient than the "almost full" method:
    // - Smaller FIFO (32 vs 64): FIFO only needs to hold worst-case in-flight count
    // - No premature stalls: accepts inputs as long as total capacity allows
    // - Pipeline depth is 16 cycles (3+3+3+4+3 = mult_aa + mult_a2a2 + mult_a4a + add + sub)
    localparam PIPELINE_DEPTH = 16;
    localparam FIFO_DEPTH = 32;  // Holds total in-flight (pipeline + buffered outputs)
    localparam TOTAL_CAPACITY = FIFO_DEPTH;

    logic [FLEN-1:0] fifo [0:FIFO_DEPTH-1];
    logic [5:0] fifo_wr_ptr, fifo_rd_ptr;
    logic [5:0] fifo_count;  // Count of items in FIFO
    logic [6:0] in_flight;   // Count of transactions in pipeline + FIFO
    logic internal_res_vld;
    logic [FLEN-1:0] internal_res;

    logic fifo_empty;
    logic input_fire;

    assign input_fire = arg_vld & arg_rdy;
    assign fifo_empty = (fifo_count == 0);
    assign arg_rdy = (in_flight < TOTAL_CAPACITY);

    // Pipeline Stage 1: Compute a*a and 0.3*b in parallel
    logic [FLEN-1:0] aa_res, b03_res;
    logic aa_vld, b03_vld;

    f_mult mult_aa (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(a),
        .up_valid(input_fire),
        .res(aa_res),
        .down_valid(aa_vld),
        .busy(),
        .error()
    );

    f_mult mult_b03 (
        .clk(clk),
        .rst(rst),
        .a(b),
        .b(CONST_ZERO_DOT_THREE),
        .up_valid(input_fire),
        .res(b03_res),
        .down_valid(b03_vld),
        .busy(),
        .error()
    );

    // Delay 'a' by 3 cycles to align with aa_res output
    logic [FLEN-1:0] a_d1, a_d2, a_d3;
    always_ff @(posedge clk) begin
        a_d1 <= a;
        a_d2 <= a_d1;
        a_d3 <= a_d2;
    end

    // Pipeline Stage 2: Compute a^2 * a^2 = a^4
    logic [FLEN-1:0] a4_res;
    logic a4_vld;

    f_mult mult_a2a2 (
        .clk(clk),
        .rst(rst),
        .a(aa_res),
        .b(aa_res),
        .up_valid(aa_vld),
        .res(a4_res),
        .down_valid(a4_vld),
        .busy(),
        .error()
    );

    // Delay a_d3 by 3 more cycles and b03_res by 3 cycles
    logic [FLEN-1:0] a_d4, a_d5, a_d6;
    logic [FLEN-1:0] b03_d1, b03_d2, b03_d3;
    always_ff @(posedge clk) begin
        a_d4 <= a_d3;
        a_d5 <= a_d4;
        a_d6 <= a_d5;

        b03_d1 <= b03_res;
        b03_d2 <= b03_d1;
        b03_d3 <= b03_d2;
    end

    // Pipeline Stage 3: Compute a^4 * a = a^5
    logic [FLEN-1:0] a5_res;
    logic a5_vld;

    f_mult mult_a4a (
        .clk(clk),
        .rst(rst),
        .a(a4_res),
        .b(a_d6),
        .up_valid(a4_vld),
        .res(a5_res),
        .down_valid(a5_vld),
        .busy(),
        .error()
    );

    // Delay b03_d3 by 3 more cycles and c by 9 cycles
    logic [FLEN-1:0] b03_d4, b03_d5, b03_d6;
    logic [FLEN-1:0] c_d1, c_d2, c_d3, c_d4, c_d5, c_d6, c_d7, c_d8, c_d9;
    always_ff @(posedge clk) begin
        b03_d4 <= b03_d3;
        b03_d5 <= b03_d4;
        b03_d6 <= b03_d5;

        c_d1 <= c;
        c_d2 <= c_d1;
        c_d3 <= c_d2;
        c_d4 <= c_d3;
        c_d5 <= c_d4;
        c_d6 <= c_d5;
        c_d7 <= c_d6;
        c_d8 <= c_d7;
        c_d9 <= c_d8;
    end

    // Pipeline Stage 4: Compute a^5 + 0.3*b
    logic [FLEN-1:0] sum_res;
    logic sum_vld;

    f_add add_a5b03 (
        .clk(clk),
        .rst(rst),
        .a(a5_res),
        .b(b03_d6),
        .up_valid(a5_vld),
        .res(sum_res),
        .down_valid(sum_vld),
        .busy(),
        .error()
    );

    // Delay c_d9 by 4 more cycles
    logic [FLEN-1:0] c_d10, c_d11, c_d12, c_d13;
    always_ff @(posedge clk) begin
        c_d10 <= c_d9;
        c_d11 <= c_d10;
        c_d12 <= c_d11;
        c_d13 <= c_d12;
    end

    // Pipeline Stage 5: Compute result - c
    f_sub sub_result_c (
        .clk(clk),
        .rst(rst),
        .a(sum_res),
        .b(c_d13),
        .up_valid(sum_vld),
        .res(internal_res),
        .down_valid(internal_res_vld),
        .busy(),
        .error()
    );

    // Track total in-flight transactions (pipeline + FIFO combined)
    always_ff @(posedge clk) begin
        if (rst) begin
            in_flight <= 0;
        end else begin
            case ({input_fire, res_rdy & ~fifo_empty})
                2'b10: in_flight <= in_flight + 1;  // Input accepted
                2'b01: in_flight <= in_flight - 1;  // Output consumed
                default: in_flight <= in_flight;
            endcase
        end
    end

    // FIFO write: when internal_res_vld is asserted
    always_ff @(posedge clk) begin
        if (rst) begin
            fifo_wr_ptr <= 0;
            for (int i = 0; i < FIFO_DEPTH; i++) begin
                fifo[i] <= '0;
            end
        end else begin
            if (internal_res_vld) begin
                fifo[fifo_wr_ptr[4:0]] <= internal_res;
                fifo_wr_ptr <= fifo_wr_ptr + 1;
            end
        end
    end

    // FIFO read: when res_rdy is asserted and FIFO not empty
    always_ff @(posedge clk) begin
        if (rst) begin
            fifo_rd_ptr <= 0;
        end else begin
            if (res_rdy & ~fifo_empty) begin
                fifo_rd_ptr <= fifo_rd_ptr + 1;
            end
        end
    end

    // FIFO count tracking
    always_ff @(posedge clk) begin
        if (rst) begin
            fifo_count <= 0;
        end else begin
            case ({internal_res_vld, res_rdy & ~fifo_empty})
                2'b10: fifo_count <= fifo_count + 1;
                2'b01: fifo_count <= fifo_count - 1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

    assign res = fifo[fifo_rd_ptr[4:0]];
    assign res_vld = ~fifo_empty;

endmodule
