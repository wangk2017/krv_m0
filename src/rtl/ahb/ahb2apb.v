//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Thu Nov 15 18:19:31 2018
// Version: v11.9 SP1 11.9.1.0
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// ahb2apb
module ahb2apb(
    // Inputs
    HADDR,
    HCLK,
    HREADY,
    HRESETN,
    HSEL,
    HTRANS,
    HWDATA,
    HWRITE,
    PRDATA,
    PREADY,
    PSLVERR,
    // Outputs
    HRDATA,
    HREADYOUT,
    HRESP,
    PADDR,
    PENABLE,
    PSEL,
    PWDATA,
    PWRITE
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [31:0] HADDR;
input         HCLK;
input         HREADY;
input         HRESETN;
input         HSEL;
input  [1:0]  HTRANS;
input  [31:0] HWDATA;
input         HWRITE;
input  [31:0] PRDATA;
input         PREADY;
input         PSLVERR;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] HRDATA;
output        HREADYOUT;
output [1:0]  HRESP;
output [31:0] PADDR;
output        PENABLE;
output        PSEL;
output [31:0] PWDATA;
output        PWRITE;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] HADDR;
wire   [31:0] AHBslave_HRDATA;
wire          HREADY;
wire          AHBslave_HREADYOUT;
wire   [1:0]  AHBslave_HRESP;
wire          HSEL;
wire   [1:0]  HTRANS;
wire   [31:0] HWDATA;
wire          HWRITE;
wire   [31:0] APBmaster_PADDR;
wire          APBmaster_PENABLE;
wire   [31:0] PRDATA;
wire          PREADY;
wire          APBmaster_PSELx;
wire          PSLVERR;
wire   [31:0] APBmaster_PWDATA;
wire          APBmaster_PWRITE;
wire          HCLK;
wire          HRESETN;
wire          AHBslave_HREADYOUT_net_0;
wire          APBmaster_PSELx_net_0;
wire          APBmaster_PENABLE_net_0;
wire          APBmaster_PWRITE_net_0;
wire   [31:0] AHBslave_HRDATA_net_0;
wire   [1:0]  AHBslave_HRESP_net_0;
wire   [31:0] APBmaster_PADDR_net_0;
wire   [31:0] APBmaster_PWDATA_net_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign AHBslave_HREADYOUT_net_0 = AHBslave_HREADYOUT;
assign HREADYOUT                = AHBslave_HREADYOUT_net_0;
assign APBmaster_PSELx_net_0    = APBmaster_PSELx;
assign PSEL                     = APBmaster_PSELx_net_0;
assign APBmaster_PENABLE_net_0  = APBmaster_PENABLE;
assign PENABLE                  = APBmaster_PENABLE_net_0;
assign APBmaster_PWRITE_net_0   = APBmaster_PWRITE;
assign PWRITE                   = APBmaster_PWRITE_net_0;
assign AHBslave_HRDATA_net_0    = AHBslave_HRDATA;
assign HRDATA[31:0]             = AHBslave_HRDATA_net_0;
assign AHBslave_HRESP_net_0     = AHBslave_HRESP;
assign HRESP[1:0]               = AHBslave_HRESP_net_0;
assign APBmaster_PADDR_net_0    = APBmaster_PADDR;
assign PADDR[31:0]              = APBmaster_PADDR_net_0;
assign APBmaster_PWDATA_net_0   = APBmaster_PWDATA;
assign PWDATA[31:0]             = APBmaster_PWDATA_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREAHBTOAPB3   -   Actel:DirectCore:COREAHBTOAPB3:3.1.100
COREAHBTOAPB3 #( 
        .FAMILY ( 19 ) )
ahb2apb_0(
        // Inputs
        .HCLK      ( HCLK ),
        .HRESETN   ( HRESETN ),
        .HWRITE    ( HWRITE ),
        .HSEL      ( HSEL ),
        .HREADY    ( HREADY ),
        .PREADY    ( PREADY ),
        .PSLVERR   ( PSLVERR ),
        .HADDR     ( HADDR ),
        .HTRANS    ( HTRANS ),
        .HWDATA    ( HWDATA ),
        .PRDATA    ( PRDATA ),
        // Outputs
        .HREADYOUT ( AHBslave_HREADYOUT ),
        .PENABLE   ( APBmaster_PENABLE ),
        .PWRITE    ( APBmaster_PWRITE ),
        .PSEL      ( APBmaster_PSELx ),
        .HRDATA    ( AHBslave_HRDATA ),
        .HRESP     ( AHBslave_HRESP ),
        .PWDATA    ( APBmaster_PWDATA ),
        .PADDR     ( APBmaster_PADDR ) 
        );


endmodule
