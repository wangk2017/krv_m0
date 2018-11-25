/*
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.      
*/
//==============================================================||
// File Name: 		apb_ss.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		APB subsystem 			    	|| 
// History:   							||
//                      First version				||
//===============================================================


module apb_ss (
        // Inputs
    GPIO_IN,
    GPIO_OUT,
    UART_RX,
    UART_TX,
    HADDR,
    HCLK,
    HREADY,
    HRESETn,
    HSEL,
    HTRANS,
    HWDATA,
    HWRITE,
    // Outputs
    timer_int,
    HRDATA,
    HREADYOUT,
    HRESP
);
//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [7:0]  GPIO_IN;
input 	      UART_RX;
input  [31:0] HADDR;
input         HCLK;
input         HREADY;
input         HRESETn;
input         HSEL;
input  [1:0]  HTRANS;
input  [31:0] HWDATA;
input         HWRITE;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output timer_int;
output [31:0] HRDATA;
output        HREADYOUT;
output [1:0]  HRESP;
output [7:0]  GPIO_OUT;
output 	      UART_TX;

//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------

wire  [31:0] PRDATA;
wire         PREADY;
wire         PSLVERR;
wire [31:0] PADDR;
wire        PENABLE;
wire        PSEL;
wire [31:0] PWDATA;
wire        PWRITE;

wire [31:0] PRDATAS4;
wire [31:0] PRDATAS1;
wire [31:0] PRDATAS2;
wire [31:0] PRDATAS3;
wire        PREADYS4;
wire        PREADYS1;
wire        PREADYS2;
wire        PREADYS3;
wire        PSLVERRS4;
wire        PSLVERRS1;
wire        PSLVERRS2;
wire        PSLVERRS3;
wire [31:0] PADDRS;
wire        PENABLES;
wire        PSELS4;
wire        PSELS1;
wire        PSELS2;
wire        PSELS3;
wire [31:0] PWDATAS;
wire        PWRITES;

//AHB2APB3
ahb2apb u_ahb2apb(
    .HADDR		(HADDR	),
    .HCLK		(HCLK	),
    .HREADY		(HREADY	),
    .HRESETN		(HRESETn),
    .HSEL		(HSEL	),
    .HTRANS		(HTRANS	),
    .HWDATA		(HWDATA	),
    .HWRITE		(HWRITE	),
    .PRDATA		(PRDATA	),
    .PREADY		(PREADY	),
    .PSLVERR		(PSLVERR),
    .HRDATA		(HRDATA	),
    .HREADYOUT		(HREADYOUT),
    .HRESP		(HRESP	),
    .PADDR		(PADDR	),
    .PENABLE		(PENABLE),
    .PSEL		(PSEL	),
    .PWDATA		(PWDATA	),
    .PWRITE		(PWRITE	)
);

//APB
apb3 u_apb(
    .PADDR		(PADDR		),
    .PENABLE		(PENABLE	),
    .PRDATAS4		(PRDATAS4	),
    .PRDATAS1		(PRDATAS1	),
    .PRDATAS2		(PRDATAS2	),
    .PRDATAS3		(PRDATAS3	),
    .PREADYS4		(PREADYS4	),
    .PREADYS1		(PREADYS1	),
    .PREADYS2		(PREADYS2	),
    .PREADYS3		(PREADYS3	),
    .PSEL		(PSEL		),
    .PSLVERRS4		(PSLVERRS4	),
    .PSLVERRS1		(PSLVERRS1	),
    .PSLVERRS2		(PSLVERRS2	),
    .PSLVERRS3		(PSLVERRS3	),
    .PWDATA		(PWDATA		),
    .PWRITE		(PWRITE		),
    .PADDRS_1		(PADDRS		),
    .PENABLES_1		(PENABLES	),
    .PRDATA		(PRDATA		),
    .PREADY		(PREADY		),
    .PSELS4		(PSELS4		),
    .PSELS1		(PSELS1		),
    .PSELS2		(PSELS2		),
    .PSELS3		(PSELS3		),
    .PSLVERR		(PSLVERR	),
    .PWDATAS_1		(PWDATAS	),
    .PWRITES_1		(PWRITES	)
);
//uart
uart uart_0(
    .PADDR		(PADDRS[4:0]),
    .PCLK		(HCLK),
    .PENABLE		(PENABLES),
    .PRESETN		(HRESETn),
    .PSEL		(PSELS1),
    .PWDATA		(PWDATAS[7:0]),
    .PWRITE		(PWRITES),
    .RX			(UART_RX),
    .FRAMING_ERR	(),
    .OVERFLOW		(),
    .PARITY_ERR		(),
    .PRDATA		(PRDATAS1[7:0]),
    .PREADY		(PREADYS1),
    .PSLVERR		(PSLVERRS1),
    .RXRDY		(),
    .TX			(UART_TX),
    .TXRDY		()
);
assign PRDATAS1[31:8] = 24'h0;
//timer
timer timer_0(
    .PADDR		(PADDRS[4:2]),
    .PCLK		(HCLK),
    .PENABLE		(PENABLES),
    .PRESETn		(HRESETn),
    .PSEL		(PSELS2),
    .PWDATA		(PWDATAS),
    .PWRITE		(PWRITES),
    .PRDATA		(PRDATAS2),
    .TIMINT		(timer_int)
);

assign PREADYS2 = 1;
assign PSLVERRS2 = 0;
//gpio_in
gpio_in gpio_in(
    .GPIO_IN(GPIO_IN),
    .PADDR(PADDRS[7:0]),
    .PCLK(HCLK),
    .PENABLE(PENABLES),
    .PRESETN(HRESETn),
    .PSEL(PSELS3),
    .PWDATA(PWDATAS),
    .PWRITE(PWRITES),
    .GPIO_OE(),
    .GPIO_OUT(),
    .INT(),
    .PRDATA(PRDATAS3),
    .PREADY(PREADYS3),
    .PSLVERR(PSLVERRS3)
);

//gpio_out
gpio_out gpio_out(
    .GPIO_IN(),
    .PADDR(PADDRS[7:0]),
    .PCLK(HCLK),
    .PENABLE(PENABLES),
    .PRESETN(HRESETn),
    .PSEL(PSELS4),
    .PWDATA(PWDATAS),
    .PWRITE(PWRITES),
    .GPIO_OE(),
    .GPIO_OUT(GPIO_OUT),
    .INT(),
    .PRDATA(PRDATAS4),
    .PREADY(PREADYS4),
    .PSLVERR(PSLVERRS4)
);

endmodule
