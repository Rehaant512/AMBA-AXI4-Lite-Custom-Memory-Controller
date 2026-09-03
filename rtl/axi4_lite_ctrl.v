`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:22:24
// Design Name: 
// Module Name: axi4_lite_ctrl
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
module axi4_lite_ctrl #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 10
    
)(
    input  wire S_AXI_ACLK,
    input  wire S_AXI_ARESETN,
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR, 
    input wire S_AXI_AWVALID, 
    output reg S_AXI_AWREADY,
    input  wire [DATA_WIDTH-1:0] S_AXI_WDATA, 
    input wire [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB, 
    input wire S_AXI_WVALID, 
    output reg S_AXI_WREADY,
    output reg  [1:0] S_AXI_BRESP, 
    output reg S_AXI_BVALID, 
    input wire S_AXI_BREADY,
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR, 
    input wire S_AXI_ARVALID, 
    output reg S_AXI_ARREADY,
    output reg  [DATA_WIDTH-1:0] S_AXI_RDATA, 
    output reg [1:0] S_AXI_RRESP, 
    output reg S_AXI_RVALID, 
    input wire S_AXI_RREADY,
    
    output wire mem_we,
    output wire [(DATA_WIDTH/8)-1:0] mem_wstrb,
    output wire [ADDR_WIDTH-1:0]     mem_waddr,
    output wire [DATA_WIDTH-1:0]     mem_wdata,
    output wire [ADDR_WIDTH-1:0]     mem_raddr,
    input  wire [DATA_WIDTH-1:0]     mem_rdata,
    output wire mem_re
);    
    reg [ADDR_WIDTH-1:0] axi_awaddr;
    reg [ADDR_WIDTH-1:0] axi_araddr;
    reg aw_en;

    localparam [ADDR_WIDTH-1:0] ADDR_LIMIT = 10'h200; 
    wire aw_addr_valid = (S_AXI_AWADDR < ADDR_LIMIT);
    wire ar_addr_valid = (S_AXI_ARADDR < ADDR_LIMIT);
    reg  axi_awaddr_valid;
    reg  axi_araddr_valid;
    
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_AWREADY <= 1'b0; aw_en <= 1'b1; axi_awaddr <= 0; axi_awaddr_valid <= 1'b0;
        end else if (~S_AXI_AWREADY && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
            S_AXI_AWREADY <= 1'b1; aw_en <= 1'b0; axi_awaddr <= S_AXI_AWADDR; axi_awaddr_valid <= aw_addr_valid;
        end else if (S_AXI_BREADY && S_AXI_BVALID) begin
            S_AXI_AWREADY <= 1'b0; aw_en <= 1'b1;
        end else S_AXI_AWREADY <= 1'b0;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) S_AXI_WREADY <= 1'b0;
        else if (~S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWVALID && aw_en) S_AXI_WREADY <= 1'b1;
        else S_AXI_WREADY <= 1'b0;
    end

    assign mem_we = S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWREADY && S_AXI_AWVALID && axi_awaddr_valid;
    assign mem_wstrb = S_AXI_WSTRB;
    assign mem_waddr = axi_awaddr;
    assign mem_wdata = S_AXI_WDATA;
    
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_BVALID <= 1'b0; S_AXI_BRESP <= 2'b00;
        end else if (S_AXI_AWREADY && ~S_AXI_BVALID && ~axi_awaddr_valid) begin
            S_AXI_BVALID <= 1'b1; S_AXI_BRESP <= 2'b10;
        end else if (mem_we && ~S_AXI_BVALID) begin
            S_AXI_BVALID <= 1'b1; S_AXI_BRESP <= 2'b00;
        end else if (S_AXI_BREADY && S_AXI_BVALID) S_AXI_BVALID <= 1'b0;
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_ARREADY <= 1'b0; axi_araddr <= 0; axi_araddr_valid <= 1'b0;
        end else if (~S_AXI_ARREADY && S_AXI_ARVALID) begin
            S_AXI_ARREADY <= 1'b1; axi_araddr <= S_AXI_ARADDR; axi_araddr_valid <= ar_addr_valid;
        end else S_AXI_ARREADY <= 1'b0;
    end

    assign mem_raddr = axi_araddr;
    assign mem_re = S_AXI_ARREADY;
    
reg mem_re_d;
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN)
        mem_re_d <= 1'b0;
    else
        mem_re_d <= mem_re;
end

    always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_RVALID <= 1'b0; S_AXI_RRESP <= 2'b00; S_AXI_RDATA <= 0;
            end else if (mem_re_d && ~S_AXI_RVALID) begin
            S_AXI_RVALID <= 1'b1; S_AXI_RRESP <= axi_araddr_valid ? 2'b00 : 2'b10; S_AXI_RDATA <= axi_araddr_valid ? mem_rdata : 32'hDEADDEAD;
    end else if (S_AXI_RREADY && S_AXI_RVALID) S_AXI_RVALID <= 1'b0;
end

endmodule
