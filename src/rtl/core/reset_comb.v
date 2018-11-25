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
// File Name: 		reset_comb.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		reset combine block               	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

module reset_comb (
input wire cpu_rstn,				//cpu reset, active low
input wire pg_resetn,				//power gating reset, active low
output wire comb_rstn				//combined reset,active low

);



assign comb_rstn = cpu_rstn && pg_resetn;

endmodule
