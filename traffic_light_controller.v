`timescale 1ns/1ps

module traffic_light_controller (

    input clk,
    input rst,

    input ped_req,

    input emergency_n,
    input emergency_e,
    input emergency_s,
    input emergency_w,

    output reg ns_green, ns_yellow, ns_red,
    output reg ew_green, ew_yellow, ew_red,
    output reg ped_walk
);

    // ================= STATES =================
    parameter S_NS_GREEN  = 3'd0;
    parameter S_NS_YELLOW = 3'd1;
    parameter S_EW_GREEN  = 3'd2;
    parameter S_EW_YELLOW = 3'd3;
    parameter S_PED       = 3'd4;
    parameter S_EMERGENCY = 3'd5;

    reg [2:0] state, next_state;

    // ================= TIMER =================
    reg [3:0] timer;

    parameter T_GREEN     = 8;
    parameter T_YELLOW    = 3;
    parameter T_PED       = 5;
    parameter T_EMERGENCY = 6;  // NEW (time slice)

    // ================= PEDESTRIAN =================
    reg ped_pending;

    // ================= EMERGENCY FLAGS =================
    wire em_n = emergency_n;
    wire em_e = emergency_e;
    wire em_s = emergency_s;
    wire em_w = emergency_w;

    wire ns_em = em_n | em_s;
    wire ew_em = em_e | em_w;

    wire any_emergency = ns_em | ew_em;

    // ================= ROUND ROBIN =================
    reg rr_toggle;       // 0 → NS, 1 → EW
    reg emergency_dir;   // selected direction

    // ================= ARBITRATION =================
    always @(*) begin

        emergency_dir = 0;

        if (!any_emergency)
            emergency_dir = 0;

        else if (ns_em && ew_em)
            emergency_dir = rr_toggle;

        else if (ns_em)
            emergency_dir = 0;

        else if (ew_em)
            emergency_dir = 1;

    end

    // ================= STATE REGISTER =================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_NS_GREEN;
            timer <= 0;
            ped_pending <= 0;
            rr_toggle <= 0;
        end 
        else begin

            state <= next_state;

            // ================= TIMER =================
            if (state != next_state)
                timer <= 0;

            // reset timer for emergency switching
            else if (state == S_EMERGENCY && ns_em && ew_em && timer >= T_EMERGENCY)
                timer <= 0;

            else
                timer <= timer + 1;

            // ================= PEDESTRIAN =================
            if (ped_req)
                ped_pending <= 1;

            if (state == S_PED)
                ped_pending <= 0;

            // ================= ROUND ROBIN UPDATE =================

            // continuous alternation when both emergencies active
            if (state == S_EMERGENCY && ns_em && ew_em && timer >= T_EMERGENCY)
                rr_toggle <= ~rr_toggle;

            // toggle when exiting emergency
            else if (state == S_EMERGENCY && next_state != S_EMERGENCY)
                rr_toggle <= ~rr_toggle;

        end
    end

    // ================= NEXT STATE LOGIC =================
    always @(*) begin

        next_state = state;

        // 🚑 EMERGENCY OVERRIDE
        if (any_emergency)
            next_state = S_EMERGENCY;

        else begin
            case (state)

                S_NS_GREEN:
                    if (timer >= T_GREEN)
                        next_state = S_NS_YELLOW;

                S_NS_YELLOW:
                    if (timer >= T_YELLOW)
                        next_state = (ped_pending) ? S_PED : S_EW_GREEN;

                S_EW_GREEN:
                    if (timer >= T_GREEN)
                        next_state = S_EW_YELLOW;

                S_EW_YELLOW:
                    if (timer >= T_YELLOW)
                        next_state = (ped_pending) ? S_PED : S_NS_GREEN;

                S_PED:
                    if (timer >= T_PED)
                        next_state = S_NS_GREEN;

                S_EMERGENCY:
                    if (!any_emergency)
                        next_state = S_NS_GREEN;

            endcase
        end
    end

    // ================= OUTPUT LOGIC =================
    always @(*) begin

        // default safe state
        ns_green = 0; ns_yellow = 0; ns_red = 1;
        ew_green = 0; ew_yellow = 0; ew_red = 1;
        ped_walk = 0;

        case (state)

            // ================= NORMAL =================
            S_NS_GREEN:  ns_green = 1;

            S_NS_YELLOW: ns_yellow = 1;

            S_EW_GREEN:  ew_green = 1;

            S_EW_YELLOW: ew_yellow = 1;

            // ================= PEDESTRIAN =================
            S_PED: begin
                ped_walk = 1;
                ns_red = 1;
                ew_red = 1;
            end

            // ================= EMERGENCY =================
            S_EMERGENCY: begin

                if (emergency_dir == 0) begin
                    // NS direction
                    ns_green = 1;
                    ew_red   = 1;
                end
                else begin
                    // EW direction
                    ew_green = 1;
                    ns_red   = 1;
                end

            end

        endcase
    end

endmodule