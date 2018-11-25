`timescale 1 ns/100 ps
// Version: v11.9 SP1 11.9.1.0


module sram_4Kx32_sram_4Kx32_0_TPSRAM(
       WD,
       RD,
       WADDR,
       RADDR,
       WEN,
       CLK
    );
input  [31:0] WD;
output [31:0] RD;
input  [11:0] WADDR;
input  [11:0] RADDR;
input  WEN;
input  CLK;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C1 (.A_DOUT({nc0, nc1, 
        nc2, nc3, nc4, nc5, nc6, nc7, nc8, nc9, nc10, nc11, nc12, nc13, 
        RD[7], RD[6], RD[5], RD[4]}), .B_DOUT({nc14, nc15, nc16, nc17, 
        nc18, nc19, nc20, nc21, nc22, nc23, nc24, nc25, nc26, nc27, 
        nc28, nc29, nc30, nc31}), .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(
        VCC), .A_ARST_N(VCC), .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), 
        .A_DOUT_ARST_N(VCC), .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND}), .A_ADDR({RADDR[11], RADDR[10], RADDR[9], 
        RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], RADDR[3], 
        RADDR[2], RADDR[1], RADDR[0], GND, GND}), .A_WEN({GND, GND}), 
        .B_CLK(CLK), .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), 
        .B_BLK({WEN, VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(
        VCC), .B_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, WD[7], WD[6], WD[5], WD[4]}), .B_ADDR({
        WADDR[11], WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], 
        WADDR[5], WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], 
        GND, GND}), .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), 
        .A_WIDTH({GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), 
        .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), 
        .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C4 (.A_DOUT({nc32, nc33, 
        nc34, nc35, nc36, nc37, nc38, nc39, nc40, nc41, nc42, nc43, 
        nc44, nc45, RD[19], RD[18], RD[17], RD[16]}), .B_DOUT({nc46, 
        nc47, nc48, nc49, nc50, nc51, nc52, nc53, nc54, nc55, nc56, 
        nc57, nc58, nc59, nc60, nc61, nc62, nc63}), .BUSY(), .A_CLK(
        CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), .A_DOUT_EN(VCC), 
        .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), .A_DOUT_SRST_N(
        VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND}), .A_ADDR({RADDR[11], 
        RADDR[10], RADDR[9], RADDR[8], RADDR[7], RADDR[6], RADDR[5], 
        RADDR[4], RADDR[3], RADDR[2], RADDR[1], RADDR[0], GND, GND}), 
        .A_WEN({GND, GND}), .B_CLK(CLK), .B_DOUT_CLK(VCC), .B_ARST_N(
        VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, VCC, VCC}), .B_DOUT_ARST_N(
        GND), .B_DOUT_SRST_N(VCC), .B_DIN({GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, WD[19], WD[18], 
        WD[17], WD[16]}), .B_ADDR({WADDR[11], WADDR[10], WADDR[9], 
        WADDR[8], WADDR[7], WADDR[6], WADDR[5], WADDR[4], WADDR[3], 
        WADDR[2], WADDR[1], WADDR[0], GND, GND}), .B_WEN({GND, VCC}), 
        .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({GND, VCC, GND}), 
        .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), .B_WIDTH({GND, 
        VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C0 (.A_DOUT({nc64, nc65, 
        nc66, nc67, nc68, nc69, nc70, nc71, nc72, nc73, nc74, nc75, 
        nc76, nc77, RD[3], RD[2], RD[1], RD[0]}), .B_DOUT({nc78, nc79, 
        nc80, nc81, nc82, nc83, nc84, nc85, nc86, nc87, nc88, nc89, 
        nc90, nc91, nc92, nc93, nc94, nc95}), .BUSY(), .A_CLK(CLK), 
        .A_DOUT_CLK(VCC), .A_ARST_N(VCC), .A_DOUT_EN(VCC), .A_BLK({VCC, 
        VCC, VCC}), .A_DOUT_ARST_N(VCC), .A_DOUT_SRST_N(VCC), .A_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND}), .A_ADDR({RADDR[11], RADDR[10], 
        RADDR[9], RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], 
        RADDR[3], RADDR[2], RADDR[1], RADDR[0], GND, GND}), .A_WEN({
        GND, GND}), .B_CLK(CLK), .B_DOUT_CLK(VCC), .B_ARST_N(VCC), 
        .B_DOUT_EN(VCC), .B_BLK({WEN, VCC, VCC}), .B_DOUT_ARST_N(GND), 
        .B_DOUT_SRST_N(VCC), .B_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, WD[3], WD[2], WD[1], WD[0]})
        , .B_ADDR({WADDR[11], WADDR[10], WADDR[9], WADDR[8], WADDR[7], 
        WADDR[6], WADDR[5], WADDR[4], WADDR[3], WADDR[2], WADDR[1], 
        WADDR[0], GND, GND}), .B_WEN({GND, VCC}), .A_EN(VCC), 
        .A_DOUT_LAT(VCC), .A_WIDTH({GND, VCC, GND}), .A_WMODE(GND), 
        .B_EN(VCC), .B_DOUT_LAT(VCC), .B_WIDTH({GND, VCC, GND}), 
        .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C3 (.A_DOUT({nc96, nc97, 
        nc98, nc99, nc100, nc101, nc102, nc103, nc104, nc105, nc106, 
        nc107, nc108, nc109, RD[15], RD[14], RD[13], RD[12]}), .B_DOUT({
        nc110, nc111, nc112, nc113, nc114, nc115, nc116, nc117, nc118, 
        nc119, nc120, nc121, nc122, nc123, nc124, nc125, nc126, nc127})
        , .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .A_ADDR({RADDR[11], RADDR[10], RADDR[9], RADDR[8], RADDR[7], 
        RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, 
        VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, WD[15], WD[14], WD[13], WD[12]}), .B_ADDR({WADDR[11], 
        WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND}), 
        .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({
        GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C6 (.A_DOUT({nc128, nc129, 
        nc130, nc131, nc132, nc133, nc134, nc135, nc136, nc137, nc138, 
        nc139, nc140, nc141, RD[27], RD[26], RD[25], RD[24]}), .B_DOUT({
        nc142, nc143, nc144, nc145, nc146, nc147, nc148, nc149, nc150, 
        nc151, nc152, nc153, nc154, nc155, nc156, nc157, nc158, nc159})
        , .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .A_ADDR({RADDR[11], RADDR[10], RADDR[9], RADDR[8], RADDR[7], 
        RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, 
        VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, WD[27], WD[26], WD[25], WD[24]}), .B_ADDR({WADDR[11], 
        WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND}), 
        .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({
        GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C7 (.A_DOUT({nc160, nc161, 
        nc162, nc163, nc164, nc165, nc166, nc167, nc168, nc169, nc170, 
        nc171, nc172, nc173, RD[31], RD[30], RD[29], RD[28]}), .B_DOUT({
        nc174, nc175, nc176, nc177, nc178, nc179, nc180, nc181, nc182, 
        nc183, nc184, nc185, nc186, nc187, nc188, nc189, nc190, nc191})
        , .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .A_ADDR({RADDR[11], RADDR[10], RADDR[9], RADDR[8], RADDR[7], 
        RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, 
        VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, WD[31], WD[30], WD[29], WD[28]}), .B_ADDR({WADDR[11], 
        WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND}), 
        .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({
        GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C2 (.A_DOUT({nc192, nc193, 
        nc194, nc195, nc196, nc197, nc198, nc199, nc200, nc201, nc202, 
        nc203, nc204, nc205, RD[11], RD[10], RD[9], RD[8]}), .B_DOUT({
        nc206, nc207, nc208, nc209, nc210, nc211, nc212, nc213, nc214, 
        nc215, nc216, nc217, nc218, nc219, nc220, nc221, nc222, nc223})
        , .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .A_ADDR({RADDR[11], RADDR[10], RADDR[9], RADDR[8], RADDR[7], 
        RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, 
        VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, WD[11], WD[10], WD[9], WD[8]}), .B_ADDR({WADDR[11], 
        WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND}), 
        .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({
        GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    RAM1K18 sram_4Kx32_sram_4Kx32_0_TPSRAM_R0C5 (.A_DOUT({nc224, nc225, 
        nc226, nc227, nc228, nc229, nc230, nc231, nc232, nc233, nc234, 
        nc235, nc236, nc237, RD[23], RD[22], RD[21], RD[20]}), .B_DOUT({
        nc238, nc239, nc240, nc241, nc242, nc243, nc244, nc245, nc246, 
        nc247, nc248, nc249, nc250, nc251, nc252, nc253, nc254, nc255})
        , .BUSY(), .A_CLK(CLK), .A_DOUT_CLK(VCC), .A_ARST_N(VCC), 
        .A_DOUT_EN(VCC), .A_BLK({VCC, VCC, VCC}), .A_DOUT_ARST_N(VCC), 
        .A_DOUT_SRST_N(VCC), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .A_ADDR({RADDR[11], RADDR[10], RADDR[9], RADDR[8], RADDR[7], 
        RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], RADDR[1], 
        RADDR[0], GND, GND}), .A_WEN({GND, GND}), .B_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ARST_N(VCC), .B_DOUT_EN(VCC), .B_BLK({WEN, 
        VCC, VCC}), .B_DOUT_ARST_N(GND), .B_DOUT_SRST_N(VCC), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, WD[23], WD[22], WD[21], WD[20]}), .B_ADDR({WADDR[11], 
        WADDR[10], WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0], GND, GND}), 
        .B_WEN({GND, VCC}), .A_EN(VCC), .A_DOUT_LAT(VCC), .A_WIDTH({
        GND, VCC, GND}), .A_WMODE(GND), .B_EN(VCC), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .B_WMODE(GND), .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
