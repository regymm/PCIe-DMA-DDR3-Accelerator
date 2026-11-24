module afifo (rclock_in, wclock_in, reset_in, data_in, write_in, read_in, q_out, empty_out, full_out);
    parameter DATA_WIDTH=32;
    parameter FIFO_DEPTH = 12;

    input wire rclock_in, wclock_in, reset_in, write_in, read_in;
    input wire [DATA_WIDTH-1:0] data_in;
    output wire empty_out, full_out;
    output wire [DATA_WIDTH-1:0] q_out;

    reg wready_r, full_r, avail_r;
    wire [DATA_WIDTH-1:0] q;
    reg [FIFO_DEPTH:0] waddr_gray_r, raddr_gray_r, waddr_binary_r, raddr_binary_r, raddr_gray_next, waddr_gray_next, raddr_binary_next, raddr_binary_prev, waddr_binary_next;
    wire [FIFO_DEPTH:0] raddr_gray_sync, waddr_gray_sync;
    reg [FIFO_DEPTH-1:0] raddr;



    assign q_out = q;
    assign empty_out = !avail_r;
    assign full_out = full_r;
    always @(*) begin
        raddr_binary_next = raddr_binary_r+1;
        raddr_binary_prev = raddr_binary_r-1;
        raddr_gray_next = bin2gray(raddr_binary_next);
        waddr_binary_next = waddr_binary_r+1;
        waddr_gray_next = bin2gray(waddr_binary_next);
        raddr = (read_in) ? raddr_binary_next[FIFO_DEPTH-1:0] : raddr_binary_r[FIFO_DEPTH-1:0];
    end


    DPRAM_DUAL_CLOCK #(.numwords_a(2**FIFO_DEPTH), .numwords_b(2**FIFO_DEPTH), .widthad_a(FIFO_DEPTH), .widthad_b(FIFO_DEPTH),
    .width_a(DATA_WIDTH), .width_b(DATA_WIDTH)) ram_i (.address_a(waddr_binary_r[FIFO_DEPTH-1:0]), .address_b(raddr),
    .clock_a(wclock_in),.clock_b(rclock_in),.data_a(data_in), .wren_a(write_in), .q_b(q));


    CCD_SYNC #(.WIDTH(FIFO_DEPTH+1)) sync_i1 (.inclock_in(wclock_in), .outclock_in(rclock_in),
    .reset_in(reset_in), .input_in(waddr_gray_r), .output_out(waddr_gray_sync));

    CCD_SYNC #(.WIDTH(FIFO_DEPTH+1)) sync_i2 (.inclock_in(rclock_in), .outclock_in(wclock_in),
    .reset_in(reset_in), .input_in(raddr_gray_r), .output_out(raddr_gray_sync));



    always @(posedge rclock_in or negedge reset_in) begin
        if(!reset_in) begin
            raddr_gray_r<=0;
            raddr_binary_r<=0;
            avail_r<=0;
        end
        else begin
            if(read_in) begin
                raddr_gray_r<=raddr_gray_next;
                raddr_binary_r<=raddr_binary_next;
                if(raddr_gray_next[FIFO_DEPTH]==waddr_gray_sync[FIFO_DEPTH]&&raddr_gray_next[FIFO_DEPTH-2:0]==waddr_gray_sync[FIFO_DEPTH-2:0]&&(raddr_gray_next[FIFO_DEPTH]^raddr_gray_next[FIFO_DEPTH-1]== waddr_gray_sync[FIFO_DEPTH] ^ waddr_gray_sync[FIFO_DEPTH-1])) begin
                    avail_r<=0;
                end
                else begin
                    avail_r<=1;
                end
            end
            else begin
                if(raddr_gray_r[FIFO_DEPTH]==waddr_gray_sync[FIFO_DEPTH]&&raddr_gray_r[FIFO_DEPTH-2:0]==waddr_gray_sync[FIFO_DEPTH-2:0]&&(raddr_gray_r[FIFO_DEPTH]^raddr_gray_r[FIFO_DEPTH-1]==waddr_gray_sync[FIFO_DEPTH] ^ waddr_gray_sync[FIFO_DEPTH-1])) begin
                    avail_r<=0;
                end
                else begin
                    avail_r<=1;
                end
            end
        end
    end


    always @(posedge wclock_in or negedge reset_in) begin
        if(!reset_in) begin
            waddr_gray_r<=0;
            waddr_binary_r<=0;
            wready_r<=0;
            full_r<=0;
        end
        else begin
            wready_r<=1;
            if(write_in) begin
                waddr_gray_r<=waddr_gray_next;
                waddr_binary_r<=waddr_binary_next;
                if(raddr_gray_sync[FIFO_DEPTH]!=waddr_gray_next[FIFO_DEPTH]&&raddr_gray_sync[FIFO_DEPTH-2:0]==waddr_gray_next[FIFO_DEPTH-2:0]&&(raddr_gray_sync[FIFO_DEPTH]^raddr_gray_sync[FIFO_DEPTH-1]==waddr_gray_next[FIFO_DEPTH]^waddr_gray_next[FIFO_DEPTH-1])) begin
                    full_r<=1;
                end
                else begin
                    full_r<=0;    
                end
            end
            else begin
                if(raddr_gray_sync[FIFO_DEPTH]!=waddr_gray_r[FIFO_DEPTH]&&raddr_gray_sync[FIFO_DEPTH-2:0]==waddr_gray_r[FIFO_DEPTH-2:0]&&(raddr_gray_sync[FIFO_DEPTH]^raddr_gray_sync[FIFO_DEPTH-1]==waddr_gray_r[FIFO_DEPTH]^waddr_gray_r[FIFO_DEPTH-1])) begin
                    full_r<=1;
                end
                else begin
                    full_r<=0;
                end
            end
                
        end
    end


    function [FIFO_DEPTH:0] bin2gray;
        input [FIFO_DEPTH:0] binary_in;
        begin
            bin2gray = {binary_in[FIFO_DEPTH], (binary_in[FIFO_DEPTH-1:0]^binary_in[FIFO_DEPTH:1])};
        end
    endfunction

endmodule //afifo