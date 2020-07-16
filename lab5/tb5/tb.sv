`timescale 1ns/1ps

`include "param_def.v"

interface chnl_intf(input clk, input rstn);
  logic [31:0] ch_data;
  logic        ch_valid;
  logic        ch_ready;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output ch_data, ch_valid;
    input ch_ready;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input ch_data, ch_valid, ch_ready;
  endclocking
endinterface

interface reg_intf(input clk, input rstn);
  logic [1:0]                 cmd;
  logic [`ADDR_WIDTH-1:0]     cmd_addr;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_s2m;
  logic [`CMD_DATA_WIDTH-1:0] cmd_data_m2s;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output cmd, cmd_addr, cmd_data_m2s;
    input cmd_data_s2m;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input cmd, cmd_addr, cmd_data_m2s, cmd_data_s2m;
  endclocking
endinterface

interface arb_intf(input clk, input rstn);
  logic [1:0] slv_prios[3];
  logic slv_reqs[3];
  logic a2s_acks[3];
  logic f2a_id_req;
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input slv_prios, slv_reqs, a2s_acks, f2a_id_req;
  endclocking
endinterface

interface fmt_intf(input clk, input rstn);
  logic        fmt_grant;
  logic [1:0]  fmt_chid;
  logic        fmt_req;
  logic [5:0]  fmt_length;
  logic [31:0] fmt_data;
  logic        fmt_start;
  logic        fmt_end;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    input fmt_chid, fmt_req, fmt_length, fmt_data, fmt_start;
    output fmt_grant;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input fmt_grant, fmt_chid, fmt_req, fmt_length, fmt_data, fmt_start;
  endclocking
endinterface

interface mcdf_intf(input clk, input rstn);
  // USER TODO
  // To define those signals which do not exsit in
  // reg_if, chnl_if, arb_if or fmt_if
  logic chnl_en[3];
  
  //self begin
   
  
  
  //self end 

  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input chnl_en;
  endclocking
endinterface

