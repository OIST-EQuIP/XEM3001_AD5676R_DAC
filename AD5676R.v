`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:34 09/22/2022 
// Design Name: 
// Module Name:    AD5676R 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AD5676R  
  #(parameter DATA_WIDTH=24)
  (
    input rst_inv, //active low
    input clk,
    input [DATA_WIDTH-1:0] da_data,
    output reg da_sdin,
    output reg da_sync_inv //active low
    );

  localparam
    STATE_INIT = 2'd0,
    STATE_WRITE = 2'd1,
    STATE_CONV = 2'd2,
    STATE_CONV_WAIT = 2'd3; // it might be removed for AD5676R
  localparam   STATE_REG_WIDTH = 2;

  //Signals
  reg [DATA_WIDTH-1:0] da_buf;
  reg [STATE_REG_WIDTH-1:0] current_state;
  reg [4:0] counter;
  
  function [STATE_REG_WIDTH-1:0] next_state(
    input [STATE_REG_WIDTH-1:0] state,
    input write_done
  );
    begin
     next_state = state;
     case(state)
      STATE_INIT:
        next_state = STATE_WRITE;
      STATE_WRITE:
        if (write_done) next_state = STATE_CONV;
      STATE_CONV:
        next_state = STATE_CONV_WAIT;
      STATE_CONV_WAIT:
        next_state = STATE_INIT;
     endcase
    end  
  endfunction

// wire write_done;
  assign write_done = (counter == DATA_WIDTH-1);

// state machine, control to write data serially to DAC
  always @(posedge clk, negedge rst_inv)
  if (rst_inv == 1'd0)
    begin
      da_buf <= {DATA_WIDTH{1'b0}};
      da_sdin <= 1'b0;
      current_state <= STATE_INIT;
      da_sync_inv <= 1'd1;
    end
  else
    begin
      current_state <= next_state(current_state, write_done);
      case(current_state)
        STATE_INIT:
          begin
            counter <= 5'd0;
            da_buf <= da_data;
          end
        STATE_WRITE:
          begin
            //enable DAC sync to clock in data serially. Must be enabled here at the same clock rising for data preparing. 
            //If enable it in STATE_INIT, it might be a clock earlier.
            if (counter == 0) da_sync_inv <= 1'd0; 
            //prepare data to be clocked in. DAC uses falling clock edge to read in.
            da_sdin <= da_buf[DATA_WIDTH-1]; 
            da_buf <= da_buf<<1;
            counter <= counter + 5'd1;
          end
        STATE_CONV:
          begin
            da_sync_inv <= 1'd1; //now that write_done, this rising edge updates input register, DAC register, and Vout. 
            da_sdin <= 1'd0;
          end
        STATE_CONV_WAIT: //just wait a clock. It might be not necessary for AD5676R. 
          begin
          end
      endcase
    end
    
endmodule
