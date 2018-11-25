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
// File Name: 		debug_cnt.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		debug count			       	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================


module debug_cnt (
input wire clk,
input wire rstn,
input wire cnt_en,
output LED1,
output LED2
);
parameter CNT_WIDTH = 25;
reg [CNT_WIDTH-1:0] cnt;
reg event_detect;

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		cnt <= 0;
		event_detect <= 1'b0;
	end
	else
	begin 
		if(cnt_en)
		begin
			cnt <= cnt + 1;
			event_detect <= 1'b1;
		end
	end
end


assign LED1   = cnt[CNT_WIDTH-1];
assign LED2   = event_detect;

endmodule
