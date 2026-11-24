module mem64 (SDRAM_clk, SDRAM_reset, SDRAM_araddr, SDRAM_arburst, SDRAM_arlen, SDRAM_arready, SDRAM_arsize,
SDRAM_arvalid, SDRAM_awaddr, SDRAM_awburst, SDRAM_awlen, SDRAM_awready, SDRAM_awsize, SDRAM_awvalid, SDRAM_bready,
SDRAM_bresp, SDRAM_bvalid, SDRAM_rdata, SDRAM_rlast, SDRAM_rready, SDRAM_rresp, SDRAM_rvalid, SDRAM_wdata, SDRAM_wlast,
SDRAM_wready, SDRAM_wstrb, SDRAM_wvalid);
//parameters declaration
parameter RAM_BYTE_WIDTH = 8;
parameter RAM_SIZE = 16000;
//defined types
typedef logic [RAM_BYTE_WIDTH*8-1:0] RamType [0:RAM_SIZE];
//ports direction definition
input SDRAM_clk, SDRAM_reset, SDRAM_arvalid, SDRAM_awvalid, SDRAM_bready, SDRAM_rready, SDRAM_wlast, SDRAM_wvalid;
input [31:0] SDRAM_araddr, SDRAM_awaddr;
input [1:0] SDRAM_arburst, SDRAM_awburst;
input [7:0] SDRAM_arlen, SDRAM_awlen, SDRAM_wstrb;
input [2:0] SDRAM_arsize, SDRAM_awsize;
input [63:0] SDRAM_wdata;

output SDRAM_arready, SDRAM_awready, SDRAM_bvalid, SDRAM_rlast, SDRAM_rvalid, SDRAM_wready;
output [1:0] SDRAM_bresp, SDRAM_rresp;
output [63:0] SDRAM_rdata;
//internal signals definition
logic [31:0] araddr;
logic [1:0] arburst;
logic [7:0] arlen;
logic arready;
logic [2:0] arsize;
logic arvalid;
logic [31:0] awaddr;
logic [1:0] awburst;
logic [7:0] awlen;
logic awready;
logic [2:0] awsize;
logic awvalid;
logic bready;
logic [1:0] bresp;
logic bvalid;
logic [63:0] rdata;
logic rlast;
logic rready =1;
logic [1:0] rresp;
logic rvalid;
logic [63:0] wdata;
logic wlast;
logic wready;
logic [7:0] wstrb;
logic wvalid;
logic [31:0] read_addr_r;
logic [7:0] read_len_r;
logic [2:0] read_size_r;
logic read_busy_r=0;
logic [31:0] write_addr_r;
logic [7:0] write_len_r;
logic [2:0] write_size_r;
logic write_busy_r=0;
RamType RAM;
//-----------------------------------------------------------------------//
initial 
RAM = ram_v("mem_trial.mem");

axi_read axi_read_inst(.clock_in(SDRAM_clk),.reset_in(SDRAM_reset),.axislave_clock_in(SDRAM_clk),.axislave_araddr_in(SDRAM_araddr),
.axislave_arlen_in(SDRAM_arlen),.axislave_arvalid_in(SDRAM_arvalid),.axislave_arid_in(0),.axislave_arlock_in(0),.axislave_arcache_in(0),
.axislave_arprot_in(0),.axislave_arqos_in(0),.axislave_rid_out(),.axislave_rvalid_out(SDRAM_rvalid),.axislave_rlast_out(SDRAM_rlast),
.axislave_rdata_out(SDRAM_rdata),.axislave_rresp_out(SDRAM_rresp),.axislave_arready_out(SDRAM_arready),.axislave_rready_in(SDRAM_rready),
.axislave_arburst_in(SDRAM_arburst),.axislave_arsize_in(SDRAM_arsize), .aximaster_clock_in(SDRAM_clk),.aximaster_araddr_out(araddr),
.aximaster_arlen_out(arlen),.aximaster_arvalid_out(arvalid),.aximaster_arid_out(),.aximaster_arlock_out(),.aximaster_arcache_out(),
.aximaster_arprot_out(),.aximaster_arqos_out(),.aximaster_rid_in(0),.aximaster_rvalid_in(rvalid),.aximaster_rlast_in(rlast),
.aximaster_rdata_in(rdata),.aximaster_rresp_in(rresp),.aximaster_arready_in(arready),.aximaster_rready_out(rready),
.aximaster_arburst_out(arburst),.aximaster_arsize_out(arsize));


