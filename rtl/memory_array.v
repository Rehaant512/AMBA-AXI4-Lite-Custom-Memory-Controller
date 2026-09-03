`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:19:30
// Design Name: 
// Module Name: memory_array
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
module memory_array #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 10
) (
    input  wire clk,
    input  wire we,
    input  wire [(DATA_WIDTH/8)-1:0] wstrb,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire re,                          // NEW
    input  wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] rdata
);

    reg [DATA_WIDTH-1:0] mem [(1<<(ADDR_WIDTH-2))-1:0];
    reg [DATA_WIDTH-1:0] rdata_r;             // NEW
    integer i;

    always @(posedge clk) begin
        if (we) begin
            for (i = 0; i < (DATA_WIDTH/8); i = i + 1) begin
                if (wstrb[i]) begin
                    mem[waddr[ADDR_WIDTH-1:2]][(i*8) +: 8] <= wdata[(i*8) +: 8];
                end
            end
        end
    end

    always @(posedge clk) begin               // NEW block
        if (re)
            rdata_r <= mem[raddr[ADDR_WIDTH-1:2]];
    end

    assign rdata = rdata_r;                   // was: assign rdata = mem[raddr[...]];

endmodule