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
// File Name: 		light_led.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		light_led			       	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================


module light_led (
input wire clk,
input wire rstn,
input wire switch1,
input wire switch2,
output wire LED_red,
output wire LED_green
);

reg [31:0] cnt;

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		cnt <= 32'h0;
	end
	else
	begin
		cnt <= cnt + 32'h1;
	end
end


assign LED_green = switch1 ? cnt[24] : cnt[23];
assign LED_red   = switch2 ? cnt[26] : cnt[25];

endmodule
