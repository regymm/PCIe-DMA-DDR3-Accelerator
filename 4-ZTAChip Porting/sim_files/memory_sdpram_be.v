/*This design was created by Mohamed Khaled intended for allowing properietary IPs to be 
implemented on open-source platforms*/

module memory_sdpram_be (doutb, addra, addrb, clk, dina, wea, ena);
parameter ADDR_WIDTH_A = 1;
parameter ADDR_WIDTH_B = 1;
parameter MEMORY_SIZE =  32;
parameter WRITE_DATA_WIDTH_A = 32;
parameter READ_DATA_WIDTH_B = 32; 
localparam MEMORY_DEPTH = MEMORY_SIZE / WRITE_DATA_WIDTH_A;

input wire clk, ena;
input wire [WRITE_DATA_WIDTH_A/8-1:0] wea;
input wire [ADDR_WIDTH_A-1:0] addra;
input wire [ADDR_WIDTH_B-1:0] addrb;
input wire [WRITE_DATA_WIDTH_A-1:0] dina;

output wire [READ_DATA_WIDTH_B-1:0] doutb;
reg [READ_DATA_WIDTH_B-1:0] doutb_temp;

reg [WRITE_DATA_WIDTH_A-1:0] mem [MEMORY_DEPTH-1:0];

integer i;
    initial begin
        for (i = 0;i<MEMORY_DEPTH ;i=i+1 ) begin
            mem[i]=0;
        end 
    end
    
    always @(posedge clk) begin
        doutb_temp <= mem [addrb];
    end

    always @(posedge clk) begin
        if(ena) begin
            for(i=0; i<WRITE_DATA_WIDTH_A/8; i=i+1) begin
                if(wea[i]) begin
                    mem [addra] [8*(i)+:8] <= dina [8*(i)+:8];
                end
            end
        end
    end

assign doutb = doutb_temp;

endmodule //memory_sdpram_be