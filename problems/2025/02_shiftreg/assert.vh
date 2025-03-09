`ifndef ASSERT_VH
`define ASSERT_VH

`define assert( condition )                                             \
        if ( !(condition) )                                             \
        begin                                                           \
            $display("[%t] ASSERTION FAILED in %m: signal != value",    \
                      $realtime);                                       \
            $finish;                                                    \
        end

`endif // ASSERT_VH