axi_write  axi_write_inst (SDRAM_clk, SDRAM_reset, SDRAM_clk,
SDRAM_awaddr, SDRAM_awlen, SDRAM_awvalid, SDRAM_wvalid, SDRAM_wdata, SDRAM_wlast, SDRAM_wstrb, SDRAM_awready,
SDRAM_wready, SDRAM_bresp, , SDRAM_bvalid, SDRAM_awburst, 0,
0, 0, 0, 0, SDRAM_awsize, SDRAM_bready, SDRAM_clk, awaddr, awlen, awvalid, wvalid, wdata, wlast, wstrb, awready,
wready, bresp, 0, bvalid, awburst, , , , , , awsize, bready);
//-----------------------------------------------------------------------//
always_comb begin 
    if(read_busy_r==0||(read_busy_r&&rready&&read_len_r==0)) begin
        arready = 1;
    end
    else begin
        arready = 0;
    end
end

assign rvalid = read_busy_r;

always_comb begin 
    if(read_busy_r&&read_len_r==0) begin
        rlast = 1;
    end
    else begin
        rlast = 0;
    end
end

assign rresp = 0;

always_comb begin 
    if(write_busy_r==0||(write_busy_r==1&&wready&&wvalid&&write_len_r==0)) begin
        awready = 1;
    end
    else begin
        awready = 0;
    end
end


assign wready = write_busy_r && bready;

always_comb begin 
    if(wready&&wvalid&&write_len_r==0) begin
        bvalid = 1;
    end
    else begin
        bvalid = 0;
    end
end

assign bresp = 0;

always_comb begin
    if(read_size_r == 3) begin
        rdata = RAM[read_addr_r/8];
    end
    else begin
        if(read_addr_r[2]) begin
            rdata[31:0] = RAM[read_addr_r/8] [63:32];
            rdata[63:32] = RAM[read_addr_r/8] [63:32];
        end
        else begin
            rdata[31:0] = RAM[read_addr_r/8] [31:0];
            rdata[63:32] = RAM[read_addr_r/8] [31:0];            
        end
    end
end


always@(posedge SDRAM_clk or negedge SDRAM_reset) begin
    if(!SDRAM_reset) begin
        read_addr_r<=0;
        read_len_r<=0;
        read_size_r<=0;
        read_busy_r<=0;
        write_addr_r<=0;
        write_len_r<=0;
        write_size_r<=0;
        write_busy_r<=0;
    end
    else begin
        if(read_busy_r) begin
            if(rready) begin
                if(read_len_r==0) begin
                    read_addr_r<=araddr;
                    read_len_r<=arlen;
                    read_size_r<=arsize;
                    read_busy_r<=arvalid;
                end
                else begin
                    if(read_size_r==3) begin
                        read_addr_r<=read_addr_r+8;
                        read_len_r<=read_len_r-1;
                    end
                    else begin
                        read_addr_r<=read_addr_r+4;
                        read_len_r<=read_len_r-1;
                    end
                end
            end
        end
        else begin
            read_addr_r<=araddr;
            read_len_r<=arlen;
            read_size_r<=arsize;
            read_busy_r<=arvalid;
        end
        if(write_busy_r) begin
            if(wready&&wvalid) begin
                if(write_len_r==0) begin
                    write_addr_r<=awaddr;
                    write_len_r<=awlen;
                    write_size_r<=awsize;
                    write_busy_r<=awvalid;
                end
                else begin
                    if(write_size_r==3) begin
                        write_addr_r<=write_addr_r+8;
                        write_len_r<=write_len_r-1;
                    end
                    else begin
                        write_addr_r<=write_addr_r+4;
                        write_len_r<=write_len_r-1;                       
                    end
                end
                if(write_size_r==3) begin
                    for(integer k=0; k<RAM_BYTE_WIDTH; k=k+1)begin
                        if(wstrb[k]) begin
                            RAM[write_addr_r/8][8*k+:8]<=wdata[8*k+:8];
                        end
                    end
                end
                else begin
                    if(write_addr_r[2]==0) begin
                        for (integer k = 0;k<4 ;k=k+1 ) begin
                            if(wstrb[k]==1) begin
                                RAM[write_addr_r/8][8*k+:8]<=wdata[8*k+:8];
                            end
                        end
                    end
                    else begin
                        for (integer k =0 ;k<4 ; k=k+1) begin
                            if(wstrb[4+k]) begin
                                RAM[write_addr_r/8][8*(k+4)+:8]<=wdata[8*(k+4)+:8];
                            end
                        end
                    end
                end
            end
        end
        else begin
            write_addr_r<=awaddr;
            write_len_r<=awlen;
            write_size_r<=awsize;
            write_busy_r<=awvalid;
        end
    end
