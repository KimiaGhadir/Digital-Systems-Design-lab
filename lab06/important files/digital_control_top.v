`timescale 1ns/1ps

module digital_control_top #(
    parameter TEMP_WIDTH = 8
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire signed [TEMP_WIDTH-1:0]  temp_c,
    output reg                           heater_on,
    output reg                           cooler_on,
    output reg  [3:0]                    cooler_speed_rps,
    output wire [1:0]                    thermal_state_dbg,
    output wire [1:0]                    speed_state_dbg
);

    // Heater/Cooler ON-OFF FSM states
    localparam [1:0] TH_IDLE = 2'd0;  // S1: Heater OFF, Cooler OFF
    localparam [1:0] TH_COOL = 2'd1;  // S2: Heater OFF, Cooler ON
    localparam [1:0] TH_HEAT = 2'd2;  // S3: Heater ON,  Cooler OFF

    // Cooler Rotational Speed FSM states
    localparam [1:0] CRS_OUT = 2'd0;  // OUT: cooler stopped, 0 RPS
    localparam [1:0] CRS_4   = 2'd1;  // S1: 4 RPS
    localparam [1:0] CRS_6   = 2'd2;  // S2: 6 RPS
    localparam [1:0] CRS_8   = 2'd3;  // S3: 8 RPS

    reg [1:0] thermal_state, thermal_next;
    reg [1:0] speed_state,   speed_next;

    assign thermal_state_dbg = thermal_state;
    assign speed_state_dbg   = speed_state;



    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            thermal_state <= TH_IDLE;
            speed_state   <= CRS_OUT;
        end else begin
            thermal_state <= thermal_next;
            speed_state   <= speed_next;
        end
    end


    always @(*) begin
        thermal_next = thermal_state;

        case (thermal_state)
            TH_IDLE: begin
                if (temp_c > 8'sd35) begin
                    thermal_next = TH_COOL;
                end else if (temp_c < 8'sd15) begin
                    thermal_next = TH_HEAT;
                end
            end

            TH_COOL: begin
                if (temp_c < 8'sd25) begin
                    thermal_next = TH_IDLE;
                end
            end

            TH_HEAT: begin
                if (temp_c > 8'sd30) begin
                    thermal_next = TH_IDLE;
                end
            end

            default: begin

                thermal_next = TH_IDLE;
            end
        endcase
    end


    always @(*) begin
        if (thermal_next != TH_COOL) begin
            speed_next = CRS_OUT;
        end else begin
            speed_next = speed_state;

            case (speed_state)
                CRS_OUT: begin
                    if (temp_c > 8'sd35) begin
                        speed_next = CRS_4;
                    end
                end

                CRS_4: begin
                    if (temp_c < 8'sd25) begin
                        speed_next = CRS_OUT;
                    end else if (temp_c > 8'sd40) begin
                        speed_next = CRS_6;
                    end
                end

                CRS_6: begin
                    if (temp_c < 8'sd35) begin
                        speed_next = CRS_4;
                    end else if (temp_c > 8'sd45) begin
                        speed_next = CRS_8;
                    end
                end

                CRS_8: begin
                    if (temp_c < 8'sd40) begin
                        speed_next = CRS_6;
                    end
                end

                default: begin

                    speed_next = CRS_OUT;
                end
            endcase
        end
    end




    always @(*) begin

        heater_on        = 1'b0;
        cooler_on        = 1'b0;
        cooler_speed_rps = 4'd0;

        case (thermal_state)
            TH_IDLE: begin
                heater_on = 1'b0;
                cooler_on = 1'b0;
            end

            TH_COOL: begin
                heater_on = 1'b0;
                cooler_on = 1'b1;
            end

            TH_HEAT: begin
                heater_on = 1'b1;
                cooler_on = 1'b0;
            end

            default: begin
                heater_on = 1'b0;
                cooler_on = 1'b0;
            end
        endcase

        case (speed_state)
            CRS_OUT: cooler_speed_rps = 4'd0;
            CRS_4:   cooler_speed_rps = 4'd4;
            CRS_6:   cooler_speed_rps = 4'd6;
            CRS_8:   cooler_speed_rps = 4'd8;
            default: cooler_speed_rps = 4'd0;
        endcase
    end

endmodule
