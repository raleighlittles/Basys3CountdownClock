`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2019 03:50:21 PM
// Design Name: 
// Module Name: seven-segment-counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Seven_segment_Decrementer(
    input clock,
    input reset, // reset
    // Basys3 uses a common anode 7-segment display, but each of the 4 common-anode
    // lines are connected, so you can only illuminate one display at once
    output reg [3:0] anode_activation,
    output reg [6:0] LED_segment); // corresponds to one of the 7-segments of the display

    reg [26:0] one_second_counter; 
    reg [15:0] displayed_number;
    reg [3:0] LED_activation_set;
    reg [19:0] refresh_counter;
    
    wire one_second_enable; 
    wire [1:0] LED_activating_counter; 
    
    always @(posedge clock or posedge reset)
    begin
        if (reset == 1)
            one_second_counter <= 0;
        else begin
            if (one_second_counter >= 99999999)
            // Reset seconds clock back to 0 if it overflowed 
                 one_second_counter <= 0; 
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    
    assign one_second_enable = (one_second_counter == 99999999)? 1 : 0;
    
    always @(posedge clock or posedge reset)
    begin
        if (reset == 1)
            displayed_number <= 9999;
            
        else if (one_second_enable == 1)
            // Decrement the number displayed every time
            displayed_number <= displayed_number - 1;
    end
    
    always @(posedge clock or posedge reset)
    begin 
        if (reset == 1)
            refresh_counter <= 0;
            
        else
            refresh_counter <= refresh_counter + 1;
    end 
    
    assign LED_activating_counter = refresh_counter[19:18];
    
    always @(*)
    begin
        case(LED_activating_counter)
        // Remember you can only drive one display at a time and there's 
        // no reason why there'd be a refresh period in which all displays
        // are off.
        
        // The position of each bit corresponds to which of the 4 displays is activated
        
        // Remember that for a 4-digit number in the form WXYZ
        // WXYZ / 1000 = W
        // (WXYZ % 1000) / 100 = X
        // ((WXYZ % 1000) % 100) / 10 = Y
        // WXYZ % 10 = Z
        2'b00: begin
            anode_activation = 4'b0111; 
            LED_activation_set = displayed_number / 1000;

              end
        2'b01: begin
            anode_activation = 4'b1011; 
            LED_activation_set = (displayed_number % 1000) / 100;

              end
        2'b10: begin
            anode_activation = 4'b1101; 
            LED_activation_set = ((displayed_number % 1000) % 100) / 10;

                end
        2'b11: begin
            anode_activation = 4'b1110; 
            LED_activation_set = displayed_number % 10;
               end
        endcase
    end
    
    always @(*)
    begin
    // Since this a common anode display, a "low" (0) signal illuminates a specific segment
    // For segment order, see: https://en.wikipedia.org/wiki/Seven-segment_display
        case(LED_activation_set)
        4'b0000: LED_segment= 7'b0000001; // "0"     
        4'b0001: LED_segment = 7'b1001111; // "1" 
        4'b0010: LED_segment = 7'b0010010; // "2" 
        4'b0011: LED_segment = 7'b0000110; // "3" 
        4'b0100: LED_segment = 7'b1001100; // "4" 
        4'b0101: LED_segment = 7'b0100100; // "5" 
        4'b0110: LED_segment = 7'b0100000; // "6" 
        4'b0111: LED_segment = 7'b0001111; // "7" 
        4'b1000: LED_segment = 7'b0000000; // "8"     
        4'b1001: LED_segment = 7'b0000100; // "9" 
        default: LED_segment = 7'b0000001; // "0"
        endcase
    end
 endmodule
