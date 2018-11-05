#
# Copyright (C) 2018
# Author: Adam Wolnikowski <adam.wolnikowski@yale.edu>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SHELL := /bin/bash

all: run

axi_fifo_alu_tb: ../axi4lite_to_fifos.v ../fifo.v ../alu.v axi_fifo_alu_tb.v
	iverilog -Wall -Wno-timescale -o axi_fifo_alu_tb $^ -I ../

run: axi_fifo_alu_tb
	./axi_fifo_alu_tb

clean:
	rm -f axi_fifo_alu_tb axi_fifo_alu_tb.vcd
