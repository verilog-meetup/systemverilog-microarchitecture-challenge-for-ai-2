module f_add (
    input               clk,
    input               rst,
    input  [FLEN - 1:0] a, b,
    input               up_valid,
    output [FLEN - 1:0] res,
    output              down_valid,
    output              busy,
    output              error
);

    logic [          4:0] operation;
    logic [FMTBITS - 1:0] format;
    logic [          6:0] opcode;

    // Floating point opcode, for more info see The RISC-V Instruction Set Manual Volume I
    // Chapter 34. RV32/64G Instruction Set Listings | page 560
    assign opcode = 7'b1010011;

    // Arithmetic operation
    // 5'b00000 - add
    // 5'b00001 - sub
    // 5'b00010 - mult
    // 5'b00011 - div
    // 5'b01011 - sqrt

    assign operation = 5'b00000;
    assign format    = FMTBITS' (1);

    logic [FLEN - 1:0] pre_res;
    logic              pre_down_valid;
    logic              pre_busy;
    logic              pre_error;
    logic [       4:0] pre_flags;

    // Don't account inexact results as errors (0.1 + 0.2 = 0.30000000000000004)
    assign pre_error = | pre_flags[4:1];

    // verilator lint_off PINMISSING
    wally_fpu i_fpu (
        .clk        ( clk            ),
        .reset      ( rst            ),
        .Operation  ( operation      ),
        .Format     ( format         ),
        .Opcode     ( opcode         ),
        .A          ( a              ),
        .B          ( b              ),
        .UpValid    ( up_valid       ),
        .Res        ( pre_res        ),
        .DownValid  ( pre_down_valid ),
        .FDivBusyE  ( pre_busy       ),
        .SetFflagsM ( pre_flags      )
    );
    // verilator lint_on PINMISSING

    logic [FLEN - 1:0] res_r;
    logic              down_valid_r;
    logic              busy_r;
    logic              error_r;

    assign res        = res_r;
    assign down_valid = down_valid_r;
    assign busy       = pre_busy | busy_r;
    assign error      = error_r;

    always_ff @ (posedge clk)
        if (rst)
        begin
            down_valid_r <= 1'b0;
            busy_r       <= 1'b0;
        end
        else
        begin
            down_valid_r <= pre_down_valid;
            busy_r       <= pre_busy;
        end

    always_ff @ (posedge clk)
    begin
        res_r   <= pre_res;
        error_r <= pre_error;
    end

endmodule
