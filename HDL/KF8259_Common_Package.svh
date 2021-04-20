//
// KF8259_Common_Package
//
// Written by Kitune-san
//
`ifndef KF8259_COMMON_PACKAGE_SVH
`define KF8259_COMMON_PACKAGE_SVH

package KF8259_Common_Package;
    function logic [7:0] rotate_right (input [7:0] source, input [2:0] rotate);
        casez (rotate)
            3'b000:  rotate_right = { source[0],   source[7:1] };
            3'b001:  rotate_right = { source[1:0], source[7:2] };
            3'b010:  rotate_right = { source[2:0], source[7:3] };
            3'b011:  rotate_right = { source[3:0], source[7:4] };
            3'b100:  rotate_right = { source[4:0], source[7:5] };
            3'b101:  rotate_right = { source[5:0], source[7:6] };
            3'b110:  rotate_right = { source[6:0], source[7]   };
            3'b111:  rotate_right = source;
            default: rotate_right = source;
        endcase
    endfunction

    function logic [7:0] rotate_left (input [7:0] source, input [2:0] rotate);
        casez (rotate)
            3'b000:  rotate_left = { source[6:0], source[7]   };
            3'b001:  rotate_left = { source[5:0], source[7:6] };
            3'b010:  rotate_left = { source[4:0], source[7:5] };
            3'b011:  rotate_left = { source[3:0], source[7:4] };
            3'b100:  rotate_left = { source[2:0], source[7:3] };
            3'b101:  rotate_left = { source[1:0], source[7:2] };
            3'b110:  rotate_left = { source[0],   source[7:1] };
            3'b111:  rotate_left = source;
            default: rotate_left = source;
        endcase
    endfunction

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
endpackage

`endif
