module axi_write (clock_in,
reset_in,
axislave_clock_in,
axislave_awaddr_in,
axislave_awlen_in,
axislave_awvalid_in,
axislave_wvalid_in,
axislave_wdata_in,
axislave_wlast_in,
axislave_wstrb_in,
axislave_awready_out,
axislave_wready_out,
axislave_bresp_out,
axislave_bid_out,
axislave_bvalid_out,
axislave_awburst_in,
axislave_awcache_in,
axislave_awid_in,
axislave_awlock_in,
axislave_awprot_in,
axislave_awqos_in,
axislave_awsize_in,
axislave_bready_in,
aximaster_clock_in,
aximaster_awaddr_out,
aximaster_awlen_out,
aximaster_awvalid_out,
aximaster_wvalid_out,
aximaster_wdata_out,
aximaster_wlast_out,
aximaster_wstrb_out,
aximaster_awready_in,
aximaster_wready_in,
aximaster_bresp_in,
aximaster_bid_in,
aximaster_bvalid_in,
aximaster_awburst_out,
aximaster_awcache_out,
aximaster_awid_out,
aximaster_awlock_out,
aximaster_awprot_out,
aximaster_awqos_out,
aximaster_awsize_out,
aximaster_bready_out);
    
    parameter DATA_WIDTH = 64;
    parameter FIFO_DEPTH = 6;
    parameter FIFO_DATA_DEPTH = 6;
    parameter CCD = 1'b1;
    localparam axiwrite_cmd_len_c = 58;
    localparam axiwrite_data_len_c = DATA_WIDTH+1+DATA_WIDTH/8 ;
    localparam axiwrite_resp_len_c = 3;

    input clock_in, reset_in;
    input axislave_clock_in, aximaster_clock_in;
    input [31:0] axislave_awaddr_in;
    input [7:0] axislave_awlen_in;
    input axislave_awvalid_in, axislave_wvalid_in;
    input [DATA_WIDTH-1:0] axislave_wdata_in;
    input axislave_wlast_in;
    input [DATA_WIDTH/8-1:0] axislave_wstrb_in;
    input [1:0] axislave_awburst_in;
    input [3:0] axislave_awcache_in;
    input [0:0] axislave_awid_in;
    input [0:0] axislave_awlock_in;
    input [2:0] axislave_awprot_in;
    input [3:0] axislave_awqos_in;
    input [2:0] axislave_awsize_in;
    input axislave_bready_in;

    output logic axislave_wready_out, axislave_awready_out;
    output logic [1:0] axislave_bresp_out;
    output logic [0:0] axislave_bid_out;
    output logic axislave_bvalid_out;
    output logic [31:0] aximaster_awaddr_out;
    output logic [7:0] aximaster_awlen_out;
    output logic aximaster_awvalid_out, aximaster_wvalid_out;
    output logic [DATA_WIDTH-1:0] aximaster_wdata_out;
    output logic aximaster_wlast_out;
    output logic [DATA_WIDTH/8-1:0] aximaster_wstrb_out;
    
    input aximaster_wready_in, aximaster_awready_in;
    input [1:0] aximaster_bresp_in;
    input [0:0] aximaster_bid_in;
    input aximaster_bvalid_in;

    output logic [1:0] aximaster_awburst_out;
    output logic [3:0] aximaster_awcache_out;
    output logic [0:0] aximaster_awid_out;
    output logic [0:0] aximaster_awlock_out;
    output logic [2:0] aximaster_awprot_out;
    output logic [3:0] aximaster_awqos_out;
    output logic [2:0] aximaster_awsize_out;
    output logic aximaster_bready_out;

    typedef struct packed {
        logic [31:0] awaddr;
        logic [7:0] awlen;
        logic [1:0] awburst;
        logic [3:0] awcache;
        logic [0:0] awid;
        logic [0:0] awlock;
        logic [2:0] awprot;
        logic [3:0] awqos;
        logic [2:0] awsize;
    } axiwrite_cmd_rec_t;


    typedef logic [axiwrite_cmd_len_c-1:0] axiwrite_cmd_fifo_t;

    typedef struct packed {
        logic [DATA_WIDTH-1:0] wdata;
        logic wlast;
        logic [DATA_WIDTH/8-1:0] wstrb;
    } axiwrite_data_rec_t;


    typedef  logic [axiwrite_data_len_c-1:0] axiwrite_data_fifo_t;

    typedef struct packed {
        logic [1:0] bresp;
        logic [0:0] bid;
    } axiwrite_resp_rec_t;


    typedef logic [axiwrite_resp_len_c-1:0] axiwrite_resp_fifo_t;


    axiwrite_cmd_rec_t axislave_cmd_rec_read;
    axiwrite_cmd_rec_t axislave_cmd_rec_write;
    axiwrite_cmd_fifo_t axislave_cmd_fifo_read;
    axiwrite_cmd_fifo_t axislave_cmd_fifo_write;
    logic axislave_cmd_fifo_full;
    logic axislave_cmd_fifo_empty;
    logic axislave_cmd_fifo_wr;
    logic axislave_cmd_fifo_rd;
    axiwrite_data_rec_t axislave_data_rec_read;
    axiwrite_data_rec_t axislave_data_rec_write;
    axiwrite_data_fifo_t axislave_data_fifo_read;
    axiwrite_data_fifo_t axislave_data_fifo_write;
    logic axislave_data_fifo_full;
    logic axislave_data_fifo_empty;
    logic axislave_data_fifo_wr;
    logic axislave_data_fifo_rd;
    axiwrite_resp_rec_t axislave_resp_rec_read;
    axiwrite_resp_rec_t axislave_resp_rec_write;
    axiwrite_resp_fifo_t axislave_resp_fifo_read;
    axiwrite_resp_fifo_t axislave_resp_fifo_write;
    logic axislave_resp_fifo_full;
    logic axislave_resp_fifo_empty;
    logic axislave_resp_fifo_wr;
    logic axislave_resp_fifo_rd;




    function axiwrite_cmd_fifo_t pack_cmd;
        input axiwrite_cmd_rec_t rec_in;
        begin
            pack_cmd = {rec_in.awaddr, rec_in.awlen, rec_in.awburst, rec_in.awcache, rec_in.awid, rec_in.awlock, rec_in.awprot, rec_in.awqos, rec_in.awsize};
        end
    endfunction


    function axiwrite_cmd_rec_t unpack_cmd;
        input axiwrite_cmd_fifo_t q_in;
        begin
            unpack_cmd.awaddr = q_in[57:26];
            unpack_cmd.awlen = q_in[25:18];
            unpack_cmd.awburst = q_in[17:16];
            unpack_cmd.awcache = q_in[15:12];
            unpack_cmd.awid = q_in[11];
            unpack_cmd.awlock = q_in[10];
            unpack_cmd.awprot = q_in[9:7];
            unpack_cmd.awqos = q_in[6:3];
            unpack_cmd.awsize = q_in[2:0];
        end
    endfunction

    function axiwrite_data_fifo_t pack_data;
        input axiwrite_data_rec_t rec_in;
        begin
            pack_data = {rec_in.wdata, rec_in.wlast, rec_in.wstrb};
        end
    endfunction


    function axiwrite_data_rec_t unpack_data;
        input axiwrite_data_fifo_t q_in;
        begin
            unpack_data.wdata = q_in[72:9];
            unpack_data.wlast = q_in[8];
            unpack_data.wstrb = q_in[7:0];
        end
    endfunction


    function axiwrite_resp_fifo_t pack_resp;
        input axiwrite_resp_rec_t rec_in;
        begin
            pack_resp = {rec_in.bresp, rec_in.bid};
        end
    endfunction


    function axiwrite_resp_rec_t unpack_resp;
        input axiwrite_resp_fifo_t q_in;
        begin
            unpack_resp.bresp = q_in[2:1];
            unpack_resp.bid = q_in[0];
        end
    endfunction



    
