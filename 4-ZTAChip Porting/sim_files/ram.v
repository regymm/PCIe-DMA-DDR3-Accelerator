module camera_rom (pclk, rst_n, address, data_out);
    //declaring parameters
    parameter WORD_WIDTH = 8; 
    parameter RAM_DEPTH = 640*480*2;
    parameter ADDRESS_WIDTH = $clog2(RAM_DEPTH);
    //defining ports
    input wire pclk, rst_n;
    input wire [ADDRESS_WIDTH-1:0] address;
    output wire [WORD_WIDTH-1:0] data_out;
    //declaring dataout register 
    reg [WORD_WIDTH-1:0] data_out_reg;
    //defining RAM block
    (* ram_style = "block"*) 
    reg [WORD_WIDTH-1:0] mem [RAM_DEPTH-1:0];
    //operation:
    //initialzing RAM
    initial begin
        $readmemh("/home/mohamed/Desktop/ztachip/deliverables/afterboard/openxc7/modified_soc_sim/ztasim_v/image_data.text",mem);
    end
    //Rertrieving data
    always @(posedge pclk or negedge rst_n) begin
        if(!rst_n) begin
            data_out_reg<=0;
        end
        else begin
            data_out_reg<=mem[address];
        end
    end 
    assign data_out = data_out_reg;
endmodule //ram
