module axi_read (clock_in, reset_in, axislave_clock_in, axislave_araddr_in, axislave_arlen_in, axislave_arvalid_in, 
axislave_arid_in, axislave_arlock_in, axislave_arcache_in, axislave_arprot_in, axislave_arqos_in, axislave_rid_out, 
axislave_rvalid_out, axislave_rlast_out, axislave_rdata_out, axislave_rresp_out, axislave_arready_out, axislave_rready_in, 
axislave_arburst_in, axislave_arsize_in, aximaster_clock_in, aximaster_araddr_out, aximaster_arlen_out, 
aximaster_arvalid_out, aximaster_arid_out, aximaster_arlock_out, aximaster_arcache_out, aximaster_arprot_out, 
aximaster_arqos_out, aximaster_rid_in, aximaster_rvalid_in, aximaster_rlast_in, aximaster_rdata_in, aximaster_rresp_in, 
aximaster_arready_in, aximaster_rready_out, aximaster_arburst_out, aximaster_arsize_out);

parameter DATA_WIDTH = 64;
parameter FIFO_DEPTH = 6;
parameter FIFO_DATA_DEPTH = 6;
parameter CCD = 1'b1;
localparam axiread_cmd_fifo_length_c = 58;
localparam axiread_resp_fifo_length_c = 68;
typedef logic [axiread_cmd_fifo_length_c-1:0] axiread_cmd_fifo_t;
typedef logic [axiread_resp_fifo_length_c-1:0] axiread_resp_fifo_t;


input wire clock_in, reset_in, axislave_clock_in, aximaster_clock_in, axislave_arvalid_in, axislave_rready_in, aximaster_rvalid_in, aximaster_rlast_in, aximaster_arready_in;
input wire [0:0] axislave_arid_in, axislave_arlock_in, aximaster_rid_in;
input wire [DATA_WIDTH-1:0] aximaster_rdata_in;
input wire[31:0] axislave_araddr_in;
input wire [7:0] axislave_arlen_in;
input wire [3:0] axislave_arcache_in, axislave_arqos_in;
input wire [2:0] axislave_arprot_in, axislave_arsize_in;
input wire [1:0] axislave_arburst_in, aximaster_rresp_in;



output wire [DATA_WIDTH-1:0] axislave_rdata_out;
output wire [0:0] axislave_rid_out, aximaster_arid_out, aximaster_arlock_out;
output wire axislave_rvalid_out, axislave_rlast_out, axislave_arready_out, aximaster_arvalid_out, aximaster_rready_out;
output wire [1:0] axislave_rresp_out, aximaster_arburst_out;
output wire [31:0] aximaster_araddr_out;
output wire [7:0] aximaster_arlen_out;
output wire [3:0] aximaster_arcache_out, aximaster_arqos_out;
output wire [2:0] aximaster_arprot_out, aximaster_arsize_out;


typedef struct packed{
	logic [31:0] araddr;
	logic [7:0] arlen;
    logic [0:0] arid, arlock;
    logic [3:0] arcache, arqos;
    logic [2:0] arprot, arsize;
    logic [1:0] arburst;
} axiread_cmd_rec_t;



typedef struct packed{
	logic rlast;
    logic [0:0] rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
} axiread_resp_rec_t;


axiread_cmd_rec_t axislave_cmd_rec_read;
axiread_cmd_rec_t axislave_cmd_rec_write;

axiread_cmd_fifo_t axislave_cmd_fifo_read;
axiread_cmd_fifo_t axislave_cmd_fifo_write;


logic axislave_cmd_fifo_full, axislave_cmd_fifo_empty, axislave_cmd_fifo_wr, axislave_cmd_fifo_rd;

axiread_resp_rec_t axislave_resp_rec_read, axislave_resp_rec_write;
axiread_resp_fifo_t axislave_resp_fifo_read, axislave_resp_fifo_write;

logic axislave_resp_fifo_full, axislave_resp_fifo_empty, axislave_resp_fifo_wr, axislave_resp_fifo_rd;

