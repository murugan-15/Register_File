class register_file_scoreboard
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    //=========================================================
    // Golden Model
    //=========================================================

    logic [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];
    logic                  valid_mem    [0:DEPTH-1];

    //=========================================================
    // Read-During-Write State
    //=========================================================

    logic [DATA_WIDTH-1:0] pending_expected;
    logic [ADDR_WIDTH-1:0] expected_addr;

    logic pending_expected_valid;
    logic pending_read_during_write;

    //=========================================================
    // Statistics
    //=========================================================

    int pass_count;
    int fail_count;
    int skip_count;

    //=========================================================
    // Constructor
    //=========================================================

    function new();
        reset();
    endfunction

    //=========================================================
    // Reset Scoreboard
    //=========================================================

    function void reset();

        for (int i = 0; i < DEPTH; i++)
        begin
            expected_mem[i] = '0;
            valid_mem[i]    = 1'b0;
        end

        pending_expected          = '0;
        expected_addr             = '0;
        pending_expected_valid    = 1'b0;
        pending_read_during_write = 1'b0;

    endfunction

    //=========================================================
    // Accept Write
    //=========================================================

    function void accept_write
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );

        expected_mem[addr] = data;
        valid_mem[addr]    = 1'b1;

    endfunction

    //=========================================================
    // Capture Old Value For Read-During-Write
    //=========================================================

    function void prepare_read_during_write
    (
        input logic [ADDR_WIDTH-1:0] addr
    );

        expected_addr             = addr;
        pending_read_during_write = 1'b1;

        // Capture the OLD golden value before the write
        // updates the golden model.
        if (valid_mem[addr])
        begin

            pending_expected       = expected_mem[addr];
            pending_expected_valid = 1'b1;

        end
        else
        begin

            pending_expected        = '0;
            pending_expected_valid  = 1'b0;

            $display(
                "[%0t] INFO: "
                "Address %0d has never been written",
                $time,
                addr
            );

        end

    endfunction

    //=========================================================
    // Compare Normal Read
    //=========================================================

    function void compare
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] actual_data
    );

        // Address has never been written.
        if (!valid_mem[addr])
        begin

            $display(
                "[%0t] INFO: "
                "Address = %0d has never been written, "
                "comparison skipped",
                $time,
                addr
            );

            skip_count++;

        end

        // Expected data matches DUT.
        else if (expected_mem[addr] === actual_data)
        begin

            $display(
                "[%0t] PASS: "
                "Address = %0d "
                "Expected = %0h "
                "Actual = %0h",
                $time,
                addr,
                expected_mem[addr],
                actual_data
            );

            pass_count++;

        end

        // Mismatch.
        else
        begin

            $display(
                "[%0t] FAIL: "
                "Address = %0d "
                "Expected = %0h "
                "Actual = %0h",
                $time,
                addr,
                expected_mem[addr],
                actual_data
            );

            fail_count++;

        end

    endfunction

    //=========================================================
    // Compare Read-During-Write
    //=========================================================

    function void compare_pending
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] actual_data
    );

        // No previous valid value existed.
        if (!pending_expected_valid)
        begin

            $display(
                "[%0t] INFO: "
                "Address = %0d has never been written, "
                "comparison skipped",
                $time,
                addr
            );

            skip_count++;

        end

        // Old value matches DUT read result.
        else if (pending_expected === actual_data)
        begin

            $display(
                "[%0t] PASS: "
                "Read-During-Write "
                "Address = %0d "
                "Expected Old Data = %0h "
                "Actual = %0h",
                $time,
                addr,
                pending_expected,
                actual_data
            );

            pass_count++;

        end

        // Collision behavior mismatch.
        else
        begin

            $display(
                "[%0t] FAIL: "
                "Read-During-Write "
                "Address = %0d "
                "Expected Old Data = %0h "
                "Actual = %0h",
                $time,
                addr,
                pending_expected,
                actual_data
            );

            fail_count++;

        end


        // Consume pending collision information.
        pending_expected_valid   = 1'b0;
        pending_read_during_write = 1'b0;

    endfunction

    //=========================================================
    // Check Scoreboard Reset State
    //=========================================================

    function void check_reset_state();

        bit error_found;

        error_found = 1'b0;

        // Check all memory-valid bits.
        for (int i = 0; i < DEPTH; i++)
        begin

            if (valid_mem[i] !== 1'b0)
            begin

                $display(
                    "FAIL: valid_mem[%0d] = %0b",
                    i,
                    valid_mem[i]
                );

                error_found = 1'b1;

            end

        end

        // Check pending state.
        if (pending_expected_valid !== 1'b0)
        begin
            $display("FAIL: pending_expected_valid not cleared");
            error_found = 1'b1;
        end

        if (pending_read_during_write !== 1'b0)
        begin
            $display("FAIL: pending_read_during_write not cleared");
            error_found = 1'b1;
        end


        if (pending_expected !== '0)
        begin
            $display("FAIL: pending_expected not cleared");
            error_found = 1'b1;
        end


        if (pending_expected === '0 &&
            pending_expected_valid !== 1'b0)
        begin
            $display("FAIL: Invalid pending scoreboard state");
            error_found = 1'b1;
        end


        // Final result.
        if (error_found)
        begin
            $display("FAIL: Scoreboard reset check failed");
        end
        else
        begin
            $display("PASS: Scoreboard cleared");
        end

    endfunction

    //=========================================================
    // Print Statistics
    //=========================================================

    function void print_statistics();

        $display("\n=================================");
        $display("       SCOREBOARD SUMMARY");
        $display("=================================");
        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);
        $display("SKIP COUNT = %0d", skip_count);
        $display("=================================");

    endfunction

    //=========================================================
    // Final Pass / Fail Result
    //=========================================================

    function bit passed();

        return (fail_count == 0);

    endfunction

endclass
