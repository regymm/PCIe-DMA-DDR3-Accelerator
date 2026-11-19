module memory_spram (douta, addra, clka, dina, wea);
parameter ADDR_WIDTH_A = 1;
parameter MEMORY_SIZE =  32;
parameter WRITE_DATA_WIDTH_A = 32;
parameter READ_DATA_WIDTH_A = 32;
localparam MEMORY_DEPTH = MEMORY_SIZE / WRITE_DATA_WIDTH_A;

input wire clka, wea;
input wire [ADDR_WIDTH_A-1:0] addra;
input wire [WRITE_DATA_WIDTH_A-1:0] dina;

output wire [READ_DATA_WIDTH_A-1:0] douta;
reg [READ_DATA_WIDTH_A-1:0] douta_temp;

reg [WRITE_DATA_WIDTH_A-1:0] mem [MEMORY_DEPTH-1:0];

    always @(posedge clka) begin
        douta_temp <= mem [addra];
    end

    always @(posedge clka) begin
        if(wea) begin
            mem [addra] <= dina;
        end
    end

assign douta = douta_temp;

endmodule //memory_spram