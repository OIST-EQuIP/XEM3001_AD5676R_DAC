`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:06:03 09/22/2022 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   Using XEM3001v2 global clock 48MHz.
//   dac (module AD5676R) state: INIT: 1 clock,
//                               WRITE: 24 clocks,
//                               CONV: 1 clock,
//                               CONV_WAIT: 1 clock.
//   One loop of dac logic includes 27 clocks, that is 562.5 ns under 48MHz clock.                    
//   (CONV_WAIT might be removed. Saving 1 clock. Then one loop is 26 clocks, 541.6667ns.)
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
    input wire [7:0]  hi_in, 
    output wire [1:0]  hi_out, 
    inout wire [15:0] hi_inout, 
    input clk,
    input rst,
    output led,
    output ldac_inv, // using fpga #11, jp2 #11. 
    output rst_inv, // using fpga #9, jp2 #7.
    output sclk, // using fpga #5, jp2 #5.
    output sync_inv,  // using fpga #10, jp2 #8.
    output sdin // using fpga #7, jp2 #6.
    );
  
  // clock divider
  //reg [16:0] counter;
  assign sclk = clk;//counter[9];
  //always @(posedge clk) begin
  //  counter <= counter + 1;
  //end

  // specify number of wire out
  localparam num_ok_out = 2;
  
  assign rst_inv = rst; //using button 2 (button<1>) as rst. Pushed = 0. 
  assign led = rst_inv; //rst_inv;
  assign ldac_inv = 1'b0; //Held to 0. Transparent mode: directly update input register and DAC register in DAC.
      
  // target interface bus: 
  wire    ti_clk; 
  wire [30:0] ok1; 
  wire [16:0] ok2; 
  wire [17 * num_ok_out - 1:0] ok2s;
  
    // wire in 
  wire [15:0] ep00wire; 
  wire [15:0] ep01wire;
  //wire [15:0] ep02wire;

  // wire Out 
  wire [15:0] ep20wire; 
  wire [15:0] ep21wire;	
  
    // OK interface 
  okHost okHI( 
   .hi_in(hi_in), .hi_out(hi_out), .hi_inout(hi_inout), .ti_clk(ti_clk), 
   .ok1(ok1), .ok2(ok2));
  okWireOR #(.N(num_ok_out)) wireOR(.ok2(ok2), .ok2s(ok2s));
  okWireIn ep00(.ok1(ok1), .ep_addr(8'h00), .ep_dataout(ep00wire));
  okWireIn ep01(.ok1(ok1), .ep_addr(8'h01), .ep_dataout(ep01wire));
  okWireOut ep20 (.ok1(ok1), .ok2(ok2s[0*17 +: 17]), .ep_addr(8'h20), .ep_datain(ep20wire));
  okWireOut ep21 (.ok1(ok1), .ok2(ok2s[1*17 +: 17]), .ep_addr(8'h21), .ep_datain(ep21wire));
  

  // instance of AD5676R
  wire [23:0] data;
  assign data[23:16] = ep01wire[7:0]; // prepare input data to DAC, command and address.
  assign data[15:0] = ep00wire; // The digital value input to DAC.
  
  assign ep20wire = ep00wire; //data[15:0];
  assign ep21wire[7:0] = ep01wire[7:0];//data[23:16];
  
  AD5676R dac(.rst_inv(rst_inv), 
    .clk(sclk), 
    .da_data(data), 
    .da_sdin(sdin), 
    .da_sync_inv(sync_inv)
    );
    
endmodule


