/*This design was created by Mohamed Khaled intended for allowing properietary IPs to be 
implemented on open-source platforms*/

module cdc_array_single (dest_clk, dest_out, src_in);
parameter WIDTH = 1;
input wire dest_clk;
input wire [WIDTH-1:0] src_in;
output wire [WIDTH-1:0] dest_out;
reg [WIDTH-1:0] dest_out_temp, dest_out_temp1, dest_out_temp2;

    always @(posedge dest_clk) begin
        dest_out_temp1<=src_in;
    end 

    always @(posedge dest_clk) begin
        dest_out_temp2<=dest_out_temp1;
    end

    always @(posedge dest_clk) begin
        dest_out_temp<=dest_out_temp2;
    end

assign dest_out = dest_out_temp;

endmodule //cdc_array_single