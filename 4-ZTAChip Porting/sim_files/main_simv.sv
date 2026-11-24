`timescale 1ns / 1ps //time precision
module main_simv ();
//parameters
parameter MEM_WIDTH = 64;
parameter RESET_R = 4;
localparam CLK_PERIOD = 4;
//port definition
logic [3:0] led_out;
//signals definition
//clocks
bit clk, clk_x2_main, clk_main, clk_r;
//reset signals
logic [RESET_R-1:0] reset_r = 0;
logic reset;
//memory-controller interface
logic [31:0] SDRAM_araddr, SDRAM_awaddr;
logic [1:0] SDRAM_arburst, SDRAM_awburst, SDRAM_bresp, SDRAM_rresp;
logic [7:0] SDRAM_arlen, SDRAM_awlen;
logic SDRAM_arready, SDRAM_arvalid, SDRAM_awready, SDRAM_awvalid, SDRAM_bready, SDRAM_bvalid, SDRAM_rlast, SDRAM_rready, SDRAM_rvalid, SDRAM_wlast, SDRAM_wready, SDRAM_wvalid;
logic [2:0] SDRAM_arsize, SDRAM_awsize;
logic [MEM_WIDTH-1:0] SDRAM_rdata, SDRAM_wdata;
logic [MEM_WIDTH/8-1:0] SDRAM_wstrb;
//generating clock
initial begin
    forever begin
        #2;
        clk = ~clk;
    end
end

assign clk_x2_main = clk;

assign clk_main = clk_r;

always @(posedge clk) begin 
    clk_r <= ~clk_r;
end
//handling resets
assign reset = reset_r[RESET_R-1];
always @(posedge clk_main) begin 
    if(reset_r[RESET_R-1]===0) begin
        reset_r <= reset_r + 1'b1;
    end
end
//modules instantiation
soc_base soc_base_inst(.clk_main(clk_main), .clk_x2_main(clk_x2_main), .clk_camera(0), .clk_vga(0), .clk_reset(reset),
.SDRAM_clk(clk_main), .SDRAM_reset(reset), .SDRAM_araddr(SDRAM_araddr), .SDRAM_arburst(SDRAM_arburst), .SDRAM_arlen(SDRAM_arlen),
.SDRAM_arready(SDRAM_arready), .SDRAM_arsize(SDRAM_arsize), .SDRAM_arvalid(SDRAM_arvalid), .SDRAM_awaddr(SDRAM_awaddr),
.SDRAM_awburst(SDRAM_awburst), .SDRAM_awlen(SDRAM_awlen), .SDRAM_awready(SDRAM_awready), .SDRAM_awsize(SDRAM_awsize),
.SDRAM_awvalid(SDRAM_awvalid), .SDRAM_bready(SDRAM_bready), .SDRAM_bresp(SDRAM_bresp), .SDRAM_bvalid(SDRAM_bvalid),
.SDRAM_rdata(SDRAM_rdata),.SDRAM_rlast(SDRAM_rlast),.SDRAM_rready(SDRAM_rready),.SDRAM_rresp(SDRAM_rresp),.SDRAM_rvalid(SDRAM_rvalid),
.SDRAM_wdata(SDRAM_wdata),.SDRAM_wlast(SDRAM_wlast),.SDRAM_wready(SDRAM_wready),.SDRAM_wstrb(SDRAM_wstrb),.SDRAM_wvalid(SDRAM_wvalid),
.led(led_out),.pushbutton(0),.UART_RXD(0),.CAMERA_PCLK(0),

.UART_TXD(),.VGA_B(),.VGA_G(),.VGA_R(),.VGA_VS_O(),.VGA_HS_O());//APB_PORT, UARTTX, VGA_PORT and some camera signals were left unconnected intentionally



mem64 mem64_inst(.SDRAM_clk(clk_main),.SDRAM_reset(reset),.SDRAM_araddr(SDRAM_araddr),.SDRAM_arburst(SDRAM_arburst),
.SDRAM_arlen(SDRAM_arlen),.SDRAM_arready(SDRAM_arready),.SDRAM_arsize(SDRAM_arsize),.SDRAM_arvalid(SDRAM_arvalid),
.SDRAM_awaddr(SDRAM_awaddr),.SDRAM_awburst(SDRAM_awburst),.SDRAM_awlen(SDRAM_awlen),.SDRAM_awready(SDRAM_awready)
,.SDRAM_awsize(SDRAM_awsize),.SDRAM_awvalid(SDRAM_awvalid),.SDRAM_bready(SDRAM_bready),.SDRAM_bresp(SDRAM_bresp)
,.SDRAM_bvalid(SDRAM_bvalid),.SDRAM_rdata(SDRAM_rdata),.SDRAM_rlast(SDRAM_rlast),.SDRAM_rready(SDRAM_rready),
.SDRAM_rresp(SDRAM_rresp),.SDRAM_rvalid(SDRAM_rvalid),.SDRAM_wdata(SDRAM_wdata),.SDRAM_wlast(SDRAM_wlast),
.SDRAM_wready(SDRAM_wready),.SDRAM_wstrb(SDRAM_wstrb),.SDRAM_wvalid(SDRAM_wvalid));



endmodule //main_simv