module tb;
  logic         clk;
  logic         rstn;

  mcdf dut(
     .clk_i       (clk                )
    ,.rstn_i      (rstn               )
    ,.cmd_i       (reg_if.cmd         ) 
    ,.cmd_addr_i  (reg_if.cmd_addr    ) 
    ,.cmd_data_i  (reg_if.cmd_data_m2s)  
    ,.cmd_data_o  (reg_if.cmd_data_s2m)  
    ,.ch0_data_i  (chnl0_if.ch_data   )
    ,.ch0_vld_i   (chnl0_if.ch_valid  )
    ,.ch0_ready_o (chnl0_if.ch_ready  )
    ,.ch1_data_i  (chnl1_if.ch_data   )
    ,.ch1_vld_i   (chnl1_if.ch_valid  )
    ,.ch1_ready_o (chnl1_if.ch_ready  )
    ,.ch2_data_i  (chnl2_if.ch_data   )
    ,.ch2_vld_i   (chnl2_if.ch_valid  )
    ,.ch2_ready_o (chnl2_if.ch_ready  )
    ,.fmt_grant_i (fmt_if.fmt_grant   ) 
    ,.fmt_chid_o  (fmt_if.fmt_chid    ) 
    ,.fmt_req_o   (fmt_if.fmt_req     ) 
    ,.fmt_length_o(fmt_if.fmt_length  )    
    ,.fmt_data_o  (fmt_if.fmt_data    )  
    ,.fmt_start_o (fmt_if.fmt_start   )  
    ,.fmt_end_o   (fmt_if.fmt_end     )  
  );
  
  // clock generation
  initial begin 
    clk <= 0;
    forever begin
      #5 clk <= !clk;
    end
  end
  
  // reset trigger
  initial begin 
    #10 rstn <= 0;
    repeat(10) @(posedge clk);
    rstn <= 1;
    # 20000  rstn <= 0;
  end

  import chnl_pkg::*;
  import reg_pkg::*;
  import arb_pkg::*;
  import fmt_pkg::*;
  import mcdf_pkg::*;

  reg_intf  reg_if(.*);
  chnl_intf chnl0_if(.*);
  chnl_intf chnl1_if(.*);
  chnl_intf chnl2_if(.*);
  arb_intf  arb_if(.*);
  fmt_intf  fmt_if(.*);
  mcdf_intf mcdf_if(.*);

  // mcdf interface monitoring MCDF ports and signals
  assign mcdf_if.chnl_en[0] = tb.dut.ctrl_regs_inst.slv0_en_o;
  assign mcdf_if.chnl_en[1] = tb.dut.ctrl_regs_inst.slv1_en_o;
  assign mcdf_if.chnl_en[2] = tb.dut.ctrl_regs_inst.slv2_en_o;

  // arbiter interface monitoring arbiter ports
  assign arb_if.slv_prios[0] = tb.dut.arbiter_inst.slv0_prio_i;
  assign arb_if.slv_prios[1] = tb.dut.arbiter_inst.slv1_prio_i;
  assign arb_if.slv_prios[2] = tb.dut.arbiter_inst.slv2_prio_i;
  assign arb_if.slv_reqs[0] = tb.dut.arbiter_inst.slv0_req_i;
  assign arb_if.slv_reqs[1] = tb.dut.arbiter_inst.slv1_req_i;
  assign arb_if.slv_reqs[2] = tb.dut.arbiter_inst.slv2_req_i;
  assign arb_if.a2s_acks[0] = tb.dut.arbiter_inst.a2s0_ack_o;
  assign arb_if.a2s_acks[1] = tb.dut.arbiter_inst.a2s1_ack_o;
  assign arb_if.a2s_acks[2] = tb.dut.arbiter_inst.a2s2_ack_o;
  assign arb_if.f2a_id_req = tb.dut.arbiter_inst.f2a_id_req_i;

  mcdf_data_consistence_basic_test t1;
  mcdf_full_random_test            t2;
  mcdf_reg_write_read_test         t3;
  mcdf_reg_illegal_access_test     t4;
  mcdf_channel_disable_test        t5;
  mcdf_arbiter_priority_test       t6;
  mcdf_formatter_length_test       t7;
  mcdf_formatter_grant_test        t8;
  mcdf_addr_illegal_access_test    t9;
  //mcdf_formatter_length_change_test  t10;
  
  mcdf_base_test tests[string];
 // mcdf_reg_write_read_test[string];     
 // mcdf_reg_illegal_access_test[string]; 
 // mcdf_channel_disable_test[string];    
 // mcdf_arbiter_priority_test[string];   
 // mcdf_formatter_length_test[string];   
 // mcdf_formatter_grant_test[string];  
     
  string name;

  initial begin 
    t1 = new();
    t2 = new();
    t3 = new();
    t4 = new();
    t5 = new();
    t6 = new();
    t7 = new();
    t8 = new();
    t9 = new();
    //t10= new();
    
    tests["mcdf_data_consistence_basic_test"] = t1;
    tests["mcdf_full_random_test"]            = t2;
    tests["mcdf_reg_write_read_test"]         = t3;
    tests["mcdf_reg_illegal_access_test"]     = t4;
    tests["mcdf_channel_disable_test"]        = t5;
    tests["mcdf_arbiter_priority_test"]       = t6;
    tests["mcdf_formatter_length_test"]       = t7;
    tests["mcdf_formatter_grant_test"]        = t8;     //mcdf_addr_illegal_access_test
    tests["mcdf_addr_illegal_access_test"]    = t9;
    //tests["mcdf_formatter_length_change_test"]= t10;    //mcdf_formatter_length_change_test
    
    if($value$plusargs("TESTNAME=%s", name)) begin
      if(tests.exists(name)) begin
        tests[name].set_interface(chnl0_if, chnl1_if, chnl2_if, reg_if, arb_if, fmt_if, mcdf_if);
        tests[name].run();
      end
      else begin
        $fatal($sformatf("[ERRTEST], test name %s is invalid, please specify a valid name!", name));
      end
    end
    else begin
      $display("NO runtime optiont TEST=[testname] is configured, and run default test mcdf_data_consistence_basic_test");
      tests["mcdf_data_consistence_basic_test"].set_interface(chnl0_if, chnl1_if, chnl2_if, reg_if, arb_if, fmt_if, mcdf_if);
      tests["mcdf_data_consistence_basic_test"].run();
    end
  end
