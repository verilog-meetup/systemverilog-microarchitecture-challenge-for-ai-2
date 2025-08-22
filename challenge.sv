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
    answer to the challenge. Your design must be able to accept a new set of
    the inputs (a, b and c) each clock cycle back-to-back and generate the
    computation results without any stalls and without requiring empty cycle
    gaps in the input. The solution code has to be synthesizable
    SystemVerilog RTL. Your design cannot use more than 10 arithmetic blocks
    from arithmetic_block_wrappers directory or more than 10000 D-flip-flops
    or other state elements outside those arithmetic blocks. The solution
    also cannot use any SRAM or other embedded memory blocks. A human should
    not help AI by tipping anything on latencies or handshakes of the
    submodules. The AI has to figure this out by itself by analyzing the
    code in the repository directories. Likewise a human should not instruct
    AI how to build a pipeline structure since it makes the exercise
    meaningless.

    */

endmodule
