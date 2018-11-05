/*
 * Copyright (C) 2018
 * Revised by Adam Wolnikowski
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
*/

`include "cl_fifo_and_alu_defines.vh" // to get define for ALU_ONE_ADDR

module axi4lite_to_fifos (
    input wire clk_main_a0,
    input wire rst_main_n_sync,

    // inputs to AXI-Lite slave
    input wire        awvalid,
    input wire [DATA_WIDTH-1:0] awaddr,
    input wire        wvalid,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [3:0]  wstrb,
    input wire        bready,
    input wire        arvalid,
    input wire [DATA_WIDTH-1:0] araddr,
    input wire        rready,

    // outputs from AXI-Lite slave
    output wire       awready,
    output wire       wready,
    output reg        bvalid,
    output wire [1:0] bresp,
    output wire       arready, // unexpectedly becomes one in the middle of read
    output reg        rvalid,
    output reg [DATA_WIDTH-1:0] rdata,
    output reg [1:0]  rresp,

    // connections to CL-to-ALU FIFO
    // (only writing to this FIFO, ALU does the reading)
    output reg fifo_cl_to_alu_wr,
    output reg [DATA_WIDTH-1:0] fifo_cl_to_alu_din,
    input wire fifo_cl_to_alu_full,

    // connections to ALU-to-CL FIFO
    // (only reading form this FIFO, ALU does the writing)
    output reg fifo_alu_to_cl_rd,
    input wire [DATA_WIDTH-1:0] fifo_alu_to_cl_dout,
    input wire fifo_alu_to_cl_empty
);

parameter DATA_WIDTH = 32;

// CL is a slave device, only responds to write and read requests from master
// cannot generate its own requestes.

// Write Request
reg        wr_active;
reg [31:0] wr_addr;

always @(posedge clk_main_a0)
  if (!rst_main_n_sync) begin
    wr_active <= 0;
    wr_addr   <= 0;
  end
  else begin
    wr_active <=  wr_active && bvalid  && bready ? 1'b0     :
                  ~wr_active && awvalid          ? 1'b1     :
                                                 wr_active  ;
    wr_addr <= awvalid && ~wr_active ? awaddr : wr_addr     ;
  end

assign awready = ~wr_active;
assign wready  =  wr_active && wvalid && !fifo_cl_to_alu_full;

// Write Response
always @(posedge clk_main_a0)
  if (!rst_main_n_sync)
    bvalid <= 0;
  else
    bvalid <=  bvalid &&  bready ? 1'b0  :
              ~bvalid &&  wready ? 1'b1  :
                                   bvalid;
assign bresp = 0;

// Read Request
reg        arvalid_q;
reg [31:0] araddr_q;

always @(posedge clk_main_a0)
  if (!rst_main_n_sync) begin
    arvalid_q <= 0;
    araddr_q  <= 0;
  end
  else begin
    arvalid_q <= arvalid;
    araddr_q  <= arvalid ? araddr : araddr_q;
  end

assign arready = !arvalid_q && !rvalid && !fifo_alu_to_cl_empty;


// Write to FIFO logic
always @(posedge clk_main_a0) begin

  if (!rst_main_n_sync) begin
    fifo_cl_to_alu_wr <= 0;
    fifo_cl_to_alu_din <= 0;
  end
  else if (wready & (wr_addr == `ALU_ONE_ADDR) & !fifo_cl_to_alu_full) begin
    fifo_cl_to_alu_wr <= 1;
    fifo_cl_to_alu_din <= wdata;
  end
  else begin
    fifo_cl_to_alu_wr <= 0;
    fifo_cl_to_alu_din <= 0;
  end
end

// Read from FIFO logic
localparam WAIT       = 0,
           IDLE       = 1,
           READ_FIFO  = 2,
           NUM_STATES = 3;

reg [1:0] state;

always @(posedge clk_main_a0) begin

  if (!rst_main_n_sync) begin
    rvalid <= 0;
    rdata  <= 0;
    rresp  <= 0;
    fifo_alu_to_cl_rd <= 0;
    state <= IDLE;  // Initial state is IDLE
  end
  else begin
    case(state)
      WAIT: begin
        rvalid <= 0;
        rdata  <= 0;
        rresp  <= 0;
        fifo_alu_to_cl_rd <= 0;
        state <= READ_FIFO;
      end

      IDLE: begin
        if (rvalid && rready) begin
          rvalid <= 0;
          rdata  <= 0;
          rresp  <= 0;
          fifo_alu_to_cl_rd <= 0;
          state <= IDLE;
        end
        else if (arvalid_q && (araddr_q == `ALU_ONE_ADDR) && !fifo_alu_to_cl_empty) begin
          rvalid <= 0;
          rdata  <= 0;
          rresp  <= 0;
          fifo_alu_to_cl_rd <= 1;
          state <= WAIT; //fifo requires 2 cycles to get data
        end
      end

      READ_FIFO: begin
        rvalid <= 1;
        rdata <= fifo_alu_to_cl_dout;
        rresp  <= 0;
        fifo_alu_to_cl_rd <= 0;
        state <= IDLE;
      end

    endcase
  end
end

endmodule