end


//function for intializing the simulation ram
    function RamType ram_v;
    //ports
    input string RamFileName;
    //variables
    int fd, line_hex;
    string line;
    //signals
    int curraddr_v, baseaddr_v, wordpos_v, bytepos_v;
    byte SC_v;
    logic [7:0] LEN_v, TYPE_v, DATA_v, CHECKSUM_v;
    logic [15:0] ADDR_v, baddr16_v;
    logic [31:0] baddr32_v;
    begin
        baseaddr_v = 0;
        for(integer  i=0;i<=RAM_SIZE; i=i+1)begin//initializing ram
            ram_v[i] = 0;
        end
        fd = $fopen (RamFileName, "r");
        while (!$feof(fd)) begin
            $fgets(line, fd);
            LEN_v = str_2_hex (line, 1,2);
            ADDR_v = str_2_hex(line, 3,6);
            TYPE_v = str_2_hex(line, 7,8);
            case(TYPE_v)
            0: begin //data
                curraddr_v = baseaddr_v + ADDR_v;
                for(integer j=0; j<LEN_v; j=j+1) begin
                    DATA_v = str_2_hex(line ,9+2*j,10+2*j);
                    bytepos_v = curraddr_v % RAM_BYTE_WIDTH;
                    wordpos_v = curraddr_v / RAM_BYTE_WIDTH;
                    if(wordpos_v < RAM_SIZE) begin
                        ram_v [wordpos_v][8*bytepos_v +: 8] = DATA_v;
                    end
                    curraddr_v = curraddr_v+1;
                end
                CHECKSUM_v = str_2_hex(line, 9+2*LEN_v,10+2*LEN_v);
            end
            2: begin
                baddr16_v = str_2_hex(line, 9,12);
                baseaddr_v = baddr16_v*16;
            end
            4: begin
                baddr16_v = str_2_hex(line, 9,12);
                baseaddr_v = baddr16_v*65536;
            end
            5: begin
                baddr32_v = str_2_hex(line, 9,16);
                baseaddr_v = baddr32_v;
            end
            endcase
        end
        $fclose(fd);
        $display("initializing memory finished");
    end    

endfunction


    function automatic int str_2_hex;
    input string line;
    input byte pos1, pos2;
    byte j=0;
    byte temp [7:0] = '{0,0,0,0,0,0,0,0};
    int tstore =0;
    for(integer i=pos2;i>=pos1;i=i-1) begin
        if(line[i]>="0"&&line[i]<="9") begin
            temp[j] = line[i] - "0";
        end
        else if(line[i]>="A"&&line[i]<="F")begin
            temp[j] = line[i]-"A"+10;
        end
        tstore = tstore+temp[j]*(16**j);
        j++;
    end
    str_2_hex = tstore;
    endfunction

endmodule
