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

`include "cl_fifo_and_alu_defines.vh"
`timescale 1ns / 1ps

module axi_fifo_alu_tb;

localparam DATA_WIDTH = 32;

// AXI Inputs
reg clk = 1'b0;
reg rst = 1'b1; // reset is active low, so 1 means not resetting

reg awvalid = 1'b0;
reg [DATA_WIDTH-1:0] awaddr = 32'h0000_0000;
reg wvalid = 1'b0;
reg [DATA_WIDTH-1:0] wdata = 32'h0000_0000;
reg [3:0] wstrb = 4'b0000;
reg bready = 1'b0;
reg arvalid = 1'b0;
reg [DATA_WIDTH-1:0] araddr = 32'h0000_0000;
reg rready = 1'b0;

// AXI Outputs
wire awready;
wire wready;
wire bvalid;
wire [1:0] bresp;
wire arready;
wire rvalid;
wire [DATA_WIDTH-1:0] rdata;
wire [1:0] rresp;

// axi/fifo connections
wire fin_wr;
wire [DATA_WIDTH-1:0] fin_din;
wire fin_full;

wire fout_rd;
wire [DATA_WIDTH-1:0] fout_dout;
wire fout_empty;

axi4lite_to_fifos axi (
    .clk_main_a0(clk),
    .rst_main_n_sync(rst),
    .awvalid(awvalid),
    .awaddr(awaddr),
    .wvalid(wvalid),
    .wdata(wdata),
    .wstrb(wstrb),
    .bready(bready),
    .arvalid(arvalid),
    .araddr(araddr),
    .rready(rready),
    .awready(awready),
    .wready(wready),
    .bvalid(bvalid),
    .bresp(bresp),
    .arready(arready),
    .rvalid(rvalid),
    .rdata(rdata),
    .rresp(rresp),
    .fifo_cl_to_alu_wr(fin_wr),
    .fifo_cl_to_alu_din(fin_din),
    .fifo_cl_to_alu_full(fin_full),
    .fifo_alu_to_cl_rd(fout_rd),
    .fifo_alu_to_cl_dout(fout_dout),
    .fifo_alu_to_cl_empty(fout_empty)
  );

//alu/fifo connections
wire fin_rd;
wire [DATA_WIDTH-1:0] fin_dout;
wire fin_empty;

wire fout_wr;
wire [DATA_WIDTH-1:0] fout_din;
wire fout_full;

wire [DATA_WIDTH-1:0] fin_cnt;
wire [DATA_WIDTH-1:0] fout_cnt;

fifo fifo_in (
    .clock(clk),
    .reset(~rst),
    .wr_in(fin_wr), // from axi
    .rd_in(fin_rd), // from alu
    .din(fin_din), // from axi
    .dout(fin_dout), // to alu
    .empty(fin_empty), // to alu
    .full(fin_full), // to axi
    .fifo_cnt(fin_cnt)
  );

fifo fifo_out (
    .clock(clk),
    .reset(~rst),
    .wr_in(fout_wr), // from alu
    .rd_in(fout_rd), // from axi
    .din(fout_din), // from alu
    .dout(fout_dout), // to axi
    .empty(fout_empty), // to axi
    .full(fout_full), // to alu
    .fifo_cnt(fout_cnt)
  );

alu alu (
    .clock(clk),
    .reset_n(rst),
    .empty(fin_empty),
    .rd(fin_rd),
    .din(fin_dout),
    .full(fout_full),
    .wr(fout_wr),
    .dout(fout_din)
  );

// write out signals to waveform
initial
  begin
    $dumpfile("axi_fifo_alu_tb.vcd");
    $dumpvars(0, axi_fifo_alu_tb);
  end

// main simulation process
initial
  begin
    # 25;
    rst <= 0;
    # 25;
    rst <= 1;
    # 25
    $display("\nWriting Opcode: 1 (Mul)",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0001;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg1: 2",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0002;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg2: 3",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0003;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg3: 0",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0000;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Opcode: 2 (Mul-Add)",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0002;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg1: 2",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0002;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg2: 3",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0003;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    $display("\nWriting Arg3: 4",);
    awaddr <= `ALU_ONE_ADDR;
    awvalid <= 1;
    wdata <= 32'h0000_0004;
    wvalid <= 1;
    wstrb <= 4'b0001;
    bready <= 1;
    @(negedge bvalid);
    awaddr <= 32'h0000_0000;
    awvalid <= 0;
    wdata <= 32'h0000_0000;
    wvalid <= 0;
    wstrb <= 4'b0000;
    bready <= 0;

    # 25
    araddr <= `ALU_ONE_ADDR;
    arvalid <= 1;
    rready <= 1;
    @(posedge rvalid);
    $display("\nReading result 1: %0d", rdata);
    @(negedge rvalid);
    araddr <= `ALU_ONE_ADDR;
    arvalid <= 1;
    rready <= 1;
    @(posedge rvalid);
    $display("\nReading result 2: %0d", rdata);
    @(negedge rvalid);
    araddr <= 32'h0000_0000;
    arvalid <= 0;
    rready <= 0;

    $fflush();
    # 25;
    $display("\nSIMULATION FINISHED\n");
    $fflush();
    $finish;
  end

// toggle the clock
always
  # 5 clk = !clk;

endmodule
