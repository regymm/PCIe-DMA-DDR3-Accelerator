module memory_sdpram (doutb, addra, addrb, clk, dina, wea, ena);
parameter ADDR_WIDTH_A = 1;
parameter ADDR_WIDTH_B = 1;
parameter MEMORY_SIZE =  32;
parameter WRITE_DATA_WIDTH_A = 32;
parameter READ_DATA_WIDTH_B = 32; 
localparam MEMORY_DEPTH = MEMORY_SIZE / WRITE_DATA_WIDTH_A;

input wire clk, wea, ena;
input wire [ADDR_WIDTH_A-1:0] addra;
input wire [ADDR_WIDTH_B-1:0] addrb;
input wire [WRITE_DATA_WIDTH_A-1:0] dina;

output wire [READ_DATA_WIDTH_B-1:0] doutb;
reg [READ_DATA_WIDTH_B-1:0] doutb_temp;

reg [WRITE_DATA_WIDTH_A-1:0] mem [MEMORY_DEPTH-1:0];

    always @(posedge clk) begin
        doutb_temp <= mem [addrb];
    end

    always @(posedge clk) begin
        if(ena) begin
            if(wea) begin
                mem [addra] <= dina;
            end 
        end
    end

assign doutb = doutb_temp;

endmodule //memory_sdpram