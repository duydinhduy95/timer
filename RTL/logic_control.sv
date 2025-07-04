// Code your design here
module logic_control #(parameter DATA_WIDTH = 8)(clk_in1, clk_in2, clk_in3, clk_in4, tcr_reg, clk_in, up_down, enable, load_tdr);
  
  input wire 					clk_in1;
  input wire 					clk_in2;
  input wire 					clk_in3;
  input wire 					clk_in4;
  input wire [DATA_WIDTH-1:0] 	tcr_reg;
  
  output reg 					clk_in;
  output reg 					up_down;
  output reg					enable;
  output reg					load_tdr;
  
  reg [1:0] sel;
  
  always @(*) begin
    sel = tcr_reg[1:0];
  
//     $display("sel is %0b", sel);
    
    case(sel) 
      2'b00: clk_in = clk_in1;
      2'b01: clk_in = clk_in2;
      2'b10: clk_in = clk_in3;
      2'b11: clk_in = clk_in4;
      default: $display("Invalid tcr_reg[1:0]!!!");
    endcase    
  	
//     $display("clk_in is %0d", clk_in);
    
    up_down = tcr_reg[5];
    enable = tcr_reg[4];
    load_tdr = tcr_reg[7];
    
//     $display("up_down is %0d", up_down);
//     $display("enable is %0d", enable);
//     $display("load_tdr is %0d", load_tdr);
    
  end
  
endmodule