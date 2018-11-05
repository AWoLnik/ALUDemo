/*
 * Copyright (C) 2018
 * Author: Adam Wolnikowski <adam.wolnikowski@yale.edu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
*/

module alu(
    input wire clock,
    input wire reset_n,

    input wire                  empty,
    output reg                  rd,
    input [DATA_WIDTH-1:0]      din,

    input wire                  full,
    output reg                  wr,
    output reg [DATA_WIDTH-1:0] dout
);

// Parameters

parameter DATA_WIDTH = 32;

// ALU logic

localparam START = 0,
           SEND_READ = 1,
           GET_READ = 2,
           SAVE_OPCODE = 3,
           SAVE_ARG1 = 4,
           SAVE_ARG2 = 5,
           SAVE_ARG3 = 6,
           COMPUTE = 7,
           WRITE_RESULT = 8,
           NUM_STATES = 9;

//reg [$clog2(NUM_STATES)-1:0] state;
reg [3:0] state;
reg [3:0] ret_state;
reg [3:0] prev_state;

localparam OP_ADD = 0,
	   OP_MUL = 1,
     OP_MUL_ADD = 2,
	   NUM_OPCODES = 3;

reg [2:0] opcode;
reg [DATA_WIDTH-1:0] arg1;
reg [DATA_WIDTH-1:0] arg2;
reg [DATA_WIDTH-1:0] arg3;
reg [DATA_WIDTH-1:0] result;

always @(posedge clock) begin
  if (!reset_n) begin
    // reset all registers when the system starts
    state <= START;
    ret_state <= START;
    rd <= 0;
    wr <= 0;
    dout <= 0;
    opcode <= 0;
    arg1 <= 0;
    arg2 <= 0;
    arg3 <= 0;
    result <= 0;
  end
  else begin
    // default assignment of register values
    // if not affected by the case statement
    state <= state;
    ret_state <= ret_state;
    prev_state <= state;
    rd <= 0;
    wr <= 0;
    dout <= 0;
    opcode <= opcode;
    arg1 <= arg1;
    arg2 <= arg2;
    arg3 <= arg3;
    result <= result;

    // main state machine
    // how can you simplify it? =)
    case (state)

      START: begin
        state <= SEND_READ;
        ret_state <= SAVE_OPCODE;
      end

      SEND_READ: begin
        if (!empty) begin
          rd <= 1;
          state <= GET_READ;
        end
        else begin
          rd <= 0;
          state <= SEND_READ;
        end
      end

      GET_READ: begin
          state <= ret_state;
      end

      SAVE_OPCODE: begin
        opcode <= din;
        state <= SEND_READ;
        ret_state <= SAVE_ARG1;
      end

      SAVE_ARG1: begin
        arg1 <= din;
        state <= SEND_READ;
        ret_state <= SAVE_ARG2;
      end

      SAVE_ARG2: begin
        arg2 <= din;
        state <= SEND_READ;
        ret_state <= SAVE_ARG3;
      end

      SAVE_ARG3: begin
        arg3 <= din;
        state <= COMPUTE;
      end

      COMPUTE: begin
        case (opcode)
          OP_ADD: begin
            result <= arg1 + arg2;
          end

          OP_MUL: begin
            result <= arg1 * arg2;
          end

          OP_MUL_ADD: begin
            result <= (arg1 * arg2) + arg3;
          end

          // default : $display("Error in opcode case statement.");
        endcase
	state <= WRITE_RESULT;
      end

      WRITE_RESULT: begin
        if (!full) begin
	        wr <= 1;
          dout <= result;
          state <= START;
        end
        else begin
          dout <= 0;
          state <= WRITE_RESULT;
        end
      end

      //default: begin
      //  $display("Error in alu state machine case statement");
      //  $display("Got state %d, ret_state %d, prev_state %d", state, ret_state, prev_state);
      //end
    endcase

  end

end

endmodule
