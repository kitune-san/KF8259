//
// KF8255_Priority_Resolver
//
// Written by Kitune-san
//
module KF8259_Priority_Resolver (
    // Inputs from control logic
    input   logic   [2:0]   priority_rotate,
    input   logic   [7:0]   interrupt_mask,
    input   logic   [7:0]   interrupt_special_mask,
    input   logic           special_fully_nest_config,
    input   logic   [7:0]   highest_level_in_service,

    // Inputs
    input   logic   [7:0]   interrupt_request_register,
    input   logic   [7:0]   in_service_register,

    // Outputs
    output  logic   [7:0]   interrupt
);


    //
    // Masked flags
    //
    logic   [7:0]   masked_interrupt_request;
    assign masked_interrupt_request = interrupt_request_register & ~interrupt_mask;

    logic   [7:0]   masked_in_service;
    assign masked_in_service        = in_service_register & ~interrupt_special_mask;


    //
    // Resolve priority
    //
    logic   [7:0]   rotated_request;
    logic   [7:0]   rotated_in_service;
    logic   [7:0]   rotated_highest_level_in_service;
    logic   [7:0]   priority_mask;
    logic   [7:0]   rotated_interrupt;

    function logic [7:0] resolv_priority (input [7:0] request);
        if      (request[0] == 1'b1)    resolv_priority = 8'b00000001;
        else if (request[1] == 1'b1)    resolv_priority = 8'b00000010;
        else if (request[2] == 1'b1)    resolv_priority = 8'b00000100;
        else if (request[3] == 1'b1)    resolv_priority = 8'b00001000;
        else if (request[4] == 1'b1)    resolv_priority = 8'b00010000;
        else if (request[5] == 1'b1)    resolv_priority = 8'b00100000;
        else if (request[6] == 1'b1)    resolv_priority = 8'b01000000;
        else if (request[7] == 1'b1)    resolv_priority = 8'b10000000;
        else                            resolv_priority = 8'b00000000;
    endfunction

    always_comb begin
        casez (priority_rotate)
            3'b000:  rotated_request = { masked_interrupt_request[0],   masked_interrupt_request[7:1] };
            3'b001:  rotated_request = { masked_interrupt_request[1:0], masked_interrupt_request[7:2] };
            3'b010:  rotated_request = { masked_interrupt_request[2:0], masked_interrupt_request[7:3] };
            3'b011:  rotated_request = { masked_interrupt_request[3:0], masked_interrupt_request[7:4] };
            3'b100:  rotated_request = { masked_interrupt_request[4:0], masked_interrupt_request[7:5] };
            3'b101:  rotated_request = { masked_interrupt_request[5:0], masked_interrupt_request[7:6] };
            3'b110:  rotated_request = { masked_interrupt_request[6:0], masked_interrupt_request[7]   };
            3'b111:  rotated_request = masked_interrupt_request;
            default: rotated_request = masked_interrupt_request;
        endcase
    end

    always_comb begin
        casez (priority_rotate)
            3'b000:  rotated_in_service = { masked_in_service[0],   masked_in_service[7:1] };
            3'b001:  rotated_in_service = { masked_in_service[1:0], masked_in_service[7:2] };
            3'b010:  rotated_in_service = { masked_in_service[2:0], masked_in_service[7:3] };
            3'b011:  rotated_in_service = { masked_in_service[3:0], masked_in_service[7:4] };
            3'b100:  rotated_in_service = { masked_in_service[4:0], masked_in_service[7:5] };
            3'b101:  rotated_in_service = { masked_in_service[5:0], masked_in_service[7:6] };
            3'b110:  rotated_in_service = { masked_in_service[6:0], masked_in_service[7]   };
            3'b111:  rotated_in_service = masked_in_service;
            default: rotated_in_service = masked_in_service;
        endcase

        casez (priority_rotate)
            3'b000:  rotated_highest_level_in_service = { highest_level_in_service[0],   highest_level_in_service[7:1] };
            3'b001:  rotated_highest_level_in_service = { highest_level_in_service[1:0], highest_level_in_service[7:2] };
            3'b010:  rotated_highest_level_in_service = { highest_level_in_service[2:0], highest_level_in_service[7:3] };
            3'b011:  rotated_highest_level_in_service = { highest_level_in_service[3:0], highest_level_in_service[7:4] };
            3'b100:  rotated_highest_level_in_service = { highest_level_in_service[4:0], highest_level_in_service[7:5] };
            3'b101:  rotated_highest_level_in_service = { highest_level_in_service[5:0], highest_level_in_service[7:6] };
            3'b110:  rotated_highest_level_in_service = { highest_level_in_service[6:0], highest_level_in_service[7]   };
            3'b111:  rotated_highest_level_in_service = highest_level_in_service;
            default: rotated_highest_level_in_service = highest_level_in_service;
        endcase

        if (special_fully_nest_config == 1'b1)
            rotated_in_service = (rotated_in_service & ~rotated_highest_level_in_service)
                                | {rotated_highest_level_in_service[6:0], 1'b0};
    end

    always_comb begin
        if      (rotated_in_service[0] == 1'b1) priority_mask = 8'b00000000;
        else if (rotated_in_service[1] == 1'b1) priority_mask = 8'b00000001;
        else if (rotated_in_service[2] == 1'b1) priority_mask = 8'b00000011;
        else if (rotated_in_service[3] == 1'b1) priority_mask = 8'b00000111;
        else if (rotated_in_service[4] == 1'b1) priority_mask = 8'b00001111;
        else if (rotated_in_service[5] == 1'b1) priority_mask = 8'b00011111;
        else if (rotated_in_service[6] == 1'b1) priority_mask = 8'b00111111;
        else if (rotated_in_service[7] == 1'b1) priority_mask = 8'b01111111;
        else                                    priority_mask = 8'b11111111;
    end

    assign rotated_interrupt = resolv_priority(rotated_request) & priority_mask;

    always_comb begin
        casez (priority_rotate)
            3'b000:  interrupt = { rotated_interrupt[6:0], rotated_interrupt[7]   };
            3'b001:  interrupt = { rotated_interrupt[5:0], rotated_interrupt[7:6] };
            3'b010:  interrupt = { rotated_interrupt[4:0], rotated_interrupt[7:5] };
            3'b011:  interrupt = { rotated_interrupt[3:0], rotated_interrupt[7:4] };
            3'b100:  interrupt = { rotated_interrupt[2:0], rotated_interrupt[7:3] };
            3'b101:  interrupt = { rotated_interrupt[1:0], rotated_interrupt[7:2] };
            3'b110:  interrupt = { rotated_interrupt[0],   rotated_interrupt[7:1] };
            3'b111:  interrupt = rotated_interrupt;
            default: interrupt = rotated_interrupt;
        endcase
    end
endmodule
