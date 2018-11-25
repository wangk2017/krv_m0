//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Sun Nov 18 03:44:33 2018
// Version: v11.9 SP1 11.9.1.0
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// flash_ss
module flash_ss(
    // Inputs
    DEVRST_N,
    FAB_RESET_N,
    FIC_0_AHB_S_HADDR,
    FIC_0_AHB_S_HMASTLOCK,
    FIC_0_AHB_S_HREADY,
    FIC_0_AHB_S_HSEL,
    FIC_0_AHB_S_HSIZE,
    FIC_0_AHB_S_HTRANS,
    FIC_0_AHB_S_HWDATA,
    FIC_0_AHB_S_HWRITE,
    MSS_INT_F2M,
    // Outputs
    FIC_0_AHB_S_HRDATA,
    FIC_0_AHB_S_HREADYOUT,
    FIC_0_AHB_S_HRESP,
    FIC_0_CLK,
    FIC_0_LOCK,
    INIT_DONE,
    MSS_READY,
    POWER_ON_RESET_N
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         DEVRST_N;
input         FAB_RESET_N;
input  [31:0] FIC_0_AHB_S_HADDR;
input         FIC_0_AHB_S_HMASTLOCK;
input         FIC_0_AHB_S_HREADY;
input         FIC_0_AHB_S_HSEL;
input  [1:0]  FIC_0_AHB_S_HSIZE;
input  [1:0]  FIC_0_AHB_S_HTRANS;
input  [31:0] FIC_0_AHB_S_HWDATA;
input         FIC_0_AHB_S_HWRITE;
input  [15:0] MSS_INT_F2M;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] FIC_0_AHB_S_HRDATA;
output        FIC_0_AHB_S_HREADYOUT;
output        FIC_0_AHB_S_HRESP;
output        FIC_0_CLK;
output        FIC_0_LOCK;
output        INIT_DONE;
output        MSS_READY;
output        POWER_ON_RESET_N;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CORERESETP_0_RESET_N_F2M;
wire          DEVRST_N;
wire          FAB_RESET_N;
wire          FABOSC_0_RCOSC_1MHZ_CCC_OUT_RCOSC_1MHZ_CCC;
wire          FABOSC_0_RCOSC_25_50MHZ_O2F;
wire   [31:0] FIC_0_AHB_S_HADDR;
wire          FIC_0_AHB_S_HMASTLOCK;
wire   [31:0] FIC_0_AMBA_SLAVE_HRDATA;
wire          FIC_0_AHB_S_HREADY;
wire          FIC_0_AMBA_SLAVE_HREADYOUT;
wire          FIC_0_AMBA_SLAVE_HRESP;
wire          FIC_0_AHB_S_HSEL;
wire   [1:0]  FIC_0_AHB_S_HSIZE;
wire   [1:0]  FIC_0_AHB_S_HTRANS;
wire   [31:0] FIC_0_AHB_S_HWDATA;
wire          FIC_0_AHB_S_HWRITE;
wire          FIC_0_CLK_net_0;
wire          FIC_0_LOCK_net_0;
wire          flash_ss_MSS_TMP_0_FIC_2_APB_M_PRESET_N;
wire          flash_ss_MSS_TMP_0_MSS_RESET_N_M2F;
wire          INIT_DONE_net_0;
wire   [15:0] MSS_INT_F2M;
wire          MSS_READY_net_0;
wire          POWER_ON_RESET_N_net_0;
wire          POWER_ON_RESET_N_net_1;
wire          INIT_DONE_net_1;
wire          FIC_0_CLK_net_1;
wire          FIC_0_LOCK_net_1;
wire          MSS_READY_net_1;
wire   [31:0] FIC_0_AMBA_SLAVE_HRDATA_net_0;
wire          FIC_0_AMBA_SLAVE_HREADYOUT_net_0;
wire          FIC_0_AMBA_SLAVE_HRESP_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          VCC_net;
wire          GND_net;
wire   [7:2]  PADDR_const_net_0;
wire   [7:0]  PWDATA_const_net_0;
wire   [31:0] SDIF0_PRDATA_const_net_0;
wire   [31:0] SDIF1_PRDATA_const_net_0;
wire   [31:0] SDIF2_PRDATA_const_net_0;
wire   [31:0] SDIF3_PRDATA_const_net_0;
wire   [31:0] FIC_2_APB_M_PRDATA_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign VCC_net                        = 1'b1;
assign GND_net                        = 1'b0;
assign PADDR_const_net_0              = 6'h00;
assign PWDATA_const_net_0             = 8'h00;
assign SDIF0_PRDATA_const_net_0       = 32'h00000000;
assign SDIF1_PRDATA_const_net_0       = 32'h00000000;
assign SDIF2_PRDATA_const_net_0       = 32'h00000000;
assign SDIF3_PRDATA_const_net_0       = 32'h00000000;
assign FIC_2_APB_M_PRDATA_const_net_0 = 32'h00000000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign POWER_ON_RESET_N_net_1           = POWER_ON_RESET_N_net_0;
assign POWER_ON_RESET_N                 = POWER_ON_RESET_N_net_1;
assign INIT_DONE_net_1                  = INIT_DONE_net_0;
assign INIT_DONE                        = INIT_DONE_net_1;
assign FIC_0_CLK_net_1                  = FIC_0_CLK_net_0;
assign FIC_0_CLK                        = FIC_0_CLK_net_1;
assign FIC_0_LOCK_net_1                 = FIC_0_LOCK_net_0;
assign FIC_0_LOCK                       = FIC_0_LOCK_net_1;
assign MSS_READY_net_1                  = MSS_READY_net_0;
assign MSS_READY                        = MSS_READY_net_1;
assign FIC_0_AMBA_SLAVE_HRDATA_net_0    = FIC_0_AMBA_SLAVE_HRDATA;
assign FIC_0_AHB_S_HRDATA[31:0]         = FIC_0_AMBA_SLAVE_HRDATA_net_0;
assign FIC_0_AMBA_SLAVE_HREADYOUT_net_0 = FIC_0_AMBA_SLAVE_HREADYOUT;
assign FIC_0_AHB_S_HREADYOUT            = FIC_0_AMBA_SLAVE_HREADYOUT_net_0;
assign FIC_0_AMBA_SLAVE_HRESP_net_0     = FIC_0_AMBA_SLAVE_HRESP;
assign FIC_0_AHB_S_HRESP                = FIC_0_AMBA_SLAVE_HRESP_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------flash_ss_CCC_0_FCCC   -   Actel:SgCore:FCCC:2.0.201
flash_ss_CCC_0_FCCC CCC_0(
        // Inputs
        .RCOSC_1MHZ ( FABOSC_0_RCOSC_1MHZ_CCC_OUT_RCOSC_1MHZ_CCC ),
        // Outputs
        .GL0        ( FIC_0_CLK_net_0 ),
        .LOCK       ( FIC_0_LOCK_net_0 ) 
        );

