//---------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//----------------------------------------------------------------------------
//
// This is the reference design to show how to build a SOC with ztachip as 
// accelerator for vision/AI workload
//
//  +-----------+
//  +           + AXI-MM     +--------------+
//  +           +----------->+  DDR         +--> DDR3 Bus
//  +           +            +  Controller  +
//  +           +            +--------------+
//  +           +
//  + soc_base  + AXI-Stream +--------------+
//  +           +------------+     VGA      +--> VGA signals
//  +           +            +--------------+
//  +           +
//  +           + AXI-Stream +--------------+
//  +           +------------+    Camera    +--> OV7670 I2C/Signals               
//  +           +            +--------------+
//  +-----------+
//

//--------------------------------------------------------------------------
//                  TOP COMPONENT DECLARATION
//                  SIGNAL/PIN ASSIGNMENTS
//--------------------------------------------------------------------------
                              
module main(
     
   // Reference clock/external reset
   
   input          sys_resetn,
   input          clk_in1_p, clk_in1_n,

   //  DDR signals 
   
   output [14:0]  ddr3_addr,
   output [2:0]   ddr3_ba_addr,
   output         ddr3_cas_n,
   output [0:0]   ddr3_ck_n,
   output [0:0]   ddr3_ck_p,
   output [0:0]   ddr3_cke,
   output [0:0]   ddr3_cs_n,
   output [0:0]   ddr3_dm,
   inout [7:0]   ddr3_dq,
   inout [0:0]    ddr3_dqs_n,
   inout [0:0]    ddr3_dqs_p,
   output [0:0]   ddr3_odt,
   output         ddr3_ras_n,
   output         ddr3_reset_n,
   output         ddr3_we_n,
   
   // UART signals
   
   output         UART_TXD,
   input          UART_RXD,
   
   // GPIO signals
   
  // output [3:0]   led,
   input [3:0]    pushbutton,

   // // VGA signals
   
   // wire         VGA_HS_O,
   // wire         VGA_VS_O,
   // wire [3:0]   VGA_R,
   // wire [3:0]   VGA_B,
   output [3:0]   vga_s
   
   // CAMERA signals   
   );

   parameter ADDR_WIDTH = 31;
   parameter MASTER_WIDTH = 512;
   parameter SLAVE_WIDTH = 64;
   parameter STRB_M = MASTER_WIDTH/8;
   parameter STRB_S = SLAVE_WIDTH/8;


   wire [ADDR_WIDTH-1:0]M_AXI_araddr;
   wire [1:0]M_AXI_arburst;
   wire [7:0]M_AXI_arlen;
   wire M_AXI_arready;
   wire [2:0]M_AXI_arsize;
   wire M_AXI_arvalid;
   wire [ADDR_WIDTH-1:0]M_AXI_awaddr;
   wire [1:0]M_AXI_awburst;
   wire [7:0]M_AXI_awlen;
   wire M_AXI_awready;
   wire [2:0]M_AXI_awsize;
   wire M_AXI_awvalid;
   wire M_AXI_bready;
   wire [1:0]M_AXI_bresp;
   wire M_AXI_bvalid;
   wire [MASTER_WIDTH-1:0]M_AXI_rdata;
   wire M_AXI_rlast;
   wire M_AXI_rready;
   wire [1:0]M_AXI_rresp;
   wire M_AXI_rvalid;
   wire [MASTER_WIDTH-1:0]M_AXI_wdata;
   wire M_AXI_wlast;
   wire M_AXI_wready;
   wire [STRB_M-1:0]M_AXI_wstrb;
   wire M_AXI_wvalid;
   wire [ADDR_WIDTH-1:0]S_AXI_araddr;
   wire [1:0]S_AXI_arburst;
   wire [7:0]S_AXI_arlen;
   wire S_AXI_arready;
   wire [2:0]S_AXI_arsize;
   wire S_AXI_arvalid;
   wire [ADDR_WIDTH-1:0]S_AXI_awaddr;
   wire [1:0]S_AXI_awburst;
   wire [7:0]S_AXI_awlen;
   wire S_AXI_awready;
   wire [2:0]S_AXI_awsize;
   wire S_AXI_awvalid;
   wire S_AXI_bready;
   wire [1:0]S_AXI_bresp;
   wire S_AXI_bvalid;
   wire [SLAVE_WIDTH-1:0]S_AXI_rdata;
   wire S_AXI_rlast;
   wire S_AXI_rready;
   wire [1:0]S_AXI_rresp;
   wire S_AXI_rvalid;
   wire [SLAVE_WIDTH-1:0]S_AXI_wdata;
   wire S_AXI_wlast;
   wire S_AXI_wready;
   wire [STRB_S-1:0]S_AXI_wstrb;
   wire S_AXI_wvalid;
   
   //clocks
   wire clk_ref_x2, clk_main_x1, clk_uber, clk_ddr, clk_ddr_90, clk_cam_vga, clk_camemu;
   wire clk_locked;

   // VGA signals
   
   wire         VGA_HS_O;
   wire         VGA_VS_O;
   wire [3:0]   VGA_R;
   wire [3:0]   VGA_B;
   wire [3:0]   VGA_G;

   wire [3:0] led;

   wire               SDRAM_clk;
   wire [31:0]        SDRAM_araddr;
   wire [1:0]         SDRAM_arburst;
   wire [7:0]         SDRAM_arlen;
   wire               SDRAM_arready;
   wire [2:0]         SDRAM_arsize;
   wire               SDRAM_arvalid;
   wire [31:0]        SDRAM_awaddr;
   wire [1:0]         SDRAM_awburst;
   wire [7:0]         SDRAM_awlen;
   wire               SDRAM_awready;
   wire [2:0]         SDRAM_awsize;
   wire               SDRAM_awvalid;
   wire               SDRAM_bready;
   wire [1:0]         SDRAM_bresp;
   wire               SDRAM_bvalid;
   wire               SDRAM_rlast;
   wire               SDRAM_rready;
   wire [1:0]         SDRAM_rresp;
   wire               SDRAM_rvalid;
   wire               SDRAM_wlast;
   wire               SDRAM_wready;
   wire               SDRAM_wvalid;

   wire [64-1:0] SDRAM_rdata;
   wire [64-1:0] SDRAM_wdata;
   wire [64/8-1:0] SDRAM_wstrb;
      
   wire [31:0]        VIDEO_tdata;
   wire               VIDEO_tlast;
   wire               VIDEO_tready;
   wire               VIDEO_tvalid;

   wire [31:0]        camera_tdata;
   wire               camera_tlast;
   wire               camera_tready;
   wire [0:0]         camera_tuser;
   wire               camera_tvalid;
   // /*for debugging*/
   // reg [31:0] awaddr_count, wdata_count, araddr_count, rdata_count, axi_errors, vga_count;

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       awaddr_count<=0;
   //    end

   //    else if(SDRAM_awready&&SDRAM_awvalid) begin
   //       awaddr_count<=awaddr_count+1;
   //    end
   // end

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       wdata_count<=0;
   //    end

   //    else if(SDRAM_wready&&SDRAM_wvalid) begin
   //       wdata_count<=wdata_count+1;
   //    end
   // end

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       araddr_count<=0;
   //    end

   //    else if(SDRAM_arvalid&&SDRAM_arready) begin
   //       araddr_count<=araddr_count+1;
   //    end
   // end

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       rdata_count<=0;
   //    end

   //    else if(SDRAM_rready&&SDRAM_rvalid) begin
   //       rdata_count<=rdata_count+1;
   //    end
   // end

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       axi_errors<=0;
   //    end

   //    else if(SDRAM_bresp||SDRAM_rresp||SDRAM_bresp||SDRAM_rresp) begin
   //       axi_errors<=axi_errors+1;
   //    end
   // end

   // always @(posedge clk_uber or negedge sys_resetn) begin
   //    if(!sys_resetn) begin
   //       vga_count<=0;
   //    end

   //    else if(VGA_B||VGA_G||VGA_R) begin
   //       vga_count<=vga_count+1;
   //    end
   // end
   // /*finished debugging block*/

   // interconnect_mk interconnect_inst
   // (
   //    .aclk          (clk_uber),
   //    .aresetn       (sys_resetn),

   //    .M_AXI_araddr  (M_AXI_araddr),
   //    .M_AXI_arburst (M_AXI_arburst),
   //    .M_AXI_arlen   (M_AXI_arlen),
   //    .M_AXI_arready (M_AXI_arready),
   //    .M_AXI_arsize  (M_AXI_arsize),
   //    .M_AXI_arvalid (M_AXI_arvalid),

   //    .M_AXI_awaddr  (M_AXI_awaddr),
   //    .M_AXI_awburst (M_AXI_awburst),
   //    .M_AXI_awlen   (M_AXI_awlen),
   //    .M_AXI_awready (M_AXI_awready),
   //    .M_AXI_awsize  (M_AXI_awsize),
   //    .M_AXI_awvalid (M_AXI_awvalid),

   //    .M_AXI_bready  (M_AXI_bready),
   //    .M_AXI_bresp   (M_AXI_bresp),
   //    .M_AXI_bvalid  (M_AXI_bvalid),

   //    .M_AXI_rdata   (M_AXI_rdata),
   //    .M_AXI_rlast   (M_AXI_rlast),
   //    .M_AXI_rready  (M_AXI_rready),
   //    .M_AXI_rresp   (M_AXI_rresp),
   //    .M_AXI_rvalid  (M_AXI_rvalid),

   //    .M_AXI_wdata   (M_AXI_wdata),
   //    .M_AXI_wlast   (M_AXI_wlast),
   //    .M_AXI_wready  (M_AXI_wready),
   //    .M_AXI_wstrb   (M_AXI_wstrb),
   //    .M_AXI_wvalid  (M_AXI_wvalid),

   //    .S_AXI_araddr  (S_AXI_araddr),
   //    .S_AXI_arburst (S_AXI_arburst),
   //    .S_AXI_arlen   (S_AXI_arlen),
   //    .S_AXI_arready (S_AXI_arready),
   //    .S_AXI_arsize  (S_AXI_arsize),
   //    .S_AXI_arvalid (S_AXI_arvalid),

   //    .S_AXI_awaddr  (S_AXI_awaddr),
   //    .S_AXI_awburst (S_AXI_awburst),
   //    .S_AXI_awlen   (S_AXI_awlen),
   //    .S_AXI_awready (S_AXI_awready),
   //    .S_AXI_awsize  (S_AXI_awsize),
   //    .S_AXI_awvalid (S_AXI_awvalid),

   //    .S_AXI_bready  (S_AXI_bready),
   //    .S_AXI_bresp   (S_AXI_bresp),
   //    .S_AXI_bvalid  (S_AXI_bvalid),

   //    .S_AXI_rdata   (S_AXI_rdata),
   //    .S_AXI_rlast   (S_AXI_rlast),
   //    .S_AXI_rready  (S_AXI_rready),
   //    .S_AXI_rresp   (S_AXI_rresp),
   //    .S_AXI_rvalid  (S_AXI_rvalid),

   //    .S_AXI_wdata   (S_AXI_wdata),
   //    .S_AXI_wlast   (S_AXI_wlast),
   //    .S_AXI_wready  (S_AXI_wready),
   //    .S_AXI_wstrb   (S_AXI_wstrb),
   //    .S_AXI_wvalid  (S_AXI_wvalid)
   // );

   soc_base soc_base_inst (
      .clk_main(clk_main_x1),
      .clk_x2_main(clk_ref_x2),
      .clk_camera(clk_cam_vga),
      .clk_vga(clk_cam_vga),
      .clk_reset(1), // Dont need reset for FPGA design. Register already initialized after programming.  

      .SDRAM_clk(clk_uber),
      .SDRAM_reset(1), // Dont need reset for FPGA design. Register already intialized after programming. 
      .SDRAM_araddr(SDRAM_araddr),
      .SDRAM_arburst(SDRAM_arburst),
      .SDRAM_arlen(SDRAM_arlen),
      .SDRAM_arready(SDRAM_arready),
      .SDRAM_arsize(SDRAM_arsize),
      .SDRAM_arvalid(SDRAM_arvalid),
      .SDRAM_awaddr(SDRAM_awaddr),
      .SDRAM_awburst(SDRAM_awburst),
      .SDRAM_awlen(SDRAM_awlen),
      .SDRAM_awready(SDRAM_awready),
      .SDRAM_awsize(SDRAM_awsize),
      .SDRAM_awvalid(SDRAM_awvalid),
      .SDRAM_bready(SDRAM_bready),
      .SDRAM_bresp(SDRAM_bresp),
      .SDRAM_bvalid(SDRAM_bvalid),
      .SDRAM_rdata(SDRAM_rdata),
      .SDRAM_rlast(SDRAM_rlast),
      .SDRAM_rready(SDRAM_rready),
      .SDRAM_rresp(SDRAM_rresp),
      .SDRAM_rvalid(SDRAM_rvalid),
      .SDRAM_wdata(SDRAM_wdata),
      .SDRAM_wlast(SDRAM_wlast),
      .SDRAM_wready(SDRAM_wready),
      .SDRAM_wstrb(SDRAM_wstrb),
      .SDRAM_wvalid(SDRAM_wvalid),

      .led(led),
      .pushbutton(pushbutton),

      .UART_TXD(UART_TXD),
      .UART_RXD(UART_RXD),

      .VGA_HS_O(VGA_HS_O),
      .VGA_VS_O(VGA_VS_O),
      .VGA_R(VGA_R),
      .VGA_B(VGA_B),
      .VGA_G(VGA_G),

      .CAMERA_PCLK(clk_camemu)
   );

   //---------------------------
   // DDR Memory controller
   //---------------------------
   wire o_calib_complete;
   ddr3_top_axi  #(.CONTROLLER_CLK_PERIOD(12_000), //ps, clock period of the controller interface
    .DDR3_CLK_PERIOD(3_000), //ps, clock period of the DDR3 RAM device (must be 1/4 of the CONTROLLER_CLK_PERIOD) 
    .ROW_BITS(15),   //width of row address
    .COL_BITS(10), //width of column address
    .BA_BITS(3), //width of bank address
    .BYTE_LANES(1), //number of byte lanes of DDR3 RAM
    .AXI_ID_WIDTH(4), // The AXI id width used for R&W, an int between 1-16
    .MICRON_SIM(1), //enable faster simulation for micron ddr3 model (shorten POWER_ON_RESET_HIGH and INITIAL_CKE_LOW)
    .ODELAY_SUPPORTED(1), //set to 1 when ODELAYE2 is supported
    .SECOND_WISHBONE(0) //set to 1 if 2nd wishbone for debugging is needed 
        ) 
      uber_inst(
            //clock and reset
            .i_controller_clk(clk_uber),
            .i_ddr3_clk(clk_ddr), //i_controller_clk has period of CONTROLLER_CLK_PERIOD, i_ddr3_clk has period of DDR3_CLK_PERIOD 
            .i_ref_clk(clk_ref_x2),
         //   .i_ddr3_clk_90(clk_ddr_90),
            .i_rst_n(sys_resetn && clk_locked), 
            // DDR3 I/O Interface
            .o_ddr3_clk_p(ddr3_ck_p),
            .o_ddr3_clk_n(ddr3_ck_n),
            .o_ddr3_reset_n(ddr3_reset_n),
            .o_ddr3_cke(ddr3_cke), 
            .o_ddr3_cs_n(ddr3_cs_n), 
            .o_ddr3_ras_n(ddr3_ras_n), 
            .o_ddr3_cas_n(ddr3_cas_n),
            .o_ddr3_we_n(ddr3_we_n),
            .o_ddr3_addr(ddr3_addr),
            .o_ddr3_ba_addr(ddr3_ba_addr),
            .io_ddr3_dq(ddr3_dq),
            .io_ddr3_dqs(ddr3_dqs_p), 
            .io_ddr3_dqs_n(ddr3_dqs_n),
            .o_ddr3_dm(ddr3_dm),
            .o_ddr3_odt(ddr3_odt),
            .o_calib_complete(o_calib_complete),
            .o_debug1(),

            // Slave Interface Write Address Ports
            .s_axi_awid(0),
            .s_axi_awaddr(SDRAM_awaddr),
            .s_axi_awlen(SDRAM_awlen),
            .s_axi_awsize(SDRAM_awsize),
            .s_axi_awburst(SDRAM_awburst),
            .s_axi_awlock(0),
            .s_axi_awcache(0),
            .s_axi_awprot(0),
            .s_axi_awqos(0),
            .s_axi_awvalid(SDRAM_awvalid),
            .s_axi_awready(SDRAM_awready),
            // Slave Interface Write Data Ports
            .s_axi_wdata(SDRAM_wdata),
            .s_axi_wstrb(SDRAM_wstrb),
            .s_axi_wlast(SDRAM_wlast),
            .s_axi_wvalid(SDRAM_wvalid),
            .s_axi_wready(SDRAM_wready),
            // Slave Interface Write Response Ports
            .s_axi_bready(SDRAM_bready),
            .s_axi_bid(),
            .s_axi_bresp(SDRAM_bresp),
            .s_axi_bvalid(SDRAM_bvalid),
            // Slave Interface Read Address Ports
            .s_axi_arid(0),
            .s_axi_araddr(SDRAM_araddr),
            .s_axi_arlen(SDRAM_arlen),
            .s_axi_arsize(SDRAM_arsize),
            .s_axi_arburst(SDRAM_arburst),
            .s_axi_arlock(0),
            .s_axi_arcache(0),
            .s_axi_arprot(0),
            .s_axi_arqos(0),
            .s_axi_arvalid(SDRAM_arvalid),
            .s_axi_arready(SDRAM_arready),
            // Slave Interface Read Data Ports
            .s_axi_rready(SDRAM_rready),
            .s_axi_rid(),
            .s_axi_rdata(SDRAM_rdata),
            .s_axi_rresp(SDRAM_rresp),
            .s_axi_rlast(SDRAM_rlast),
            .s_axi_rvalid(SDRAM_rvalid)
   );

   // ------------------
   // Clock synthesizer
   // -------------------


