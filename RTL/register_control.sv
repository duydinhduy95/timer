// Code your design here
module register_control #(parameter ADDR_WIDTH = 8,
                         parameter DATA_WIDTH = 8,
                         parameter WAIT = 0
                         )
  (pclk, presetn, psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr, tdr_reg, tcr_reg, tsr_reg, s_ovf, s_udf);
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
  
  input wire 					s_ovf;
  input wire					s_udf;
  
  output reg [DATA_WIDTH-1:0]	tdr_reg;
  output reg [DATA_WIDTH-1:0]	tcr_reg;
  output reg [DATA_WIDTH-1:0]	tsr_reg;

  localparam 	IDLE = 2'b00,
  				SETUP = 2'b01,
  				ACCESS = 2'b10;
  
  reg [7:0] 					wait_signal;
  
  reg [1:0] current_state;
  reg [1:0] next_state;

  always @(*) begin
    case(current_state)
    	IDLE: begin
          wait_signal = WAIT + 1;
          pready = 1'b0;
          pslverr = 1'b0;
          
          if(psel & ~penable) begin
            next_state = SETUP;
          end else begin
            next_state = IDLE;
          end
        end
      	
      	SETUP: begin
          if(psel & penable) begin
            
            if(wait_signal == 0) begin
              pready = 1'b1;
              if(paddr > 8'h02) begin
                pslverr = 1'b1;
              end
              next_state = IDLE;
            end else begin
              next_state = ACCESS;
            end
          
          end else begin
            next_state = SETUP;
          end
        end
      
      	ACCESS: begin
          if(wait_signal != 0) begin
            next_state = ACCESS;
          end else begin
            pready = 1'b1;
            if(paddr > 8'h02) begin
              pslverr = 1'b1;
            end
            next_state = IDLE;
          end
        end
      	
      	default:
          next_state = IDLE;
    endcase
  end
  
  always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
      wait_signal <= wait_signal - 1;
    end
  end

  always @(posedge pclk or negedge presetn) begin
    if(~presetn) begin
      prdata  <= 8'h00;
      tdr_reg <= 8'h00;
      tcr_reg <= 8'h00;
      tsr_reg <= 8'h00;
    end else begin
      // write transaction
      if((wait_signal == 1) & psel & penable & pwrite) begin
        case(paddr) 
          8'h00:
            tdr_reg <= pwdata;
          8'h01: begin
            tcr_reg[7] <= pwdata[7];
            tcr_reg[6] <= 1'b0;
            tcr_reg[5:4] <= pwdata[5:4];
            tcr_reg[3:2] <= 2'b00;
            tcr_reg[1:0] <= pwdata[1:0];
          end
          8'h02: begin
            if((tsr_reg[0] & tsr_reg[1]) & (pwdata[0] & pwdata[1])) begin
              tsr_reg[1:0] <= 2'b00;
          	end else begin
              tsr_reg[1:0] <= tsr_reg[1:0];
          	end
          	tsr_reg[DATA_WIDTH-1:2] <= 0;
          end
          default: $display("INVALID ADDRESS");
        endcase
        
        // configure tdr register
//         tdr_reg <= (paddr == 8'h00) ? pwdata : tdr_reg;
        
//         // configure tcr register
//         if(paddr == 8'h01) begin
//           tcr_reg[7] <= pwdata[7];
//           tcr_reg[6] <= 1'b0;
//           tcr_reg[5:4] <= pwdata[5:4];
//           tcr_reg[3:2] <= 2'b00;
//           tcr_reg[1:0] <= pwdata[1:0];
//         end
        
//         // configure tsr register
//         if(paddr == 8'h02) begin
// //           if(tsr_reg[1] && pwdata[1]) tsr_reg[1] <= 0;
// //           else if (tsr_reg[0] && pwdata[0]) tsr_reg[0] <= 0;
// //           else begin
// //             tsr_reg[0] <= tsr_reg[0];
// //             tsr_reg[1] <= tsr_reg[1];
// //           end
// //           tsr_reg[DATA_WIDTH-1:2] = pwdata[DATA_WIDTH-1:2];
          
// //           if((tsr_reg[0] & tsr_reg[1]) & (~pwdata[0] & ~pwdata[1])) begin
// //             tsr_reg[1:0] <= 2'b11;
// //           end else begin
// //             tsr_reg[1:0] <= 2'b00;
// //           end
//           // Nếu chỉ có 1 cặp tsr và pwdata == 1 thì sao? Cách bên dưới vẫn sai
//           if((tsr_reg[0] & tsr_reg[1]) & (pwdata[0] & pwdata[1])) begin
//             tsr_reg[1:0] <= 2'b00;
//           end else begin
//             tsr_reg[1:0] <= tsr_reg[1:0];
//           end
          
//           tsr_reg[DATA_WIDTH-1:2] <= 0;
//         end
      // read transaction
      
      end else if((wait_signal == 1) & psel & penable & ~pwrite) begin
        case(paddr)
          8'h00: 	prdata <= tdr_reg;
          8'h01: 	prdata <= tcr_reg;
          8'h02: 	prdata <= tsr_reg;
          default:	$display("CANNOT READ DATA FROM INVALID ADDRESS"); 
        endcase
      end else begin
      tdr_reg <= tdr_reg;
      tcr_reg <= tcr_reg;
      tsr_reg <= tsr_reg;
      end
    end
  end

  always @(*) begin
    if (~tsr_reg[0] & s_ovf) begin
      tsr_reg[0] = 1'b1;
    end else begin
      tsr_reg[0] = tsr_reg[0];
    end
  end
      
  always @(*) begin
    if (~tsr_reg[1] & s_udf) begin
      tsr_reg[1] = 1'b1;
    end else begin
      tsr_reg[1] = tsr_reg[1];
    end
  end
  
endmodule