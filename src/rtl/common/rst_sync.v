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
// File Name: 		rst_sync.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		reset sync			       	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================


module rst_sync (
input wire clk,
input wire in_rstn,
output wire out_rstn
);

reg rstn_d1;
reg rstn_d2;

always @ (posedge clk or negedge in_rstn)
begin
	if(!in_rstn)
	begin
		rstn_d1 <= 1'b0;
		rstn_d2 <= 1'b0;
	end
	else
	begin
		rstn_d1 <= 1'b1;
		rstn_d2 <= rstn_d1;
	end
end
assign out_rstn = in_rstn && rstn_d2;


endmodule