assign axislave_awready_out = (! axislave_cmd_fifo_full);
assign axislave_wready_out = (! axislave_data_fifo_full);
assign axislave_bresp_out = axislave_resp_rec_read.bresp;
assign axislave_bid_out = axislave_resp_rec_read.bid;
assign axislave_bvalid_out = ! axislave_resp_fifo_empty;


assign aximaster_awaddr_out = axislave_cmd_rec_read.awaddr;
assign aximaster_awlen_out = axislave_cmd_rec_read.awlen;
assign aximaster_awvalid_out = ! axislave_cmd_fifo_empty;
assign aximaster_wvalid_out = ! axislave_data_fifo_empty;
assign aximaster_wdata_out = axislave_data_rec_read.wdata;
assign aximaster_wlast_out = axislave_data_rec_read.wlast;
assign aximaster_wstrb_out = axislave_data_rec_read.wstrb;
assign aximaster_awburst_out = axislave_cmd_rec_read.awburst;
assign aximaster_awcache_out = axislave_cmd_rec_read.awcache;
assign aximaster_awid_out = axislave_cmd_rec_read.awid;
assign aximaster_awlock_out = axislave_cmd_rec_read.awlock;
assign aximaster_awprot_out = axislave_cmd_rec_read.awprot;
assign aximaster_awqos_out = axislave_cmd_rec_read.awqos;
assign aximaster_awsize_out = axislave_cmd_rec_read.awsize;
assign aximaster_bready_out = ! axislave_resp_fifo_full;

      
assign axislave_cmd_rec_write.awaddr = axislave_awaddr_in;
assign axislave_cmd_rec_write.awlen = axislave_awlen_in;
assign axislave_cmd_rec_write.awburst = axislave_awburst_in;
assign axislave_cmd_rec_write.awcache = axislave_awcache_in;
assign axislave_cmd_rec_write.awid = axislave_awid_in;
assign axislave_cmd_rec_write.awlock = axislave_awlock_in;
assign axislave_cmd_rec_write.awprot = axislave_awprot_in;
assign axislave_cmd_rec_write.awqos = axislave_awqos_in;
assign axislave_cmd_rec_write.awsize = axislave_awsize_in;

       
assign axislave_data_rec_write.wdata = axislave_wdata_in;
assign axislave_data_rec_write.wlast = axislave_wlast_in;
assign axislave_data_rec_write.wstrb = axislave_wstrb_in;