logic [0:0] aximaster_rid_r;
logic aximaster_rvalid_r, aximaster_rlast_r;
logic [DATA_WIDTH-1:0] aximaster_rdata_r;
logic [1:0] aximaster_rresp_r;
logic aximaster_rready;


function axiread_cmd_fifo_t pack_cmd;
    input axiread_cmd_rec_t rec_in;
    //output axiread_cmd_fifo_t q_v;
    begin
        pack_cmd = {rec_in.araddr, rec_in.arlen, rec_in.arid, rec_in.arlock, rec_in.arcache, rec_in.arqos, rec_in.arprot, rec_in.arsize, rec_in.arburst };
    end
endfunction


function axiread_cmd_rec_t unpack_cmd;
    input axiread_cmd_fifo_t q_in;
    //output axiread_cmd_rec_t rec_v;
    begin
        unpack_cmd.araddr = q_in[57:26];
        unpack_cmd.arlen = q_in[25:18];
        unpack_cmd.arid = q_in[17];
        unpack_cmd.arlock = q_in[16];
        unpack_cmd.arcache = q_in[15:12];
        unpack_cmd.arqos = q_in[11:8];
        unpack_cmd.arprot = q_in[7:5];
        unpack_cmd.arsize = q_in[4:2];
        unpack_cmd.arburst = q_in[1:0];
    end
endfunction


function axiread_resp_fifo_t pack_resp;
    input axiread_resp_rec_t rec_in;
    begin
        pack_resp = {rec_in.rlast, rec_in.rid, rec_in.rdata, rec_in.rresp};
    end
endfunction

function axiread_resp_rec_t unpack_resp;
    input axiread_resp_fifo_t q_in;
    begin
        unpack_resp.rlast = q_in[67];
        unpack_resp.rid = q_in[66];
        unpack_resp.rdata = q_in[65:2];
        unpack_resp.rresp = q_in[1:0];
    end
endfunction


assign axislave_rvalid_out = !axislave_resp_fifo_empty;
assign axislave_rid_out = axislave_resp_rec_read.rid;
assign axislave_rlast_out = axislave_resp_rec_read.rlast;
assign axislave_rdata_out = axislave_resp_rec_read.rdata;
assign axislave_rresp_out = axislave_resp_rec_read.rresp;
assign axislave_arready_out = !axislave_cmd_fifo_full;

assign aximaster_araddr_out  = axislave_cmd_rec_read.araddr;
assign aximaster_arlen_out   = axislave_cmd_rec_read.arlen;
assign aximaster_arvalid_out = !axislave_cmd_fifo_empty;
assign aximaster_rready_out  = aximaster_rready;
assign aximaster_arid_out    = axislave_cmd_rec_read.arid;
assign aximaster_arlock_out  = axislave_cmd_rec_read.arlock;
assign aximaster_arcache_out = axislave_cmd_rec_read.arcache;
assign aximaster_arprot_out  = axislave_cmd_rec_read.arprot;
assign aximaster_arqos_out   = axislave_cmd_rec_read.arqos;
assign aximaster_arburst_out = axislave_cmd_rec_read.arburst;
assign aximaster_arsize_out  = axislave_cmd_rec_read.arsize;

assign axislave_cmd_rec_write.araddr  = axislave_araddr_in;
assign axislave_cmd_rec_write.arlen   = axislave_arlen_in;
assign axislave_cmd_rec_write.arid    = axislave_arid_in;
assign axislave_cmd_rec_write.arlock  = axislave_arlock_in;
assign axislave_cmd_rec_write.arcache = axislave_arcache_in;
assign axislave_cmd_rec_write.arprot  = axislave_arprot_in;
assign axislave_cmd_rec_write.arqos   = axislave_arqos_in;
assign axislave_cmd_rec_write.arburst = axislave_arburst_in;
assign axislave_cmd_rec_write.arsize  = axislave_arsize_in;

assign axislave_resp_rec_write.rid   = aximaster_rid_r;
assign axislave_resp_rec_write.rlast = aximaster_rlast_r;
assign axislave_resp_rec_write.rdata = aximaster_rdata_r;
assign axislave_resp_rec_write.rresp = aximaster_rresp_r;

