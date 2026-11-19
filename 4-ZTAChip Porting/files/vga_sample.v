`default_nettype wire
module vga_sample (clk, aresetn, led, VGA_R, VGA_G, VGA_B, vga_s);
    parameter SAMPLE_FREQ = 25<<20;
    localparam ACT_FREQ = SAMPLE_FREQ>>3;

    input clk, aresetn;
    input [3:0] led, VGA_G, VGA_B, VGA_R;
    output reg [3:0] vga_s; 

    reg [22:0] samp_count;

    always @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            samp_count<=23'b0;
        end
        else begin
            if(samp_count == ACT_FREQ-1) begin
                samp_count<=23'b0;
            end
            else begin
                samp_count<=samp_count+1'b1;
            end
        end
    end


    always @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            vga_s<=4'b0;
        end
        else if(samp_count == ACT_FREQ-1) begin
            vga_s <= VGA_R;
        end
    end

endmodule //vga_sample