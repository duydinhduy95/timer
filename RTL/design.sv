// Code your design here
// Code your design here
`include "register_control.sv"
`include "logic_control.sv"
`include "counter.sv"


module timer #(parameter ADDR_WIDTH = 8,
             parameter DATA_WIDTH = 8,
             parameter WAIT = 0
			 )
  (pclk, presetn, psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr, s_ovf, s_udf, cnt, tdr_reg, tcr_reg, tsr_reg, clk_in1, clk_in2, clk_in3, clk_in4);
  
  input wire 					pclk;
  input wire 					presetn;
  input wire 					psel;
  input wire 					penable;
  input wire 					pwrite;
  input wire [ADDR_WIDTH-1:0] 	paddr;
  input wire [DATA_WIDTH-1:0]	pwdata;
  
  output reg [DATA_WIDTH-1:0]	prdata; 
  output reg					pready;
  output reg					pslverr;
  
  output reg 					s_ovf;
  output reg					s_udf;
  output reg [DATA_WIDTH-1:0]	cnt;
  
  input wire 					clk_in1;
  input wire 					clk_in2;
  input wire 					clk_in3;
  input wire 					clk_in4;
  
  output reg [DATA_WIDTH-1:0]	tdr_reg;
  output reg [DATA_WIDTH-1:0]	tcr_reg;
  output reg [DATA_WIDTH-1:0]	tsr_reg;
  
  wire 							clk_in;
  wire 							up_down;
  wire    						enable;
  wire							load_tdr;
  
  register_control #(.WAIT(WAIT)) register_control_inst (
    .pclk			(pclk),
    .presetn		(presetn),
    .psel			(psel),
    .penable		(penable),
    .pwrite			(pwrite),
    .paddr			(paddr),
    .pwdata			(pwdata),
    .prdata			(prdata),
    .pready			(pready),
    .pslverr		(pslverr),
    .s_ovf			(s_ovf),
    .s_udf			(s_udf),
    .tdr_reg		(tdr_reg),
    .tcr_reg		(tcr_reg),
    .tsr_reg		(tsr_reg)
  );
  
  logic_control logic_control_inst (
    .clk_in1		(clk_in1),
    .clk_in2		(clk_in2),
    .clk_in3		(clk_in3),
    .clk_in4		(clk_in4),
    .tcr_reg		(tcr_reg),
    .clk_in			(clk_in),
    .up_down		(up_down),
    .enable			(enable),
    .load_tdr		(load_tdr)
  );
  
  counter counter_inst (
    .pclk			(pclk),
    .presetn		(presetn),
    .clk_in			(clk_in), 
    .up_down		(up_down), 
    .tdr_reg		(tdr_reg), 
    .enable			(enable), 
    .load_tdr		(load_tdr), 
    .cnt			(cnt), 
    .s_ovf			(s_ovf), 
    .s_udf			(s_udf)
  );
  
endmodule