`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 13:53:19
// Design Name: 
// Module Name: axi4_lite_slave
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
module axi4_lite_slave #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 10  
)(
    input  wire S_AXI_ACLK,    
    input  wire S_AXI_ARESETN, 
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR,  
    input  wire S_AXI_AWVALID,
    output reg S_AXI_AWREADY, 
    input  wire [DATA_WIDTH-1:0]    S_AXI_WDATA,  
    input  wire [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB, 
    input  wire S_AXI_WVALID, 
    output reg S_AXI_WREADY, 
    output reg [1:0] S_AXI_BRESP,   
    output reg S_AXI_BVALID,
    input  wire S_AXI_BREADY,  
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,  
    input  wire S_AXI_ARVALID, 
    output reg S_AXI_ARREADY, 
    output reg [DATA_WIDTH-1:0] S_AXI_RDATA,   
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input  wire S_AXI_RREADY 
);

    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0]; 
    reg [ADDR_WIDTH-1:0] axi_awaddr;
    reg [ADDR_WIDTH-1:0] axi_araddr;

endmodule
