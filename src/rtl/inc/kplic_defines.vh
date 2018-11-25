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

//Global defines
`define KPLIC_DATA_WIDTH 32
`define INT_NUM 32
`define INT_WIDTH 5


//register defines
`define KPLIC_INT_TYPE_OFFSET 			12'h000
`define KPLIC_INT_ENABLE_OFFSET			12'h008
`define KPLIC_INT_PENDING_STATUS_OFFSET		12'h010
`define KPLIC_TARGET_PRIORITY_OFFSET		12'h018
`define KPLIC_MPPI_OFFSET			12'h020
`define KPLIC_INT_COMPLETION_OFFSET		12'h028

`define KPLIC_INT_PRIORITY_GROUP0_OFFSET	12'h12C	
`define KPLIC_INT_PRIORITY_GROUP1_OFFSET	12'h130	
`define KPLIC_INT_PRIORITY_GROUP2_OFFSET	12'h134	
`define KPLIC_INT_PRIORITY_GROUP3_OFFSET	12'h138	
`define KPLIC_INT_PRIORITY_GROUP4_OFFSET	12'h13C	
`define KPLIC_INT_PRIORITY_GROUP5_OFFSET	12'h140	
`define KPLIC_INT_PRIORITY_GROUP6_OFFSET	12'h144	
`define KPLIC_INT_PRIORITY_GROUP7_OFFSET	12'h148	
