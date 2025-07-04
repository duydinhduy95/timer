module counter #(parameter DATA_WIDTH = 8) (pclk, presetn, clk_in, up_down, tdr_reg, enable, load_tdr, cnt, s_ovf, s_udf);
  
  input wire 					pclk;
  input wire					presetn;
  input wire 					clk_in;
  input wire 					up_down;
  input wire [DATA_WIDTH-1:0] 	tdr_reg;
  input wire					enable;
  input wire 					load_tdr;
  output reg [DATA_WIDTH-1:0]	cnt;
  output reg					s_ovf;
  output reg					s_udf;
  
  reg 	delay_clk_in;
  wire 	posedge_detector_clk_in;
  
  reg 	delay_load_tdr;
  wire 	posedge_detector_load_tdr;
  
  reg 	[DATA_WIDTH-1:0]	temp_cnt;
  
  
//   always @(*) begin
    
//     if(posedge_detector_load_tdr)
// //       $display("combinational 1st cnt: %0d at %0t", cnt, $time);
//       cnt = tdr_reg;
// //       count = count + 1;
// //       $display("combinational 2nd cnt: %0d at %0t", cnt, $time);
// //       else
// //         cnt = cnt;
// //       count = 0;
// //       $display("combinational 3rd cnt: %0d at %0t", cnt, $time);
//   end
  

//   always @(posedge pclk or negedge presetn) begin
//     if (~presetn)
//       cnt <= 8'h00;
    
//     else begin
//       if (enable && posedge_detector_clk_in) begin
//         if (up_down) 
//           cnt <= cnt + 8'h01;
//       	else
//           cnt <= cnt - 8'h01;
// //       end else cnt <= cnt;
//       end
//     end
//   end
  
  always @(posedge pclk or negedge presetn) begin
    if (~presetn)
      cnt <= 8'h00;
    else if (posedge_detector_load_tdr)
      cnt <= tdr_reg;
    else if (enable && posedge_detector_clk_in) begin
      if (up_down)
        cnt <= cnt + 8'h01;
      else
        cnt <= cnt - 8'h01;
    end
  end
  
  always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
      s_udf <= 0;
      s_ovf <= 0;
    end else begin
      if(enable) begin
        if(~up_down && (cnt == 8'hff))
          s_udf <= 1;
        else if(up_down && (cnt == 8'h00))
          s_ovf <= 1;
        else begin
          s_udf <= s_udf;
          s_ovf <= s_ovf;
        end
      end else begin
        s_udf <= s_udf;
      	s_ovf <= s_ovf;
      end
    end
  end
  
  // posedge detector block
  always @(posedge pclk or negedge presetn) begin
    if(~presetn) delay_clk_in <= 0;
	else 		delay_clk_in <= clk_in;
  end
  
  assign posedge_detector_clk_in = clk_in & ~delay_clk_in;
  ///
  
  // POSEDGE DETECTOR FOR LOAD_TDR BIT
  always @(posedge pclk or negedge presetn) begin
    if(~presetn) delay_load_tdr <= 0;
    else 		delay_load_tdr <= load_tdr;
  end
  
  assign posedge_detector_load_tdr = load_tdr & ~delay_load_tdr;
  
endmodule