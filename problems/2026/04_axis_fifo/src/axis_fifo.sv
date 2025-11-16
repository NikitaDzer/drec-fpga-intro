module axis_fifo #(
    parameter DATA_WIDTH  = 32,
    parameter DEPTH       = 8,
    parameter TID_WIDTH   = 8,
    parameter TDEST_WIDTH = 4,
    parameter TUSER_WIDTH = 4
) (
    input  wire                      clk,
    input  wire                      rst_n,
    
    // Slave interface
    input  wire                      s_axis_tvalid,
    output wire                      s_axis_tready,
    input  wire [DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axis_tstrb,
    input  wire [(DATA_WIDTH/8)-1:0] s_axis_tkeep,
    input  wire                      s_axis_tlast,
    input  wire [TID_WIDTH-1:0]      s_axis_tid,
    input  wire [TDEST_WIDTH-1:0]    s_axis_tdest,
    input  wire [TUSER_WIDTH-1:0]    s_axis_tuser,
    
    // Master interface
    output wire                      m_axis_tvalid,
    input  wire                      m_axis_tready,
    output wire [DATA_WIDTH-1:0]     m_axis_tdata,
    output wire [(DATA_WIDTH/8)-1:0] m_axis_tstrb,
    output wire [(DATA_WIDTH/8)-1:0] m_axis_tkeep,
    output wire                      m_axis_tlast,
    output wire [TID_WIDTH-1:0]      m_axis_tid,
    output wire [TDEST_WIDTH-1:0]    m_axis_tdest,
    output wire [TUSER_WIDTH-1:0]    m_axis_tuser
);

localparam ADDR_WIDTH = $clog2(DEPTH);
localparam TSTRB_WIDTH = DATA_WIDTH/8;

typedef struct packed {
    reg [DATA_WIDTH-1:0]   tdata;
    reg [TSTRB_WIDTH-1:0]  tstrb;
    reg [TSTRB_WIDTH-1:0]  tkeep;
    reg                    tlast;
    reg [TID_WIDTH-1:0]    tid;
    reg [TDEST_WIDTH-1:0]  tdest;
    reg [TUSER_WIDTH-1:0]  tuser;
} fifo_entry_t;

// FIFO entries
fifo_entry_t mem [0:DEPTH-1];

// Pointers to iterate over FIFO
reg [ADDR_WIDTH-1:0] wr_ptr = 0;
reg [ADDR_WIDTH-1:0] rd_ptr = 0;
reg [ADDR_WIDTH:0]   count = 0;

wire full  = (count == DEPTH);
wire empty = (count == 0);

reg wait_clk_after_rst_n = 0;
assign s_axis_tready = !full & !wait_clk_after_rst_n;
assign m_axis_tvalid = !empty & !wait_clk_after_rst_n;

// Permit writing in/reading from FIFO
wire wr_en = s_axis_tvalid & s_axis_tready & !full;
wire rd_en = m_axis_tvalid & m_axis_tready & !empty;

// Send data to slave
assign m_axis_tdata = mem[ rd_ptr ].tdata;
assign m_axis_tstrb = mem[ rd_ptr ].tstrb;
assign m_axis_tkeep = mem[ rd_ptr ].tkeep;
assign m_axis_tlast = mem[ rd_ptr ].tlast;
assign m_axis_tid   = mem[ rd_ptr ].tid;
assign m_axis_tdest = mem[ rd_ptr ].tdest;
assign m_axis_tuser = mem[ rd_ptr ].tuser;

// Receive entry from master, update write pointer
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 0;
    end
    else if (wr_en) begin
        mem[ wr_ptr ].tdata <= s_axis_tdata;
        mem[ wr_ptr ].tstrb <= s_axis_tstrb;
        mem[ wr_ptr ].tkeep <= s_axis_tkeep;
        mem[ wr_ptr ].tlast <= s_axis_tlast;
        mem[ wr_ptr ].tid   <= s_axis_tid;
        mem[ wr_ptr ].tdest <= s_axis_tdest;
        mem[ wr_ptr ].tuser <= s_axis_tuser;
        
        wr_ptr <= wr_ptr + 1;
    end
end

// Update read pointer
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= 0;
    end
    else if (rd_en) begin
        rd_ptr <= rd_ptr + 1;
    end
end

// FIFO counter
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
    end
    else begin
        unique case ({wr_en, rd_en})
            2'b10: count <= count + 1; // Write only
            2'b01: count <= count - 1; // Read only
            default: count <= count;   // Simultaneous read/write or no changes
        endcase
    end
end

// Ensure TREADY and TVALID are 0 after reset and before clk
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wait_clk_after_rst_n <= 1;
    end
    else begin
        wait_clk_after_rst_n <= 0;
    end
end

endmodule
