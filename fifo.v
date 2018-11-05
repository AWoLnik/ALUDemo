// Adapted by Adam Wolnikowski from:
// https://stackoverflow.com/questions/24027523/first-in-first-out-fifo-using-verilog

module fifo (
  input clock,
  input reset,

  input wr_in,
  input rd_in,
  input [DATA_WIDTH-1:0] din,
  output reg [DATA_WIDTH-1:0] dout,
  output empty,
  output full,

  output reg [DATA_WIDTH-1:0] fifo_cnt
);

// Parameters

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 4;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);

// FIFO logic

reg [DATA_WIDTH-1:0] fifo_ram[0:RAM_DEPTH-1];
reg [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;

assign empty = (fifo_cnt==0);
assign full = (fifo_cnt==8);

reg wr;
reg rd;
reg wr_in_d;
reg rd_in_d;

// edge detection
always @( posedge clock )
begin: edge_detect
  rd_in_d <= rd_in;
  wr_in_d <= wr_in;

  rd = (rd_in && !rd_in_d);
  wr = (wr_in && !wr_in_d);
end

always @( posedge clock )
begin: write
if(wr && !full) fifo_ram[wr_ptr] <= din;
else if(wr && rd) fifo_ram[wr_ptr] <= din;
end

always @( posedge clock )
begin: read
if(rd && !empty)
  dout <= fifo_ram[rd_ptr];
else if(rd && wr && empty)
  dout <= fifo_ram[rd_ptr];
end

always @( posedge clock )
begin: pointer
  if( reset )
  begin
    wr_ptr <= 0;
    rd_ptr <= 0;
  end
  else
  begin
    wr_ptr <= ((wr && !full)||(wr && rd)) ? wr_ptr+1 : wr_ptr;
    rd_ptr <= ((rd && !empty)||(wr && rd)) ? rd_ptr+1 : rd_ptr;
  end
end

always @( posedge clock )
begin: count
  if( reset )
    fifo_cnt <= 0;
  else
  begin
    case ({wr,rd})
      2'b00 : fifo_cnt <= fifo_cnt;
      2'b01 : fifo_cnt <= (fifo_cnt==0) ? 0 : fifo_cnt-1;
      2'b10 : fifo_cnt <= (fifo_cnt==8) ? 8 : fifo_cnt+1;
      2'b11 : fifo_cnt <= fifo_cnt;
      default: fifo_cnt <= fifo_cnt;
    endcase
  end
end


endmodule