assign axislave_resp_rec_write.bresp = aximaster_bresp_in;
assign axislave_resp_rec_write.bid = aximaster_bid_in;


assign axislave_cmd_fifo_wr = (axislave_awvalid_in) && (! axislave_cmd_fifo_full);
assign axislave_cmd_fifo_rd = (! axislave_cmd_fifo_empty) && (aximaster_awready_in);


assign axislave_data_fifo_wr = (axislave_wvalid_in) && (! axislave_data_fifo_full);
assign axislave_data_fifo_rd = (! axislave_data_fifo_empty) && (aximaster_wready_in);

      
assign axislave_resp_fifo_wr = (aximaster_bvalid_in) && (! axislave_resp_fifo_full);
assign axislave_resp_fifo_rd = (axislave_bready_in) && (! axislave_resp_fifo_empty);


assign axislave_cmd_rec_read = unpack_cmd(axislave_cmd_fifo_read);
assign axislave_cmd_fifo_write = pack_cmd(axislave_cmd_rec_write);

assign axislave_data_rec_read = unpack_data(axislave_data_fifo_read);
assign axislave_data_fifo_write = pack_data(axislave_data_rec_write);

assign axislave_resp_rec_read = unpack_resp(axislave_resp_fifo_read);
assign axislave_resp_fifo_write = pack_resp(axislave_resp_rec_write);



    generate if(CCD) begin
        afifo2 #(.DATA_WIDTH(axiwrite_cmd_len_c), .FIFO_DEPTH(FIFO_DEPTH)) slave_cmd_fifo (.rclock_in(clock_in),
        .wclock_in(axislave_clock_in),
        .reset_in(reset_in),
        .data_in(axislave_cmd_fifo_write),
        .write_in(axislave_cmd_fifo_wr),
        .read_in(axislave_cmd_fifo_rd),
        .q_out(axislave_cmd_fifo_read),
        .empty_out(axislave_cmd_fifo_empty),
        .full_out(axislave_cmd_fifo_full));

        afifo2 #(.DATA_WIDTH(axiwrite_data_len_c), .FIFO_DEPTH(FIFO_DATA_DEPTH)) slave_data_fifo(.rclock_in(clock_in),
        .wclock_in(axislave_clock_in),
        .reset_in(reset_in),
        .data_in(axislave_data_fifo_write),
        .write_in(axislave_data_fifo_wr),
        .read_in(axislave_data_fifo_rd),
        .q_out(axislave_data_fifo_read),
        .empty_out(axislave_data_fifo_empty),
        .full_out(axislave_data_fifo_full));

        afifo2 #(.DATA_WIDTH(axiwrite_resp_len_c), .FIFO_DEPTH(FIFO_DEPTH)) slave_resp_fifo (.rclock_in(axislave_clock_in),
        .wclock_in(clock_in),
        .reset_in(reset_in),
        .data_in(axislave_resp_fifo_write),
        .write_in(axislave_resp_fifo_wr),
        .read_in(axislave_resp_fifo_rd),
        .q_out(axislave_resp_fifo_read),
        .empty_out(axislave_resp_fifo_empty),
        .full_out(axislave_resp_fifo_full));
    end
    else begin
        scfifo #(.DATA_WIDTH(axiwrite_cmd_len_c), .FIFO_DEPTH(FIFO_DEPTH), .LOOKAHEAD(1'b1)) slave_cmd_fifo (.clock_in(clock_in),
        .reset_in(reset_in),
        .data_in(axislave_cmd_fifo_write),
        .write_in(axislave_cmd_fifo_wr),
        .read_in(axislave_cmd_fifo_rd),
        .q_out(axislave_cmd_fifo_read),
        .empty_out(axislave_cmd_fifo_empty),
        .full_out(axislave_cmd_fifo_full),
        .ravail_out(), .wused_out(), .almost_full_out());

        scfifo #(.DATA_WIDTH(axiwrite_data_len_c), .FIFO_DEPTH(FIFO_DATA_DEPTH), .LOOKAHEAD(1'b1)) slave_data_fifo(
        .clock_in(clock_in),
        .reset_in(reset_in),
        .data_in(axislave_data_fifo_write),
        .write_in(axislave_data_fifo_wr),
        .read_in(axislave_data_fifo_rd),
        .q_out(axislave_data_fifo_read),
        .empty_out(axislave_data_fifo_empty),
        .full_out(axislave_data_fifo_full),
        .ravail_out(), .wused_out(), .almost_full_out());

        scfifo #(.DATA_WIDTH(axiwrite_resp_len_c), .FIFO_DEPTH(FIFO_DEPTH), .LOOKAHEAD(1'b1)) slave_resp_fifo (
        .clock_in(clock_in),
        .reset_in(reset_in),
        .data_in(axislave_resp_fifo_write),
        .write_in(axislave_resp_fifo_wr),
        .read_in(axislave_resp_fifo_rd),
        .q_out(axislave_resp_fifo_read),
        .empty_out(axislave_resp_fifo_empty),
        .full_out(axislave_resp_fifo_full),
        .ravail_out(), .wused_out(), .almost_full_out());        
    end
        
    endgenerate








endmodule