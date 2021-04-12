//
// KF8255_Interrupt_Request
//
// Written by Kitune-san
//
module KF8259_Interrupt_Request (
    input   logic           clock,
    input   logic           reset,

    // Inputs from control logic
    input   logic           level_toriggered_config,
    input   logic           freeze,
    input   logic   [7:0]   clear_interrupt_request,

    // External inputs
    input   logic   [7:0]   interrupt_request_pin,

    // Outputs
    output  logic   [7:0]   interrupt_request_register
);

    logic   [7:0]   prev_interrupt_request_pin;
    wire    [7:0]   interrupt_request_edge;

    genvar ir_bit_no;
    generate
    for (ir_bit_no = 0; ir_bit_no <= 7; ir_bit_no = ir_bit_no + 1) begin: Request_Latch
        //
        // Edge Sense
        //
        always_ff @(negedge clock, posedge reset) begin
        if (reset)
            prev_interrupt_request_pin[ir_bit_no] <= 1'b1;
        else
            prev_interrupt_request_pin[ir_bit_no] <= interrupt_request_pin[ir_bit_no];
        end

        assign interrupt_request_edge[ir_bit_no] = (prev_interrupt_request_pin[ir_bit_no] == 1'b0) & (interrupt_request_pin[ir_bit_no] == 1'b1);

        //
        // Request Latch
        //
        always_ff @(negedge clock, posedge reset) begin
            if (reset)
                interrupt_request_register[ir_bit_no] <= 1'b0;
            else if (clear_interrupt_request[ir_bit_no])
                interrupt_request_register[ir_bit_no] <= 1'b0;
            else if (freeze)
                interrupt_request_register[ir_bit_no] <= interrupt_request_register[ir_bit_no];
            else if (interrupt_request_register[ir_bit_no])
                interrupt_request_register[ir_bit_no] <= 1'b1;
            else if (level_toriggered_config)
                interrupt_request_register[ir_bit_no] <= interrupt_request_pin[ir_bit_no];
            else
                interrupt_request_register[ir_bit_no] <= interrupt_request_edge[ir_bit_no];
        end
    end
    endgenerate

endmodule