//   clk_wiz_0 clocking_ip
//    (
//     // Clock out ports
//     .clk_x2_200(clk_ref_x2),     // output clk_ref_x2
//     .clk_x1_100(clk_main_x1),     // output clk_main_x1
//     .clk_ddr_333(clk_ddr),     // output clk_ddr
//     .clk_uber_83(clk_uber),     // output clk_uber
//     .clk_vga_cam(clk_cam_vga),     // output clk_cam_vga
//     .clk_cam_emu(clk_camemu),     // output clk_camemu
//     // Status and control signals
//     .resetn(sys_resetn), // input resetn
//    // Clock in ports
//     .clk_in1_p(clk_in1_p),    // input clk_in1_p
//     .clk_in1_n(clk_in1_n)    // input clk_in1_n
// );

  clk_mmcm_diff clocking_ip
   (
    // Clock out ports
    .clk_x2_200(clk_ref_x2),     // output clk_x2_200
    .clk_x1_100(clk_main_x1),     // output clk_x1_100
    .clk_uber_83(clk_uber),     // output clk_uber_83
    .clk_ddr_333(clk_ddr),     // output clk_ddr_333
  //  .clk_90_333(clk_ddr_90),     // output clk_90_333
    .clk_vga_cam(clk_cam_vga),     // output clk_vga_cam
    .clk_cam_emu(clk_camemu),     // output clk_cam_emu
    // Status and control signals
    .resetn(sys_resetn), // input resetn
    .locked(clk_locked),
   // Clock in ports
    .clk_in1_p(clk_in1_p),    // input clk_in1_p
    .clk_in1_n(clk_in1_n)    // input clk_in1_n
);

