`timescale 1ns/1ps

module traffic_light_controller_tb;

    // ================= DUT INPUTS =================
    reg clk;
    reg rst;

    reg ped_req;

    reg emergency_n;
    reg emergency_e;
    reg emergency_s;
    reg emergency_w;

    // ================= DUT OUTPUTS =================
    wire ns_green, ns_yellow, ns_red;
    wire ew_green, ew_yellow, ew_red;
    wire ped_walk;

    // ================= DUT INSTANTIATION =================
    traffic_light_controller dut (
        .clk(clk),
        .rst(rst),
        .ped_req(ped_req),

        .emergency_n(emergency_n),
        .emergency_e(emergency_e),
        .emergency_s(emergency_s),
        .emergency_w(emergency_w),

        .ns_green(ns_green),
        .ns_yellow(ns_yellow),
        .ns_red(ns_red),

        .ew_green(ew_green),
        .ew_yellow(ew_yellow),
        .ew_red(ew_red),

        .ped_walk(ped_walk)
    );

    // ================= CLOCK GENERATION =================
    always #5 clk = ~clk;

    // ================= TASKS =================

    task reset_system;
    begin
        rst = 1;
        #20;
        rst = 0;
    end
    endtask

    task no_emergency;
    begin
        emergency_n = 0;
        emergency_e = 0;
        emergency_s = 0;
        emergency_w = 0;
    end
    endtask

    task ns_emergency;
    begin
        emergency_n = 1;
        emergency_s = 1;
        emergency_e = 0;
        emergency_w = 0;
    end
    endtask

    task ew_emergency;
    begin
        emergency_n = 0;
        emergency_s = 0;
        emergency_e = 1;
        emergency_w = 1;
    end
    endtask

    task both_emergency;
    begin
        emergency_n = 1;
        emergency_s = 1;
        emergency_e = 1;
        emergency_w = 1;
    end
    endtask

    task pedestrian_request;
    begin
        ped_req = 1;
        #10;
        ped_req = 0;
    end
    endtask

    // ================= MONITOR =================
    always @(posedge clk) begin
        $display("Time=%0t | rst=%b | Clk=%b | NS=%b EW=%b | PED=%b | N_Emergency=%b |E_Emergency=%b | S_EMERGENCY=%b | W_Emergency=%b",
                  $time,rst,clk,
                  ns_green, ew_green,
                  ped_walk,
                  emergency_n, emergency_e, emergency_s, emergency_w);
    end

    // ================= STIMULUS =================
    initial begin

        // INIT
        clk = 0;
        rst = 0;
        ped_req = 0;
        no_emergency();

        // ================= RESET =================
        reset_system();

        // =====================================================
        // TEST 1: NORMAL OPERATION
        // =====================================================
        $display("=====TEST 1 : NORMAL OPERATION=====");
        #100;
        repeat(10) @(posedge clk);

        // =====================================================
        // TEST 2: SINGLE EMERGENCY (NS)
        // =====================================================
        $display("=====TEST 2 : SINGLE EMERGENCY NORTH OR SOUTH ROAD=====");
        ns_emergency();
        #100;
        no_emergency();
        

        // =====================================================
        // TEST 3: SINGLE EMERGENCY (EW)
        // =====================================================
        $display("=====TEST 3 : SINGLE EMERGENCY EAST OR WEST ROAD=====");

        ew_emergency();
        #100;
        no_emergency();

        // =====================================================
        // TEST 4: ROUND-ROBIN CASE 1 (BOTH EMERGENCY)
        // First conflict → NS should win
        // =====================================================
        $display("=====TEST 4 : ROUND ROBBIN CASE 1 (BOTH EMERGENCE N OR S AND E OR W)======");

        both_emergency();
        #100;
        no_emergency();

        // =====================================================
        // TEST 5: ROUND-ROBIN CASE 2 (BOTH EMERGENCY AGAIN)
        // Now EW should win (toggle effect)
        // =====================================================
        $display("=====TEST 5 : ROUND ROBBIN CASE 2 (BOTH EMERGENCE N OR S AND E OR W)=====");
        both_emergency();
        #100;repeat(10)@(posedge clk);
        no_emergency();

        // =====================================================
        // TEST 6: PEDESTRIAN DURING NORMAL OPERATION
        // =====================================================
        $display("=====TEST 6 : PEDESTRAIN DURING NORMAL OPERATION=====");
        pedestrian_request();
        #150;repeat(10)@(posedge clk);

        // =====================================================
        // TEST 7: PED + EMERGENCY MIX
        // =====================================================
        $display("=====TEST 7 : PEDESTRAIN + EMERGENCY AT A TIME=====");
        ped_req = 1;
        ns_emergency();
        #100;repeat(10)@(posedge clk);
        ped_req = 0;
        no_emergency();

        // ================= END =================
        #200;
        $finish;

    end

endmodule