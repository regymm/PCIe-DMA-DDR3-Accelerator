//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//----------------------------------------------------------------------------
//----------
//-- This module implements single-port ram with byte-enable for Xilinx
//----------

module SPRAM_BE
   #(parameter
      numwords_a=32,
      widthad_a=32,
      width_a=32
    )
    (
      input [widthad_a-1:0] address_a,
      input [width_a/8-1:0] byteena_a,
      input clock0,
      input [width_a-1:0] data_a,
      input wren_a,
      output [width_a-1:0] q_a
    ); 


wire [width_a/8-1:0] byteena;

assign byteena = (wren_a==1)?byteena_a:0;

memory_spram_be #(
   .ADDR_WIDTH_A(widthad_a), // DECIMAL
   .MEMORY_SIZE(numwords_a*width_a), // DECIMAL
   .READ_DATA_WIDTH_A(width_a), // DECIMAL
   .WRITE_DATA_WIDTH_A(width_a) // DECIMAL
)
xpm_memory_spram_inst
(
   .douta(q_a),          // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   .addra(address_a),    // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   .clka(clock0),        // 1-bit input: Clock signal for port A.
   .dina(data_a),        // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   .wea(byteena)         // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                          // for port A input data port dina. 1 bit wide when word-wide writes
                          // are used. In byte-wide write configurations, each bit controls the
                          // writing one byte of dina to address addra. For example, to
                          // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                          // is 32, wea would be 4'b0010.
);
 
endmodule
