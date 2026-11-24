module afifo2 (rclock_in, wclock_in, reset_in, data_in, write_in, read_in, q_out, empty_out, full_out);
    parameter DATA_WIDTH= 32;
    parameter FIFO_DEPTH = 12;

    input wire rclock_in, wclock_in, reset_in, write_in, read_in;
    input wire [DATA_WIDTH-1:0] data_in;
    output wire empty_out, full_out;
    output wire [DATA_WIDTH-1:0] q_out;

    wire [DATA_WIDTH-1:0] data;
    wire [DATA_WIDTH-1:0] q;
    wire write, empty, full, read;

    generate if(FIFO_DEPTH>5) begin
        afifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(5)) afifo_i (.rclock_in(rclock_in),.wclock_in(wclock_in),
        .reset_in(reset_in),.data_in(data), .write_in(write), .read_in(read_in), .q_out(q_out), .empty_out(empty_out), .full_out(full));
   
       assign data =q;
       assign write = !empty & !full;
       assign read = write;

        scfifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH), .LOOKAHEAD(1)) fifo_i (.reset_in(reset_in), .clock_in(wclock_in),
        .read_in(read), .q_out(q), .empty_out(empty), .data_in(data_in), .write_in(write_in),
        .full_out(full_out), .ravail_out(), .wused_out(), .almost_full_out());
    end
    else begin
        afifo #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) afifo_i (.rclock_in(rclock_in),.wclock_in(wclock_in),
        .reset_in(reset_in),.data_in(data_in),.write_in(write_in),.read_in(read_in),.q_out(q_out),.empty_out(empty_out)
        ,.full_out(full_out));
    end
    endgenerate

endmodule //afifo2