class register_file_monitor
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
);

    //=========================================================
    // Virtual Interface
    //=========================================================
    virtual register_file_if #(DATA_WIDTH, ADDR_WIDTH) vif;


    //=========================================================
    // Monitor State
    //=========================================================

    // Indicates that a previous read request is waiting
    // for its registered read-data response.
    logic pending_valid;

    // Address associated with the pending read
    logic [ADDR_WIDTH-1:0] pending_addr;

    //=========================================================
    // Synchronization Event
    //=========================================================
    event monitor_done;

    //=========================================================
    // Constructor
    //=========================================================
    function new
    (
        virtual register_file_if #(DATA_WIDTH, ADDR_WIDTH) vif
    );
        this.vif = vif;

        pending_valid = 1'b0;
        pending_addr  = '0;
    endfunction

    //=========================================================
    // Run Monitor
    //=========================================================
    task run();
    begin

        forever
        begin

            @(posedge vif.clk);

            // Allow DUT NBA updates to settle
            #1;

            //=================================================
            // Complete Previous Read
            //=================================================
            if (pending_valid)
            begin

                $display(
                    "[%0t] MONITOR : "
                    "Read Response Address = %0d "
                    "Data = %0h",
                    $time,
                    pending_addr,
                    vif.rd_data
                );

                pending_valid = 1'b0;

                // Inform test/scoreboard that the response
                // corresponding to the previous read is ready.
                -> monitor_done;

            end

            //=================================================
            // Capture New Read Request
            //=================================================
            if (vif.rd_en)
            begin

                pending_addr  = vif.rd_addr;
                pending_valid = 1'b1;

                $display(
                    "[%0t] MONITOR : "
                    "Read Request Address = %0d",
                    $time,
                    vif.rd_addr
                );

            end

        end

    end
    endtask

    //=========================================================
    // Wait For Monitor Completion
    //=========================================================
    task automatic wait_for_monitor();
    begin
        @monitor_done;
    end
    endtask

endclass