//--------CoreResetP   -   Actel:DirectCore:CoreResetP:7.1.100
CoreResetP #( 
        .DDR_WAIT            ( 200 ),
        .DEVICE_090          ( 0 ),
        .DEVICE_VOLTAGE      ( 2 ),
        .ENABLE_SOFT_RESETS  ( 0 ),
        .EXT_RESET_CFG       ( 0 ),
        .FDDR_IN_USE         ( 0 ),
        .MDDR_IN_USE         ( 0 ),
        .SDIF0_IN_USE        ( 0 ),
        .SDIF0_PCIE          ( 0 ),
        .SDIF0_PCIE_HOTRESET ( 1 ),
        .SDIF0_PCIE_L2P2     ( 1 ),
        .SDIF1_IN_USE        ( 0 ),
        .SDIF1_PCIE          ( 0 ),
        .SDIF1_PCIE_HOTRESET ( 1 ),
        .SDIF1_PCIE_L2P2     ( 1 ),
        .SDIF2_IN_USE        ( 0 ),
        .SDIF2_PCIE          ( 0 ),
        .SDIF2_PCIE_HOTRESET ( 1 ),
        .SDIF2_PCIE_L2P2     ( 1 ),
        .SDIF3_IN_USE        ( 0 ),
        .SDIF3_PCIE          ( 0 ),
        .SDIF3_PCIE_HOTRESET ( 1 ),
        .SDIF3_PCIE_L2P2     ( 1 ) )
