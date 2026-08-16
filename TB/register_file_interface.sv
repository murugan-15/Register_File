interface register_file_if
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)
(
    input logic clk
);

    // Reset
    logic rst;

    // Write interface
    logic                    wr_en;
    logic [ADDR_WIDTH-1:0]   wr_addr;
    logic [DATA_WIDTH-1:0]   wr_data;

    // Read interface
    logic                    rd_en;
    logic [ADDR_WIDTH-1:0]   rd_addr;
    logic [DATA_WIDTH-1:0]   rd_data;

endinterface
