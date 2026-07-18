`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2026 09:45:17
// Design Name: 
// Module Name: bilinear_pipeline
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


module bilinear_pipeline#(
     parameter H_IN  = 4,
    parameter W_IN  = 4,
     parameter H_OUT = 6,
    parameter W_OUT = 6,
    // 1 = grayscale
    // 3 = RGB
    parameter CHANNELS = 1

)(
    input clk,
    input reset,
    output reg done
);
reg [7:0] input_image  [0:(H_IN*W_IN*CHANNELS)-1];
reg [7:0] output_image [0:(H_OUT*W_OUT*CHANNELS)-1];

integer x_out;
integer y_out;
integer ch;

reg write_done;
reg [15:0] scale_x;
reg [15:0] scale_y;

// capturing hex file and storing it in input memory 
initial begin
    done       = 0;
    write_done = 0;
    x_out = 0;
    y_out = 0;
    ch    = 0;
    $readmemh("input.hex", input_image);
    scale_x = (W_IN << 8) / W_OUT;
    scale_y = (H_IN << 8) / H_OUT;

end
  
  
  // stage 1 computing integer and fractional part ..........
  
reg [31:0] s1_x_in_fixed;
reg [31:0] s1_y_in_fixed;
integer s1_x0;
integer s1_y0;
reg [7:0] s1_a;
reg [7:0] s1_b;
integer s1_x_out;
integer s1_y_out;
integer s1_ch;
integer out_addr;
reg [31:0] x_temp;
reg [31:0] y_temp;
always @(posedge clk)
begin

    if(reset)
    begin

        x_out <= 0;
        y_out <= 0;
        ch    <= 0;

        done <= 0;

    end

    else if(!done)
    begin
     x_temp = x_out * scale_x;
     y_temp = y_out * scale_y;
     s1_x_in_fixed <= x_temp;
     s1_y_in_fixed <= y_temp;
     
     s1_x0 <= x_temp >> 8;// integeer part
     s1_y0 <= y_temp >> 8;

          s1_a <= x_temp[7:0];// fractionl part
         s1_b <= y_temp[7:0];
         
          s1_x_out <= x_out;// values to be forwarded
         s1_y_out <= y_out;
          s1_ch <= ch;


        if(ch == CHANNELS-1)
        begin

            if(x_out == W_OUT-1)
            begin

                x_out <= 0;

                if(y_out == H_OUT-1)
                begin
                    done <= 1;
                end
                else
                begin
                    y_out <= y_out + 1;
                end

            end
            else
            begin
                x_out <= x_out + 1;
            end

        end
        
        else
        begin
            ch <= ch + 1;
        end

    end

end

// stage 2 memory fetch 

reg [7:0] s2_I00;
reg [7:0] s2_I01;
reg [7:0] s2_I10;
reg [7:0] s2_I11;
reg [7:0] s2_a;
reg [7:0] s2_b;
integer s2_ch;
integer s2_x_out;
integer s2_y_out;
integer x_clamped;
integer y_clamped;
integer base_addr;
always @(posedge clk)
begin
    x_clamped = s1_x0;
    y_clamped = s1_y0;

    // boundary ccheck 
    if(x_clamped >= W_IN-1)
        x_clamped = W_IN-2;

    if(y_clamped >= H_IN-1)
        y_clamped = H_IN-2;

    // base address
    base_addr = ((y_clamped * W_IN) + x_clamped) * CHANNELS;

    s2_I00 <= input_image[base_addr + s1_ch];

    s2_I10 <= input_image[base_addr + CHANNELS + s1_ch];

    s2_I01 <= input_image[base_addr + (W_IN*CHANNELS) + s1_ch];

    s2_I11 <= input_image[base_addr + (W_IN*CHANNELS) + CHANNELS + s1_ch];

  
    s2_a <= s1_a;
    s2_b <= s1_b;
    s2_x_out <= s1_x_out;
    s2_y_out <= s1_y_out;
    s2_ch <= s1_ch;

end

// satage 3 intrapolating image 
reg [7:0] s3_pixel;

integer s3_x_out;
integer s3_y_out;

integer s3_ch;

always @(posedge clk)
begin

    s3_pixel <= (((256-s2_a)*(256-s2_b)*s2_I00 +
                  s2_a*(256-s2_b)*s2_I10 +
                  (256-s2_a)*s2_b*s2_I01 +
                  s2_a*s2_b*s2_I11) >> 16);

    s3_x_out <= s2_x_out;
    s3_y_out <= s2_y_out;

    s3_ch <= s2_ch;

end
// stage 4 storing output in output memory
always @(posedge clk)
begin

    out_addr = ((s3_y_out * W_OUT) + s3_x_out) * CHANNELS;

    output_image[out_addr + s3_ch] <= s3_pixel;

end

// writing hex file 
always @(posedge clk)
begin

    if(done && !write_done)
    begin

        write_done <= 1;

        $writememh("output.hex", output_image);

    end

end

endmodule
   