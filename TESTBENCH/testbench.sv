// Code your testbench here
// or browse Examples

// TESTCASE 1
`define tdr_test

// TESTCASE 2
`define tcr_test

// TESTCASE 3
`define tsr_test

// TESTCASE 4
`define null_address

// TESTCASE 5
`define mixed_address

// TESTCASE 6
`define countup_forkjoin_pclk2

// TESTCASE 7
`define countup_forkjoin_pclk4

// TESTCASE 8
`define countup_forkjoin_pclk8

// TESTCASE 9
`define countup_forkjoin_pclk16

// TESTCASE 14
`define countup_pause_countup_pclk2

// TESTCASE 15
`define countdw_pause_countdw_pclk2

// TESTCASE 16
`define countup_reset_countdw_pclk2

// TESTCASE 17
`define countdw_reset_countup_pclk2

// TESTCASE 18
`define countup_reset_load_countdw_pclk2

// TESTCASE 19
`define countdw_reset_load_countdw_pclk2

// TESTCASE 20
`define fake_underflow

// TESTCASE 21
`define fake_overflow

module tb_timer;
  
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 8;
  parameter WAIT = 1;
  
  reg 					pclk;
  reg 					presetn;
  reg 					psel;
  reg 					penable;
  reg 					pwrite;
  reg [ADDR_WIDTH-1:0]	paddr;
  reg [DATA_WIDTH-1:0]	pwdata;
  
  wire [DATA_WIDTH-1:0]	prdata;
  wire 					pready;
  wire 					pslverr;
  
  wire 					s_ovf;
  wire 					s_udf;
  wire [DATA_WIDTH-1:0]	cnt;
  wire [DATA_WIDTH-1:0]	tdr_reg;
  wire [DATA_WIDTH-1:0]	tcr_reg;
  wire [DATA_WIDTH-1:0]	tsr_reg;
  
  reg 					clk_in1;
  reg 					clk_in2;
  reg 					clk_in3;
  reg 					clk_in4;
  
  integer count;
  integer i;

  timer #(.WAIT(WAIT)) dut (
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
    .cnt			(cnt),
    .tdr_reg		(tdr_reg),
    .tcr_reg		(tcr_reg),
    .tsr_reg		(tsr_reg),
    .clk_in1		(clk_in1),
    .clk_in2		(clk_in2),
    .clk_in3		(clk_in3),
    .clk_in4		(clk_in4)
  );
  
  task apb_write;
    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] data_in;
    
    begin
      @(posedge pclk);
      psel <= 1;
      paddr <= addr;
      pwdata <= data_in;
      pwrite <= 1;
      
      @(posedge pclk);
      penable <= 1;
      
      wait(pready);
      
      @(posedge pclk);
      psel <= 0;
      penable <= 0;
      pwrite <= 0;
    end
  endtask
  
  task apb_read;
    input [ADDR_WIDTH-1:0] addr;
    
    begin
      @(posedge pclk);
      psel <= 1;
      paddr <= addr;
      pwrite <= 0;
      
      @(posedge pclk);
      penable <= 1;
      
      wait(pready);
      
      @(posedge pclk);
      psel <= 0;
      penable <= 0;
    end
  endtask
  
  // clock generator
  initial begin
    pclk = 0;
    clk_in1 = 0;
    clk_in2 = 0;
    clk_in3 = 0;
    clk_in4 = 0;
    count = 0;
  end
  
  always #5 pclk = ~pclk;
  
  always @(posedge pclk) begin
    count <= count + 1;
    
    if (count % 1 == 0) clk_in1 <= ~clk_in1;
    if (count % 2 == 0) clk_in2 <= ~clk_in2;
    if (count % 4 == 0) clk_in3 <= ~clk_in3;
    if (count % 8 == 0) clk_in4 <= ~clk_in4;
  end
  /////////////////
  
  initial begin
    presetn = 0;
    
    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 0;
    pwdata = 0;
    
    
    // test presetn signal 
    #20;
    presetn = 1;
    
    
    // TESTCASE 1
    
    `ifdef tdr_test
    
    $display("TESTCASE tdr_test %0t\n", $time);
    
    for(i = 0; i < 20; i = i + 1) begin
      
      $display("TEST %0d", i);
      
      // READ TDR --> CHECK DEFAULT VALUE
      apb_read(8'h00);
      
      // WRITE RANDOM VALUE TO TDR
      apb_write(8'h00, i + 4);
      
      // READ TDR
      apb_read(8'h00);
      
      // COMPARE WRITTEN VALUE
      if(prdata == (i + 4))
        $display("READ WRITE COMPARISON --> TRUE");
      else
        $display("READ WRITE COMPARISON --> FALSE");
 
    end
    `endif
    
    // TESTCASE 2
	`ifdef tcr_test
    
    $display("TESTCASE tcr_test %0t\n", $time);
    
    for (i = 0; i < 20; i = i + 1) begin
      $display("TEST %0d", i);
      
      // READ TCR --> CHECK DEFAULT VALUE
      apb_read(8'h01);
      
      // WRITE RANDOM VALUE TO TCR
      apb_write(8'h01, 5 * i + 2);
      
      // READ TCR
      apb_read(8'h01);
      
      $display("prdata is %0d", prdata);
      $display("(5 * i + 2) & 10110011 is %0d", (5 * i + 2) & 8'b10110011);
      
      // COMPARE WRITTEN VALUE WITH MASK = 1011_0011
      if(prdata == ((5 * i + 2) & 8'b10110011))
         $display("READ WRITE COMPARISON --> TRUE");
      else
        $display("READ WRITE COMPARISON --> FALSE");
      
    end
    
    `endif
    
    // TESTCASE 3
    
    `ifdef tsr_test
    
    $display("TESTCASE tsr_test %0t\n", $time);
    
    for(i = 0; i < 20; i = i + 1) begin
      
      $display("TEST %0d", i);
      
      // READ TSR --> CHECK DEFAULT VALUE
      apb_read(8'h02);
      
      // WRITE RANDOM VALUE TO TSR
      apb_write(8'h02, 2 * i + 1);
      
      // READ TSR
      apb_read(8'h02);
      
      // COMPARE WRITTEN DATA FROM TSR TO 0
      if(prdata == 0)
        $display("READ WRITE COMPARISON --> TRUE");
      else
        $display("READ WRITE COMPARISON --> FALSE");
      
    end
    `endif
    
    // TESTCASE 4
    
    `ifdef null_address
    
    $display("TESTCASE null_address %0t\n", $time);
    
    for(i = 0; i < 20; i = i + 1) begin
      
      $display("TEST %0d", i);
      
      // WRITE A RANDOM VALUE TO A RANDOM ADDRESS
      apb_write($urandom_range(3, 255), $random);
      
      $display("pwdata %0b, paddr 8'h%0h", pwdata, paddr);
   	
      if(pslverr)
        $display("PSLVERR TRIGGERED");
      else
        $display("PSLVERR NOT TRIGGERED");
      
      // READ DATA FROM RANDOM ADDRESS
      apb_read(tb_timer.dut.register_control_inst.paddr);
      
    end
    `endif
    
    // TESTCASE 5
    
    `ifdef mixed_address
    
    $display("TESTCASE mixed_address %0t\n", $time);
    
    for(i = 0; i < 20; i = i + 1) begin
      
      $display("TEST %0d", i);
      
      // WRITE A RANDOM VALUE TO A RANDOM ADDRESS
      apb_write($random, $random);
      $display("pwdata %0b, paddr 8'h%0h", pwdata, paddr);
   	
      if(pslverr) 
        $display("PSLVERR TRIGGERED");
      else
        $display("PSLVERR NOT TRIGGERED");
      
      
      if((tb_timer.dut.register_control_inst.paddr != 8'h00) &
         (tb_timer.dut.register_control_inst.paddr != 8'h01) & 
         (tb_timer.dut.register_control_inst.paddr != 8'h02) 
        ) begin
        
        $display("NULL-ADDRESS");
//         $display("time %0t", $time);
      end
      else begin
        
        // READ DATA FROM REGISTER
      	apb_read(tb_timer.dut.register_control_inst.paddr);
      
//       	$display("time %0t", $time);
        
        if(tb_timer.dut.register_control_inst.paddr == 8'h00) begin
          if(prdata == tb_timer.dut.register_control_inst.pwdata)
            $display("READ WRITE COMPARISON TDR --> TRUE");
          else 
            $display("READ WRITE COMPARISON TDR --> FALSE");
        
        end else if (tb_timer.dut.register_control_inst.paddr == 8'h01) begin
          if(prdata == (tb_timer.dut.register_control_inst.pwdata & 8'b10110011))
            $display("READ WRITE COMPARISON TCR --> TRUE");
          else 
            $display("READ WRITE COMPARISON TCR --> FALSE");
        
        end else begin
          if(prdata == 8'h00)
            $display("READ WRITE COMPARISON TSR --> TRUE");
          else
            $display("READ WRITE COMPARISON TSR --> FALSE");
        end
      
      end
    
    end
    
    `endif
    
    
    // TESTCASE 6
    
    `ifdef countup_forkjoin_pclk2
    
    $display("TESTCASE countup_forkjoin_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd78);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00110000);
    
    fork
      
      begin
        $display("THREAD 1 %0t", $time);
        
        repeat(257 - tdr_reg) begin
          @(posedge tb_timer.dut.logic_control_inst.clk_in);
          $display("time %0t", $time);
        end
		
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Pass %0t", $time);
        else
          $display("Fail %0t", $time);
      end
      
      begin
        
        $display("THREAD 2 %0t", $time);
        
        repeat((257 - tdr_reg) * 2/3) @(posedge tb_timer.dut.logic_control_inst.clk_in);
        
		$display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Fail --> NOT NORMAL %0t", $time); 
        else 
          $display("Pass --> NORMAL OPERATION %0t", $time);

      end
            
    join
    
    `endif
    
    // TESTCASE 7
    
    `ifdef countup_forkjoin_pclk4
    
    $display("TESTCASE countup_forkjoin_pclk4 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd78);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000001);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTUP, PCLKx4, EN --> 1
    apb_write(8'h01, 8'b00110001);
    
    fork
      
      begin
        $display("THREAD 1 %0t", $time);
        
        repeat(257 - tdr_reg) begin
          @(posedge tb_timer.dut.logic_control_inst.clk_in);
          $display("time %0t", $time);
        end
		
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);

        if(s_ovf)
          $display("Pass %0t", $time);
        else
          $display("Fail %0t", $time);
      end
      
      begin
        
        $display("THREAD 2 %0t", $time);
        
        repeat((257 - tdr_reg) * 2/3) @(posedge tb_timer.dut.logic_control_inst.clk_in);
        
		$display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Fail --> NOT NORMAL %0t", $time);
        else 
          $display("Pass --> NORMAL OPERATION %0t", $time);
      end
            
    join
    
    `endif
    
    
    // TESTCASE 8
    
    `ifdef countup_forkjoin_pclk8
    
    $display("TESTCASE countup_forkjoin_pclk8 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd78);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000010);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTUP, PCLKx8, EN --> 1
    apb_write(8'h01, 8'b00110010);
    
    fork
      
      begin
        $display("THREAD 1 %0t", $time);
        
        repeat(257 - tdr_reg) begin
          @(posedge tb_timer.dut.logic_control_inst.clk_in);
          $display("time %0t", $time);
        end
		
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Pass %0t", $time);
        else
          $display("Fail %0t", $time);
      end
      
      begin
        
        $display("THREAD 2 %0t", $time);
        
        repeat((257 - tdr_reg) * 2/3) @(posedge tb_timer.dut.logic_control_inst.clk_in);
                
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);

        if(s_ovf)
          $display("Fail --> NOT NORMAL %0t", $time);
        else 
          $display("Pass --> NORMAL OPERATION %0t", $time);
      end
            
    join
    
    `endif

    // TESTCASE 9
    
    `ifdef countup_forkjoin_pclk16
    
    $display("TESTCASE countup_forkjoin_pclk16 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd78);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000011);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTUP, PCLKx8, EN --> 1
    apb_write(8'h01, 8'b00110011);
    
    fork
      
      begin
        $display("THREAD 1 %0t", $time);
        
        repeat(257 - tdr_reg) begin
          @(posedge tb_timer.dut.logic_control_inst.clk_in);
          $display("time %0t", $time);
        end
        
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Pass %0t", $time);
        else
          $display("Fail %0t", $time);
      end
      
      begin
        
        $display("THREAD 2 %0t", $time);
        
        repeat((257 - tdr_reg) * 2/3) @(posedge tb_timer.dut.logic_control_inst.clk_in);
                
        $display("cnt is %0d and s_ovf is %0d", cnt, s_ovf);
        
        if(s_ovf)
          $display("Fail --> NOT NORMAL %0t", $time);
        else 
          $display("Pass --> NORMAL OPERATION %0t", $time);
      end
            
    join
    
    `endif
    
    // TESTCASE 14
    
    `ifdef countup_pause_countup_pclk2
    
    $display("TESTCASE countup_pause_countup_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd200);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00110000);
    
    // count up for 250 ns
    #800;
    
    @(posedge pclk);
    apb_write(8'h01, 8'b00100000);
    
    #800;
    
    if(s_ovf) 
      $display("OVERFLOW TRIGGERED -->> FAILED");
    else
      $display("OVERFLOW NOT TRIGGERED -->> NORMAL OPERATION %0t", $time);
    
    $display("CONTINUE COUNTING %0t", $time);
//     @(posedge pclk);
    apb_write(8'h01, 8'b00110000);
    
    wait(cnt == 8'h00);

    repeat(2) @(posedge pclk);

    if(s_ovf)
      $display("PASS %0t", $time);
    else
      $display("FAULTY %0t", $time);
    
    `endif
    
    // TESTCASE 15
    `ifdef countdw_pause_countdw_pclk2
    
    $display("TESTCASE countdw_pause_countdw_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'd50);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation 
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    // count down for 250 ns
    #800;
    
    // EN --> 0 --> stop counting
    @(posedge pclk);
    apb_write(8'h01, 8'b00000000);
    
    // wait for 250 ns
    #800;
    
    // CHECK TO SEE OPERATION IS NORMAL
    if(s_udf) 
      $display("UNDERFLOW TRIGGERED -->> FAILED");
    else
      $display("UNDERFLOW NOT TRIGGERED -->> NORMAL OPERATION %0t", $time);
    
    // SET EN --> 1 --> CONTINUE COUNTING
    $display("CONTINUE COUNTING %0t", $time);

    apb_write(8'h01, 8'b00010000);
    
    wait(cnt == 8'hff);

    repeat(2) @(posedge pclk);
    
    // IF S_UDF FLAG TRIGGERED, PASS
    if(s_udf)
      $display("TESTCASE 15 --> PASS %0t", $time);
    else
      $display("TESTCASE 15 --> FAULTY %0t", $time);
    
    `endif
    
    // TESTCASE 16
    
    `ifdef countup_reset_countdw_pclk2
    
    $display("TESTCASE countup_reset_countdw_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'b10011000);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation 
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00110000);
    
    // COUNT UP FOR 250 ns
    #250;
    
    // RESET SIGNAL TRIGGERED
    presetn = 0;
    
    #100;
    
    $display("TDR %0d, TCR %0d, TSR %0d %0t", tdr_reg, tcr_reg, tsr_reg, $time);
    // CHECK IF TDR, TCR, TSR EQUAL DEFAULT VALUES (0)
    if(tdr_reg == 8'h00 & tcr_reg == 8'h00 & tsr_reg == 8'h00) 
      $display("TDR, TCR, TSR EQUAL DEFAULT VALUES (0) --> NORMAL OPERATION %0t", $time);
    else
      $display("TDR, TCR, TSR NOT EQUAL DEFAULT VALUES (0) --> FAILED %0t", $time);
        
    // RESET SIGNAL TRIGGERED
    presetn = 1;
    
    // PUT VALUE SIMILAR TO THE ONE BEFORE THE RESET INTO TCNT
//     @(posedge pclk);
    apb_write(8'h00, 8'ha4);
        
 	// SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    wait(cnt == 8'hff);
    repeat(2) @(posedge pclk);
    
    //CHECK IF S_UDF FLAG TRIGGERED --> PASS, OTHERWISE --> FAIL
    if(s_udf)
      $display("TESTCASE 16 --> PASS %0t", $time);
    else
      $display("TESTCASE 16 --> FAULTY %0t", $time);
    
    `endif
    
    // TESTCASE 17
    
    `ifdef countdw_reset_countup_pclk2
    
    $display("TESTCASE countdw_reset_countup_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'b10011000);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation 
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    // COUNT DOWN FOR 250 ns
    #250;
    
    // RESET SIGNAL TRIGGERED
    presetn = 0;
    
    #100;
    
    // CHECK IF TDR, TCR, TSR EQUAL DEFAULT VALUES (0)
    if(tdr_reg == 8'h00 & tcr_reg == 8'h00 & tsr_reg == 8'h00) 
      $display("TDR, TCR, TSR EQUAL DEFAULT VALUES (0) --> NORMAL OPERATION %0t", $time);
    else
      $display("TDR, TCR, TSR NOT EQUAL DEFAULT VALUES (0) --> FAILED %0t", $time);
    
    // RESET SIGNAL TRIGGERED
    presetn = 1;
    
    // PUT VALUE SIMILAR TO THE ONE BEFORE THE RESET INTO TCNT
    @(posedge pclk);
    apb_write(8'h00, 8'h8c);
        
 	// SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00110000);
    
    wait(cnt == 8'h00);
    repeat(2) @(posedge pclk);
    
    //CHECK IF S_OVF FLAG TRIGGERED --> PASS, OTHERWISE --> FAIL
    if(s_ovf)
      $display("TESTCASE 17 --> PASS %0t", $time);
    else
      $display("TESTCASE 17 --> FAIL %0t", $time);
    
    `endif
    
    // TESTCASE 18
    
    `ifdef countup_reset_load_countdw_pclk2
    
    $display("TESTCASE countup_reset_load_countdw_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'b10011000);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation 
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00110000);
    
    // COUNT UP FOR 250 ns
    #250;
    
    // RESET SIGNAL TRIGGERED
    presetn = 0;
    
    #100;
    
    // CHECK IF TDR, TCR, TSR EQUAL DEFAULT VALUES (0)
    if(tdr_reg == 8'h00 & tcr_reg == 8'h00 & tsr_reg == 8'h00) 
      $display("TDR, TCR, TSR EQUAL DEFAULT VALUES (0) --> NORMAL OPERATION %0t", $time);
    else
      $display("TDR, TCR, TSR NOT EQUAL DEFAULT VALUES (0) --> FAILED %0t", $time);
    
    // RESET SIGNAL TRIGGERED
    presetn = 1;
    
    // PUT A RANDOM VALUE INTO TCNT
    @(posedge pclk);
    apb_write(8'h00, 8'hd3);
        
 	// SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    wait(cnt == 8'hff);
    repeat(2) @(posedge pclk);
    
    //CHECK IF S_UDF FLAG TRIGGERED --> PASS, OTHERWISE --> FAIL
    if(s_udf)
      $display("TESTCASE 18 --> PASS %0t", $time);
    else
      $display("TESTCASE 18 --> FAIL %0t", $time);
    
    `endif
    
    // TESTCASE 19
    
    `ifdef countdw_reset_load_countdw_pclk2
    
    $display("TESTCASE countdw_reset_load_countdw_pclk2 %0t\n", $time);
    
    // write a random value to TDR
    apb_write(8'h00, 8'b10011000);
    
    // SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation 
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    // COUNT DOWN FOR 250 ns
    #250;
    
    // RESET SIGNAL TRIGGERED
    presetn = 0;
    
    #100;
    
    // CHECK IF TDR, TCR, TSR EQUAL DEFAULT VALUES (0)
    if(tdr_reg == 8'h00 & tcr_reg == 8'h00 & tsr_reg == 8'h00) 
      $display("TDR, TCR, TSR EQUAL DEFAULT VALUES (0) --> NORMAL OPERATION %0t", $time);
    else
      $display("TDR, TCR, TSR NOT EQUAL DEFAULT VALUES (0) --> FAILED %0t", $time);
    
    // RESET SIGNAL TRIGGERED
    presetn = 1;
    
    // PUT VALUE SIMILAR TO THE ONE BEFORE THE RESET INTO TCNT
    @(posedge pclk);
    apb_write(8'h00, 8'hd3);
        
 	// SET LOAD --> 1 to load data from TDR to tcnt 
    apb_write(8'h01, 8'b10000000);
    
    // set the conditions for operation
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 1
    apb_write(8'h01, 8'b00010000);
    
    wait(cnt == 8'hff);
    repeat(2) @(posedge pclk);
    
    //CHECK IF S_UDF FLAG TRIGGERED --> PASS, OTHERWISE --> FAIL
    if((cnt == 8'hff) & s_udf)
      $display("TESTCASE 19 --> PASS %0t", $time);
    else
      $display("TESTCASE 19 --> FAIL %0t", $time);
    
    `endif
    
    // TESTCASE 20
    
    `ifdef fake_underflow
    
    $display("TESTCASE fake_underflow %0t\n", $time);
    
    // WRITE 8'H00 TO TDR
    apb_write(8'h00, 8'h00);
    
    // SET LOAD --> 1 TO LOAD DATA FROM TDR TO TCNT
    apb_write(8'h01, 8'b10000000);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTDOWN, PCLKx2, EN --> 0
    apb_write(8'h01, 8'b00000000);
    
    // WRITE 8'HFF TO TDR
    apb_write(8'h00, 8'hff);
    
    // SET LOAD --> 1 TO LOAD DATA FROM TDR TO TCNT
    apb_write(8'h01, 8'b10000000);
    
    // SET LOAD --> 0
    apb_write(8'h01, 8'b00000000);
    
    `endif

    // TESTCASE 21
    
    `ifdef fake_overflow
    
    $display("TESTCASE fake_overflow %0t\n", $time);
    
    // WRITE 8'HFF TO TDR
    apb_write(8'h00, 8'hff);
    
    // SET LOAD --> 1 TO LOAD DATA FROM TDR TO TCNT
    apb_write(8'h01, 8'b10000000);
    
    // SET THE CONDITION FOR OPERATION 
    // LOAD --> 0, COUNTUP, PCLKx2, EN --> 0
    apb_write(8'h01, 8'b00100000);
    
    // WRITE 8'H00 TO TDR
    apb_write(8'h00, 8'h00);
    
    // SET LOAD --> 1 TO LOAD DATA FROM TDR TO TCNT
    apb_write(8'h01, 8'b10100000);
    
    // SET LOAD --> 0
    apb_write(8'h01, 8'b00100000);
    
    `endif


    #4000;
    $finish;
  end
  
  
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, tb_timer);
    $dumpvars(1, dut);
    $dumpvars(1, dut.register_control_inst);
    $dumpvars(1, dut.logic_control_inst);
    $dumpvars(1, dut.counter_inst);
  end
  
  
  
  
endmodule