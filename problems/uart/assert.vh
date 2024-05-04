`ifndef ASSERT_VH
`define ASSERT_VH

`define assert( condition )                                     \
        if ( !(condition) )                                     \
        begin                                                   \
            $display("ASSERTION FAILED in %m: signal != value");\
            $finish;                                            \
        end

`endif // ASSERT_VH
