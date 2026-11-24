 module scfifo (clock_in, reset_in, data_in, write_in, read_in, q_out, ravail_out, wused_out, empty_out, full_out, almost_full_out);
        parameter DATA_WIDTH = 32;
        parameter FIFO_DEPTH = 12;
        parameter LOOKAHEAD = 1'b0;
        parameter ALMOST_FULL = 1;

        input wire clock_in, reset_in, write_in, read_in;
        input wire [DATA_WIDTH-1:0] data_in;
        output wire empty_out, full_out, almost_full_out;
        output wire [DATA_WIDTH-1:0] q_out;
        output wire [FIFO_DEPTH-1:0] ravail_out, wused_out;

        reg [DATA_WIDTH-1:0] q_r;
        wire [DATA_WIDTH-1:0] q;
        reg [FIFO_DEPTH-1:0] address_a, address_b, waddr_r, waddr_rr, raddr_r, raddr, ravail, wused;
        reg we, not_empty_r, full_r;

        DPRAM #(.numwords_a(2**FIFO_DEPTH), .numwords_b(2**FIFO_DEPTH),
        .widthad_a(FIFO_DEPTH), .widthad_b(FIFO_DEPTH),
        .width_a(DATA_WIDTH), .width_b(DATA_WIDTH)) ram_i (.address_a(address_a),
        .address_b(address_b), .clock(clock_in), .data_a(data_in), .wren_a(write_in)
        ,.q_b(q));

        always @(*) begin
            address_a = waddr_r;
            address_b = raddr;
        end

        always @(*) begin
            ravail = waddr_rr-raddr_r;
            wused = waddr_r-raddr_r;
            if(read_in) begin
                raddr = raddr_r+1;
            end
            else begin
                raddr = raddr_r;    
            end
        end

        assign empty_out = !not_empty_r;
        assign full_out = full_r;
        assign almost_full_out = (wused>=ALMOST_FULL) ? 1'b1 : 1'b0;
        assign ravail_out = ravail;
        assign wused_out = wused;
        assign q_out = (LOOKAHEAD) ? q : q_r;


        always @(posedge clock_in or negedge reset_in) begin
            if(!reset_in) begin
                raddr_r<=0;
                waddr_r<=0;
                waddr_rr<=0;
                q_r<=0;
                not_empty_r<=0;
                full_r<=0;
            end
            else begin
                if(write_in) begin
                    waddr_r<=waddr_r+1;
                    if(waddr_r+2==raddr) begin
                        full_r<=1;
                    end
                    else begin
                        full_r<=0;
                    end
                end
                else begin
                    if(waddr_r+1==raddr) begin
                        full_r<=1;
                    end
                    else begin
                        full_r<=0;
                    end
                end
                waddr_rr<=waddr_r;

                if(read_in) begin
                    q_r<=q;
                end
                raddr_r<=raddr;
                if(waddr_r==raddr) begin
                    not_empty_r<=0;
                end
                else begin
                    not_empty_r<=1;
                end
                    
            end
        end
        

 endmodule //fifo