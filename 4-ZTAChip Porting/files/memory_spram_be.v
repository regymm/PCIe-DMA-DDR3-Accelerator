module memory_spram_be (douta, addra, clka, dina, wea);
parameter ADDR_WIDTH_A = 1;
parameter MEMORY_SIZE =  32;
parameter WRITE_DATA_WIDTH_A = 32;
parameter READ_DATA_WIDTH_A = 32;
localparam MEMORY_DEPTH = MEMORY_SIZE / WRITE_DATA_WIDTH_A;

input wire clka;
input wire [WRITE_DATA_WIDTH_A/8-1:0] wea;
input wire [ADDR_WIDTH_A-1:0] addra;
input wire [WRITE_DATA_WIDTH_A-1:0] dina;

output wire [READ_DATA_WIDTH_A-1:0] douta;
reg [READ_DATA_WIDTH_A-1:0] douta_temp;

reg [WRITE_DATA_WIDTH_A-1:0] mem [MEMORY_DEPTH-1:0];

integer i;

    always @(posedge clka) begin
        douta_temp <= mem [addra];
    end

    always @(posedge clka) begin
        for(i=0; i<WRITE_DATA_WIDTH_A/8; i=i+1) begin
            if(wea[i]) begin
                mem [addra] [8*(i)+:8] <= dina [8*(i)+:8];
            end
        end
    end

assign douta = douta_temp;

endmodule //memory_spram_be