class register_file_transaction
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
);

    typedef enum logic [1:0]
    {
        OP_WRITE,
        OP_READ,
        OP_READ_WRITE_SAME,
        OP_READ_WRITE_DIFF
    } operation_t;

    //=========================================================
    // Transaction Fields
    //=========================================================

    operation_t operation;

    logic [ADDR_WIDTH-1:0] read_addr;
    logic [ADDR_WIDTH-1:0] write_addr;

    logic [DATA_WIDTH-1:0] write_data;

    //=========================================================
    // Constructor
    //=========================================================

    function new();

        operation  = OP_READ;

        read_addr  = '0;
        write_addr = '0;
        write_data = '0;

    endfunction

    //=========================================================
    // Print Transaction
    //=========================================================

    function void display(string prefix = "TRANSACTION");

        $display(
            "[%0t] %s : "
            "Operation = %s "
            "Read Addr = %0d "
            "Write Addr = %0d "
            "Write Data = %0h",
            $time,
            prefix,
            operation.name(),
            read_addr,
            write_addr,
            write_data
        );

    endfunction

endclass