endmodule




// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_full_random_test -sv_seed random +TESTNAME=mcdf_full_random_test -l mcdf_full_random_test.log work.tb
//这里需要注意的是标注黄色的仿真命令，这些新增的命令说明如下：
// -coverage:会在仿真时产生代码覆盖率数据，功能覆盖率数据则默认会生成，与此选项无关。
// -coverstore COVERAGE_STORAGE_PATH：这个命令是用来在仿真在最后结束时，生成覆盖率数据
//   并且存储到COVERAGE_STORAGE_PATH。你可以自己制定COVERAGE_STORAGE_PATH，但需要注意路径名中不要包含中文字符。
// -testname TESTNAME：这个选项是你需要添加本次仿真的test名称，你可以使用同+TESTNAME选项一样的test名称。
//   这样在仿真结束后，将在COVERAGE_STORAGE_PATH下产生一个覆盖率数据文件“{TESTNAME}_{SV_SEED}.data”。由于
//   仿真时我们传入的种子是随机值，因此我们每次提交测试，在测试结束后都将产生一个独一无二的覆盖率数据。例如mcdf_full_random_test_1988811153.data。

// t1 == mcdf_data_consistence_basic_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_data_consistence_basic_test -sv_seed random +TESTNAME=mcdf_data_consistence_basic_test -l mcdf_data_consistence_basic_test.log work.tb

// t2 == mcdf_full_random_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_full_random_test -sv_seed random +TESTNAME=mcdf_full_random_test -l mcdf_full_random_test.log work.tb

// t3 == mcdf_reg_write_read_test
//vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_reg_write_read_test -sv_seed random +TESTNAME=mcdf_reg_write_read_test -l mcdf_reg_write_read_test.log work.tb

// t4 == mcdf_reg_illegal_access_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_reg_illegal_access_test -sv_seed random +TESTNAME=mcdf_reg_illegal_access_test -l mcdf_reg_illegal_access_test.log work.tb

// t5 == mcdf_channel_disable_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_channel_disable_test -sv_seed random +TESTNAME=mcdf_channel_disable_test -l mcdf_channel_disable_test.log work.tb

// t6 == mcdf_arbiter_priority_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_arbiter_priority_test -sv_seed random +TESTNAME=mcdf_arbiter_priority_test -l mcdf_arbiter_priority_test.log work.tb

// t7 == mcdf_formatter_length_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_formatter_length_test -sv_seed random +TESTNAME=mcdf_formatter_length_test -l mcdf_formatter_length_test.log work.tb

// t8 == mcdf_formatter_grant_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_formatter_grant_test -sv_seed random +TESTNAME=mcdf_formatter_grant_test -l mcdf_formatter_grant_test.log work.tb
   
//  t9 == mcdf_addr_illegal_access_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_addr_illegal_access_test -sv_seed random +TESTNAME=mcdf_addr_illegal_access_test -l mcdf_addr_illegal_access_test.log work.tb

//  t10 == mcdf_formatter_length_change_test
// vsim -i -classdebug -solvefaildebug -coverage -coverstore G:\QuestaSimFile\SocLab5\CoverageStorage -testname mcdf_formatter_length_change_test -sv_seed random +TESTNAME=mcdf_formatter_length_change_test -l mcdf_formatter_length_change_test.log work.tb
// 
//--------------------
//  mcdf_data_consistence_basic_test t1;
//  mcdf_full_random_test            t2;  
//  mcdf_reg_write_read_test         t3; 
//  mcdf_reg_illegal_access_test     t4;
//  mcdf_channel_disable_test        t5;
//  mcdf_arbiter_priority_test       t6;
//  mcdf_formatter_length_test       t7;
//  mcdf_formatter_grant_test        t8;
//  mcdf_addr_illegal_access_test    t9;
//  mcdf_formatter_length_change_test  t10;