assign axislave_cmd_fifo_wr = axislave_arvalid_in & !axislave_cmd_fifo_full;
assign axislave_cmd_fifo_rd = aximaster_arready_in & !axislave_cmd_fifo_empty;

assign axislave_resp_fifo_wr = aximaster_rvalid_r & !axislave_resp_fifo_full;
assign axislave_resp_fifo_rd = axislave_rready_in & !axislave_resp_fifo_empty;

assign axislave_cmd_rec_read = unpack_cmd(axislave_cmd_fifo_read);
assign axislave_cmd_fifo_write = pack_cmd(axislave_cmd_rec_write);

assign axislave_resp_rec_read = unpack_resp(axislave_resp_fifo_read);
assign axislave_resp_fifo_write = pack_resp(axislave_resp_rec_write);

generate if (CCD) begin
   afifo2 #(.DATA_WIDTH(axiread_cmd_fifo_length_c), .FIFO_DEPTH(FIFO_DEPTH)) slave_cmd_fifo(.rclock_in(clock_in),
   .wclock_in(axislave_clock_in), .reset_in(reset_in), .data_in(axislave_cmd_fifo_write), .write_in(axislave_cmd_fifo_wr),
   .read_in(axislave_cmd_fifo_rd), .q_out(axislave_cmd_fifo_read), .empty_out(axislave_cmd_fifo_empty),
   .full_out(axislave_cmd_fifo_full));

   afifo2 #(.DATA_WIDTH(axiread_resp_fifo_length_c), .FIFO_DEPTH(FIFO_DATA_DEPTH)) slave_resp_fifo (.rclock_in(axislave_clock_in),
   .wclock_in(clock_in), .reset_in(reset_in), .data_in(axislave_resp_fifo_write), .write_in(axislave_resp_fifo_wr),
   .read_in(axislave_resp_fifo_rd), .q_out(axislave_resp_fifo_read), .empty_out(axislave_resp_fifo_empty),
   .full_out(axislave_resp_fifo_full));
end
else begin
    scfifo #(.DATA_WIDTH(axiread_cmd_fifo_length_c),.FIFO_DEPTH(FIFO_DEPTH), .LOOKAHEAD(1)) slave_cmd_fifo(.clock_in(clock_in),
    .reset_in(reset_in), .data_in(axislave_cmd_fifo_write), .write_in(axislave_cmd_fifo_wr),
   .read_in(axislave_cmd_fifo_rd), .q_out(axislave_cmd_fifo_read), .empty_out(axislave_cmd_fifo_empty),
   .full_out(axislave_cmd_fifo_full), .ravail_out(), .wused_out(), .almost_full_out());

   scfifo #(.DATA_WIDTH(axiread_resp_fifo_length_c), .FIFO_DEPTH(FIFO_DATA_DEPTH), .LOOKAHEAD(1)) slave_resp_fifo (
   .clock_in(clock_in), .reset_in(reset_in), .data_in(axislave_resp_fifo_write), .write_in(axislave_resp_fifo_wr),
   .read_in(axislave_resp_fifo_rd), .q_out(axislave_resp_fifo_read), .empty_out(axislave_resp_fifo_empty),
   .full_out(axislave_resp_fifo_full), .ravail_out(), .wused_out(), .almost_full_out());

end

endgenerate

assign aximaster_rready = (!aximaster_rvalid_r||!axislave_resp_fifo_full) ? 1'b1 : 1'b0;

always @(posedge aximaster_clock_in or negedge reset_in) begin
    if(!reset_in) begin
      aximaster_rid_r <= 0;
      aximaster_rvalid_r <= 0;
      aximaster_rlast_r <= 0;
      aximaster_rdata_r <= 0;
      aximaster_rresp_r <= 0;
    end
    else begin
        if(aximaster_rready) begin
            aximaster_rid_r <= aximaster_rid_in;
            aximaster_rvalid_r <= aximaster_rvalid_in;
            aximaster_rlast_r <= aximaster_rlast_in;
            aximaster_rdata_r <= aximaster_rdata_in;
            aximaster_rresp_r <= aximaster_rresp_in;
        end
    end
end

endmodule //axi_read