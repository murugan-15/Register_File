//==============================================================================
// Module      : Register File
// File        : register_file.v
// Author      : Ramasubbu Bala Murugan
// Description :
//   Parameterized single-port Register File with one synchronous write port
//   and one synchronous read port.
//==============================================================================

module register_file
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)
(
    input  wire                    clk,
    input  wire                    rst,

    //--------------------------------------------------------------------------
    // Write Port
    //--------------------------------------------------------------------------
    input  wire                    wr_en,
    input  wire [ADDR_WIDTH-1:0]   wr_addr,
    input  wire [DATA_WIDTH-1:0]   wr_data,

    //--------------------------------------------------------------------------
    // Read Port
    //--------------------------------------------------------------------------
    input  wire                    rd_en,
    input  wire [ADDR_WIDTH-1:0]   rd_addr,
    output reg  [DATA_WIDTH-1:0]   rd_data
);

    //--------------------------------------------------------------------------
    // Number of registers in the register file
    //--------------------------------------------------------------------------
    localparam DEPTH = (1 << ADDR_WIDTH);

    //--------------------------------------------------------------------------
    // Memory Array
    //--------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //--------------------------------------------------------------------------
    // Sequential Logic
    //--------------------------------------------------------------------------
    always @(posedge clk)
    begin
        if (rst)
        begin
            rd_data <= {DATA_WIDTH{1'b0}};
        end
        else
        begin
            // Synchronous Write
            if (wr_en)
                mem[wr_addr] <= wr_data;

            // Synchronous Read
            if (rd_en)
                rd_data <= mem[rd_addr];
        end
    end

endmodule
