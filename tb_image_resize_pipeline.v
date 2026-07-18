`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2026 12:05:10
// Design Name: 
// Module Name: tb_image_resize_pipeline
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


module tb_image_resize_pipeline(

    );


reg clk;
reg reset;

wire done;
//dut 
bilinear_pipeline #(

    .H_IN(512),
    .W_IN(512),

    .H_OUT(1024),
    .W_OUT(1024),

    .CHANNELS(1)

) uut (

    .clk(clk),
    .reset(reset),
    .done(done)

);

initial
begin

    clk = 0;

    forever #5 clk = ~clk;

end

initial
begin

    reset = 1;

    #20;

    reset = 0;

end

initial
begin

    // wait until processing finishes
    wait(done);

    // wait few extra cycles
    #100;

    $display("====================================");
    $display("IMAGE SCALING COMPLETED");
    $display("output.hex generated");
    $display("====================================");

    $finish;

end

endmodule