vga_sample vga_sample_inst (
    .clk     (clk_cam_vga),
    .aresetn (sys_resetn && clk_locked),
    .led     (led),
    .VGA_R   (VGA_R),
    .VGA_G   (VGA_G),
    .VGA_B   (VGA_B),
    .vga_s   (vga_s)
);


//    //ILA
// ila_0 ila_inst (
// 	.clk(clk_ddr), // input wire clk

// 	.probe0(VGA_HS_O), // input wire [0:0]  probe0  
// 	.probe1(VGA_VS_O), // input wire [0:0]  probe1 
// 	.probe2(VGA_R), // input wire [3:0]  probe2 
// 	.probe3(VGA_G), // input wire [3:0]  probe3 
// 	.probe4(VGA_B), // input wire [3:0]  probe4
//    .probe5(vga_sample_inst.samp_count)
//    // .probe5(sys_resetn),
//    // .probe6(clk_locked),
//    // .probe7(o_calib_complete),
//    // .probe8(M_AXI_araddr),
//    // .probe9(M_AXI_awaddr),
//    // .probe10(M_AXI_arvalid),
//    // .probe11(M_AXI_awvalid),
//    // .probe12(M_AXI_wdata),
//    // .probe13(S_AXI_rdata),
//    // .probe14(S_AXI_arready),
//    // .probe15(S_AXI_awready),
//    // .probe16(axi_errors),
//    // .probe17(awaddr_count),
//    // .probe18(wdata_count),
//    // .probe19(araddr_count),
//    // .probe20(rdata_count),
//    // .probe21(S_AXI_awlen),
//    // .probe22(M_AXI_awlen),
//    // .probe23(S_AXI_araddr),
//    // .probe24(S_AXI_arvalid),
//    // .probe25(S_AXI_awvalid),
//    // .probe26(vga_count)
// );


endmodule