CORERESETP_0(
        // Inputs
        .RESET_N_M2F                    ( flash_ss_MSS_TMP_0_MSS_RESET_N_M2F ),
        .FIC_2_APB_M_PRESET_N           ( flash_ss_MSS_TMP_0_FIC_2_APB_M_PRESET_N ),
        .POWER_ON_RESET_N               ( POWER_ON_RESET_N_net_0 ),
        .FAB_RESET_N                    ( FAB_RESET_N ),
        .RCOSC_25_50MHZ                 ( FABOSC_0_RCOSC_25_50MHZ_O2F ),
        .CLK_BASE                       ( FIC_0_CLK_net_0 ),
        .CLK_LTSSM                      ( GND_net ), // tied to 1'b0 from definition
        .FPLL_LOCK                      ( VCC_net ), // tied to 1'b1 from definition
        .SDIF0_SPLL_LOCK                ( VCC_net ), // tied to 1'b1 from definition
        .SDIF1_SPLL_LOCK                ( VCC_net ), // tied to 1'b1 from definition
        .SDIF2_SPLL_LOCK                ( VCC_net ), // tied to 1'b1 from definition
        .SDIF3_SPLL_LOCK                ( VCC_net ), // tied to 1'b1 from definition
        .CONFIG1_DONE                   ( VCC_net ),
        .CONFIG2_DONE                   ( VCC_net ),
        .SDIF0_PERST_N                  ( VCC_net ), // tied to 1'b1 from definition
        .SDIF1_PERST_N                  ( VCC_net ), // tied to 1'b1 from definition
        .SDIF2_PERST_N                  ( VCC_net ), // tied to 1'b1 from definition
        .SDIF3_PERST_N                  ( VCC_net ), // tied to 1'b1 from definition
        .SDIF0_PSEL                     ( GND_net ), // tied to 1'b0 from definition
        .SDIF0_PWRITE                   ( VCC_net ), // tied to 1'b1 from definition
        .SDIF0_PRDATA                   ( SDIF0_PRDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SDIF1_PSEL                     ( GND_net ), // tied to 1'b0 from definition
        .SDIF1_PWRITE                   ( VCC_net ), // tied to 1'b1 from definition
        .SDIF1_PRDATA                   ( SDIF1_PRDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SDIF2_PSEL                     ( GND_net ), // tied to 1'b0 from definition
        .SDIF2_PWRITE                   ( VCC_net ), // tied to 1'b1 from definition
        .SDIF2_PRDATA                   ( SDIF2_PRDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SDIF3_PSEL                     ( GND_net ), // tied to 1'b0 from definition
        .SDIF3_PWRITE                   ( VCC_net ), // tied to 1'b1 from definition
        .SDIF3_PRDATA                   ( SDIF3_PRDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SOFT_EXT_RESET_OUT             ( GND_net ), // tied to 1'b0 from definition
        .SOFT_RESET_F2M                 ( GND_net ), // tied to 1'b0 from definition
        .SOFT_M3_RESET                  ( GND_net ), // tied to 1'b0 from definition
        .SOFT_MDDR_DDR_AXI_S_CORE_RESET ( GND_net ), // tied to 1'b0 from definition
        .SOFT_FDDR_CORE_RESET           ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF0_PHY_RESET           ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF0_CORE_RESET          ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF0_0_CORE_RESET        ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF0_1_CORE_RESET        ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF1_PHY_RESET           ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF1_CORE_RESET          ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF2_PHY_RESET           ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF2_CORE_RESET          ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF3_PHY_RESET           ( GND_net ), // tied to 1'b0 from definition
        .SOFT_SDIF3_CORE_RESET          ( GND_net ), // tied to 1'b0 from definition
        // Outputs
        .MSS_HPMS_READY                 ( MSS_READY_net_0 ),
        .DDR_READY                      (  ),
        .SDIF_READY                     (  ),
        .RESET_N_F2M                    ( CORERESETP_0_RESET_N_F2M ),
        .M3_RESET_N                     (  ),
        .EXT_RESET_OUT                  (  ),
        .MDDR_DDR_AXI_S_CORE_RESET_N    (  ),
        .FDDR_CORE_RESET_N              (  ),
        .SDIF0_CORE_RESET_N             (  ),
        .SDIF0_0_CORE_RESET_N           (  ),
        .SDIF0_1_CORE_RESET_N           (  ),
        .SDIF0_PHY_RESET_N              (  ),
        .SDIF1_CORE_RESET_N             (  ),
        .SDIF1_PHY_RESET_N              (  ),
        .SDIF2_CORE_RESET_N             (  ),
        .SDIF2_PHY_RESET_N              (  ),
        .SDIF3_CORE_RESET_N             (  ),
        .SDIF3_PHY_RESET_N              (  ),
        .SDIF_RELEASED                  (  ),
        .INIT_DONE                      ( INIT_DONE_net_0 ) 
        );

//--------flash_ss_FABOSC_0_OSC   -   Actel:SgCore:OSC:2.0.101
flash_ss_FABOSC_0_OSC FABOSC_0(
        // Inputs
        .XTL                ( GND_net ), // tied to 1'b0 from definition
        // Outputs
        .RCOSC_25_50MHZ_CCC (  ),
        .RCOSC_25_50MHZ_O2F ( FABOSC_0_RCOSC_25_50MHZ_O2F ),
        .RCOSC_1MHZ_CCC     ( FABOSC_0_RCOSC_1MHZ_CCC_OUT_RCOSC_1MHZ_CCC ),
        .RCOSC_1MHZ_O2F     (  ),
        .XTLOSC_CCC         (  ),
        .XTLOSC_O2F         (  ) 
        );

//--------flash_ss_MSS
flash_ss_MSS flash_ss_MSS_0(
        // Inputs
        .MCCC_CLK_BASE          ( FIC_0_CLK_net_0 ),
        .MCCC_CLK_BASE_PLL_LOCK ( FIC_0_LOCK_net_0 ),
        .MSS_RESET_N_F2M        ( CORERESETP_0_RESET_N_F2M ),
        .FIC_0_AHB_S_HREADY     ( FIC_0_AHB_S_HREADY ),
        .FIC_0_AHB_S_HWRITE     ( FIC_0_AHB_S_HWRITE ),
        .FIC_0_AHB_S_HMASTLOCK  ( FIC_0_AHB_S_HMASTLOCK ),
        .FIC_0_AHB_S_HSEL       ( FIC_0_AHB_S_HSEL ),
        .FIC_2_APB_M_PREADY     ( VCC_net ), // tied to 1'b1 from definition
        .FIC_2_APB_M_PSLVERR    ( GND_net ), // tied to 1'b0 from definition
        .FIC_0_AHB_S_HADDR      ( FIC_0_AHB_S_HADDR ),
        .FIC_0_AHB_S_HWDATA     ( FIC_0_AHB_S_HWDATA ),
        .FIC_0_AHB_S_HSIZE      ( FIC_0_AHB_S_HSIZE ),
        .FIC_0_AHB_S_HTRANS     ( FIC_0_AHB_S_HTRANS ),
        .FIC_2_APB_M_PRDATA     ( FIC_2_APB_M_PRDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MSS_INT_F2M            ( MSS_INT_F2M ),
        // Outputs
        .MSS_RESET_N_M2F        ( flash_ss_MSS_TMP_0_MSS_RESET_N_M2F ),
        .FIC_0_AHB_S_HRESP      ( FIC_0_AMBA_SLAVE_HRESP ),
        .FIC_0_AHB_S_HREADYOUT  ( FIC_0_AMBA_SLAVE_HREADYOUT ),
        .FIC_2_APB_M_PRESET_N   ( flash_ss_MSS_TMP_0_FIC_2_APB_M_PRESET_N ),
        .FIC_2_APB_M_PCLK       (  ),
        .FIC_2_APB_M_PWRITE     (  ),
        .FIC_2_APB_M_PENABLE    (  ),
        .FIC_2_APB_M_PSEL       (  ),
        .FIC_0_AHB_S_HRDATA     ( FIC_0_AMBA_SLAVE_HRDATA ),
        .FIC_2_APB_M_PADDR      (  ),
        .FIC_2_APB_M_PWDATA     (  ) 
        );

//--------SYSRESET
SYSRESET SYSRESET_POR(
        // Inputs
        .DEVRST_N         ( DEVRST_N ),
        // Outputs
        .POWER_ON_RESET_N ( POWER_ON_RESET_N_net_0 ) 
        );


endmodule
