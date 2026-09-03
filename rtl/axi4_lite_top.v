
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:24:57
// Design Name: 
// Module Name: axi4_lite_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module axi4_lite_top #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 10
)(
    input  wire S_AXI_ACLK,
    input  wire S_AXI_ARESETN,
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR, 
    input wire S_AXI_AWVALID, 
    output wire S_AXI_AWREADY,
    input  wire [DATA_WIDTH-1:0] S_AXI_WDATA, 
    input wire [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB, 
    input wire S_AXI_WVALID, 
    output wire S_AXI_WREADY,
    output wire [1:0] S_AXI_BRESP, 
    output wire S_AXI_BVALID, 
    input wire S_AXI_BREADY,
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR, 
    input wire S_AXI_ARVALID, 
    output wire S_AXI_ARREADY,
    output wire [DATA_WIDTH-1:0] S_AXI_RDATA, 
    output wire [1:0] S_AXI_RRESP, 
    output wire S_AXI_RVALID, 
    input wire S_AXI_RREADY
);

    wire int_we;
    wire int_re;
    wire [(DATA_WIDTH/8)-1:0] int_wstrb;
    wire [ADDR_WIDTH-1:0]     int_waddr;
    wire [DATA_WIDTH-1:0]     int_wdata;
    wire [ADDR_WIDTH-1:0]     int_raddr;
    wire [DATA_WIDTH-1:0]     int_rdata;

    axi4_lite_ctrl #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_axi_ctrl (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR), .S_AXI_AWVALID(S_AXI_AWVALID), .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA), .S_AXI_WSTRB(S_AXI_WSTRB), .S_AXI_WVALID(S_AXI_WVALID), .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP), .S_AXI_BVALID(S_AXI_BVALID), .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR), .S_AXI_ARVALID(S_AXI_ARVALID), .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA), .S_AXI_RRESP(S_AXI_RRESP), .S_AXI_RVALID(S_AXI_RVALID), .S_AXI_RREADY(S_AXI_RREADY),
        .mem_we(int_we),
        .mem_wstrb(int_wstrb),
        .mem_waddr(int_waddr),
        .mem_wdata(int_wdata),
        .mem_raddr(int_raddr),
        .mem_rdata(int_rdata),
        .mem_re(int_re)
    );

    memory_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mem_array (
        .clk(S_AXI_ACLK),
        .we(int_we),
        .wstrb(int_wstrb),
        .waddr(int_waddr),
        .wdata(int_wdata),
        .raddr(int_raddr),
        .rdata(int_rdata),
        .re(int_re)
    );

endmodule
