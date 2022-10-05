`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:17:46 09/19/2022
// Design Name:   DAC_AD5676R
// Module Name:   /home/ise/project/DAC/dac_tb.v
// Project Name:  DAC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DAC_AD5676R
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dac_tb;

	// Inputs
	reg rst_inv;
	reg clk;
	reg [23:0] da_data;

	// Outputs
	wire da_sclk;
	wire da_sdin;
	wire da_sync_inv;

	// Instantiate the Unit Under Test (UUT)
	AD5676R uut (
		.rst_inv(rst_inv), 
		.clk(clk), 
		.da_data(da_data), 
		.da_sdin(da_sdin), 
		.da_sync_inv(da_sync_inv)
	);

	initial begin
		// Initialize Inputs
		rst_inv = 1;
		clk = 0;
		da_data = 0;

		// Wait 100 ns for global reset to finis
        
		// Add stimulus here
    #20  rst_inv = 0;
    #40  rst_inv = 1;

    #10  da_data = 24'b101100111000111100001001;
	end
  always
    #10 clk = ~clk;
endmodule

