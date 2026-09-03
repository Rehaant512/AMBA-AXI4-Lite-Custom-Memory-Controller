`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:31:01
// Design Name: 
// Module Name: axi4_lite_tb
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
module axi4_lite_tb;

    parameter integer DATA_WIDTH = 32;
    parameter integer ADDR_WIDTH = 10;

    reg S_AXI_ACLK;
    reg S_AXI_ARESETN;
    reg [ADDR_WIDTH-1:0] S_AXI_AWADDR;
    reg S_AXI_AWVALID;
    wire S_AXI_AWREADY;

    reg  [DATA_WIDTH-1:0] S_AXI_WDATA;
    reg  [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB;
    reg S_AXI_WVALID;
    
    wire S_AXI_WREADY;
    wire [1:0] S_AXI_BRESP;
    wire S_AXI_BVALID;
    reg S_AXI_BREADY;
    
    reg [ADDR_WIDTH-1:0] S_AXI_ARADDR;
    reg S_AXI_ARVALID;
    wire S_AXI_ARREADY;
    
    wire [DATA_WIDTH-1:0] S_AXI_RDATA;
    wire [1:0]S_AXI_RRESP;
    wire S_AXI_RVALID;
    reg S_AXI_RREADY;

    axi4_lite_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR), .S_AXI_AWVALID(S_AXI_AWVALID), .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA), .S_AXI_WSTRB(S_AXI_WSTRB), .S_AXI_WVALID(S_AXI_WVALID), .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP), .S_AXI_BVALID(S_AXI_BVALID), .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR), .S_AXI_ARVALID(S_AXI_ARVALID), .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA), .S_AXI_RRESP(S_AXI_RRESP), .S_AXI_RVALID(S_AXI_RVALID), .S_AXI_RREADY(S_AXI_RREADY)
    );

    initial begin
        S_AXI_ACLK = 0;
        forever #2.5 S_AXI_ACLK = ~S_AXI_ACLK;
    end

    task axi_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_AWADDR  <= addr;
            S_AXI_AWVALID <= 1;
            S_AXI_WDATA   <= data;
            S_AXI_WSTRB   <= 4'b1111; 
            S_AXI_WVALID  <= 1;
            S_AXI_BREADY  <= 1;

            wait (S_AXI_AWREADY && S_AXI_WREADY);
            @(posedge S_AXI_ACLK);
            S_AXI_AWVALID <= 0;
            S_AXI_WVALID  <= 0;
            wait (S_AXI_BVALID);
            @(posedge S_AXI_ACLK);
            if (S_AXI_BRESP == 2'b00)
            $display("Write Success! Addr 0x%0h: 0x%0h", addr, data);
            else
            $display("Write Failed! SLVERR at Addr 0x%0h", addr);
            S_AXI_BREADY <= 0;
    end
    endtask
    
    
    task axi_read;
        input [ADDR_WIDTH-1:0] addr;
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_ARADDR  <= addr;
            S_AXI_ARVALID <= 1;
            S_AXI_RREADY  <= 1;

            wait (S_AXI_ARREADY);
            @(posedge S_AXI_ACLK);
            S_AXI_ARVALID <= 0;

            wait (S_AXI_RVALID);
            @(posedge S_AXI_ACLK);
            
            if (S_AXI_RRESP == 2'b00)
             $display("Read Success! Data at Addr 0x%0h: 0x%0h", addr, S_AXI_RDATA);
          else
             $display("Read Failed! SLVERR at Addr 0x%0h", addr);
            S_AXI_RREADY <= 0;
        end
    endtask

    initial begin
        S_AXI_ARESETN <= 0;
        S_AXI_AWADDR <= 0; S_AXI_AWVALID <= 0;
        S_AXI_WDATA <= 0; S_AXI_WSTRB <= 0; S_AXI_WVALID <= 0; S_AXI_BREADY <= 0;
        S_AXI_ARADDR <= 0; S_AXI_ARVALID <= 0; S_AXI_RREADY <= 0;

        #20;
        S_AXI_ARESETN = 1;
        #20;

        $display("--- Starting AXI4-Lite Transactions ---");

     axi_write(10'h004, 32'hDEADBEEF);
     
     axi_write(10'h008, 32'hCAFEBABE);

    axi_read(10'h004);

    axi_read(10'h008);

    $display("--- Testing valid boundary address ---");
    axi_write(10'h1F0, 32'h600DF00D);
    axi_read(10'h1F0);

    $display("--- Testing out-of-range address (expect SLVERR) ---");
    axi_write(10'h3F0, 32'hBADBAD00);
    axi_read(10'h3F0);

    $display("--- Verifying in-range data was not corrupted ---");
    axi_read(10'h1F0);

    $display("--- Simulation Complete ---");
        $finish;
    end

endmodule