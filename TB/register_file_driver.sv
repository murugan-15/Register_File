class register_file_driver
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
);

    // Virtual interface
    virtual register_file_if #(DATA_WIDTH, ADDR_WIDTH) vif;

    // Constructor
    function new(
        virtual register_file_if #(DATA_WIDTH, ADDR_WIDTH) vif
    );
        this.vif = vif;
    endfunction

    //=========================================================
    // Main Transaction Entry Point
    //=========================================================

    task automatic send
    (
        register_file_transaction tr
    );

        case (tr.operation)

            register_file_transaction::OP_WRITE:
            begin
                drive_write(
                    tr.write_addr,
                    tr.write_data
                );
            end


            register_file_transaction::OP_READ:
            begin
                drive_read(
                    tr.read_addr
                );
            end


            register_file_transaction::OP_READ_WRITE_SAME:
            begin
                drive_read_write_same(
                    tr.write_addr,
                    tr.write_data
                );
            end


            register_file_transaction::OP_READ_WRITE_DIFF:
            begin
                drive_read_write_diff(
                    tr.read_addr,
                    tr.write_addr,
                    tr.write_data
                );
            end


            default:
            begin
                $error(
                    "[%0t] DRIVER ERROR: "
                    "Unsupported transaction type",
                    $time
                );
            end

        endcase

    endtask

    //=========================================================
    // Drive Write Transaction
    //=========================================================
    task automatic drive_write
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
    begin

        // Drive before active clock edge
        @(negedge vif.clk);

        vif.wr_en   <= 1'b1;
        vif.wr_addr <= addr;
        vif.wr_data <= data;

        // DUT accepts transaction
        @(posedge vif.clk);

        // Disable write controls
        @(negedge vif.clk);

        vif.wr_en   <= 1'b0;
        vif.wr_addr <= '0;
        vif.wr_data <= '0;

        $display(
            "[%0t] WRITE : Address = %0d Data = %0h",
            $time,
            addr,
            data
        );

    end
    endtask

    //=========================================================
    // Drive Read Transaction
    //=========================================================
    task automatic drive_read
    (
        input logic [ADDR_WIDTH-1:0] addr
    );
    begin

        // Drive before active clock edge
        @(negedge vif.clk);

        vif.rd_en   <= 1'b1;
        vif.rd_addr <= addr;

        // DUT accepts read request
        @(posedge vif.clk);

        // Disable read controls
        @(negedge vif.clk);

        vif.rd_en   <= 1'b0;
        vif.rd_addr <= '0;

        $display(
            "[%0t] READ  : Address = %0d",
            $time,
            addr
        );

    end
    endtask

    //=========================================================
    // Drive Simultaneous Read / Write
    // Same Address
    //=========================================================
    task automatic drive_read_write_same
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
    begin

        // Drive both operations before active edge
        @(negedge vif.clk);

        vif.wr_en   <= 1'b1;
        vif.wr_addr <= addr;
        vif.wr_data <= data;

        vif.rd_en   <= 1'b1;
        vif.rd_addr <= addr;

        // DUT accepts both transactions
        @(posedge vif.clk);

        // Disable controls
        @(negedge vif.clk);

        vif.wr_en   <= 1'b0;
        vif.rd_en   <= 1'b0;

        vif.wr_addr <= '0;
        vif.rd_addr <= '0;
        vif.wr_data <= '0;

        $display(
            "[%0t] SIMULTANEOUS R/W : Address = %0d Write Data = %0h",
            $time,
            addr,
            data
        );

    end
    endtask

    //=========================================================
    // Drive Simultaneous Read / Write
    // Different Addresses
    //=========================================================
    task automatic drive_read_write_diff
    (
        input logic [ADDR_WIDTH-1:0] rd_addr_i,
        input logic [ADDR_WIDTH-1:0] wr_addr_i,
        input logic [DATA_WIDTH-1:0] wr_data_i
    );
    begin

        // Drive both operations before active edge
        @(negedge vif.clk);

        vif.wr_en   <= 1'b1;
        vif.wr_addr <= wr_addr_i;
        vif.wr_data <= wr_data_i;

        vif.rd_en   <= 1'b1;
        vif.rd_addr <= rd_addr_i;

        // DUT accepts both transactions
        @(posedge vif.clk);

        // Disable controls
        @(negedge vif.clk);

        vif.wr_en   <= 1'b0;
        vif.rd_en   <= 1'b0;

        vif.wr_addr <= '0;
        vif.rd_addr <= '0;
        vif.wr_data <= '0;

        $display(
            "[%0t] SIMULTANEOUS R/W : "
            "Read Addr = %0d "
            "Write Addr = %0d "
            "Write Data = %0h",
            $time,
            rd_addr_i,
            wr_addr_i,
            wr_data_i
        );

    end
    endtask

endclass
