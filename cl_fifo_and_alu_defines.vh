// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.

`ifndef CL_fifo_and_alu_DEFINES
`define CL_fifo_and_alu_DEFINES

// Put module name of the CL design here.  This is used to instantiate in top.sv
`define CL_NAME cl_fifo_and_alu

// Highly recommeneded.  For lib FIFO block, uses less async reset (take advantage of
// FPGA flop init capability).  This will help with routing resources.
`define FPGA_LESS_RST

// Register addresses used by the CL.
// Note, registers are byte addressable, and data is 4 bytes, so each 
// address is a multiple of 4
`define ALU_ONE_ADDR              32'h0000_0510
`define ALU_TWO_ADDR              32'h0000_0514

// Uncomment to disable Virtual JTAG
`define DISABLE_VJTAG_DEBUG

`endif
