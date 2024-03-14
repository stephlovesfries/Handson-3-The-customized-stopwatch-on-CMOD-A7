`timescale 1ns / 1ps


module top_module(
        input sysclk,
        input [1:0] btn,
        output pio1,
        input pio2,
        input pio3,
        input pio4,
        input pio5,
        output pio6,
        output pio37,
        output pio38,
        output pio39,
        output pio40,
        output pio41,
        output pio42,
        output pio43,
        output pio44,
        output pio45,
        output pio46,
        output pio47,
        output pio48,
        output [1:0] led
);

wire rstn;
assign rstn = ~btn[1];
reg CLK1500Hz,CLK500Hz,CLK10Hz;
wire [15:0] bcd_tim;

reg pezio,signal;
reg alwONone;
assign pio6 = signal;
assign pio1 = alwONone;

reg [12:0] CLK_CNTER_1500Hz;
reg [13:0] CLK_CNTER_500Hz;
reg [19:0] CLK_CNTER_10Hz;
reg [3:0] CLK_CNTER_HalfHz;


wire start;
assign start=~btn[0];
assign mindn=~pio2;
assign secdn=~pio3;
assign minup=~pio4;
assign secup=~pio5;

reg seconds,light;

reg running;  //running flag to keep trakc of paused/unpaused state
assign led[0]=running;
assign led[1]=light;
assign pio40=seconds;
reg start_r; // value to read button press into a register value during clock

always@(posedge sysclk)begin // things must always follow the clock, thus this function reads the start button state when clock ticks
    start_r <= start ;
end

always@(negedge start_r, negedge rstn)begin  //function to change the "running" state, resetting it upon reset button and start/stopping on the start button
        if(!rstn) begin
        running <= 0;
        alwONone<=0;
        end
        else 
        running<=~running;
        alwONone<=1;
        end
        
//Generate 1500Hz CLK;
always@(posedge sysclk, negedge rstn)begin
    if(!rstn) begin
        CLK_CNTER_1500Hz<=13'd0;
        CLK1500Hz <= 1'b0;
    end
    else begin
        if(CLK_CNTER_1500Hz == 13'd4000-1'b1) begin
            CLK1500Hz <= ~ CLK1500Hz;
            CLK_CNTER_1500Hz <= 13'd0;
        end
        else CLK_CNTER_1500Hz <= CLK_CNTER_1500Hz + 1'b1;
    end
end

//Generate 500Hz CLK; 
always@(posedge sysclk, negedge rstn) begin
    if(!rstn) begin
        CLK_CNTER_500Hz<=14'h0000;
        CLK500Hz <= 1'b0;
    end
    else begin
        if(CLK_CNTER_500Hz == 14'd12_000-1'b1) begin
            CLK500Hz <= ~ CLK500Hz;
            CLK_CNTER_500Hz <= 14'h0000;
        end
        else CLK_CNTER_500Hz <= CLK_CNTER_500Hz + 1'b1;
    end
end

//Generate 100Hz CLK;
always@(posedge sysclk, negedge rstn)begin
    if(!rstn) begin
        CLK_CNTER_10Hz<=20'd0;
        CLK10Hz <= 1'b0;
    end
    else begin
        if(CLK_CNTER_10Hz == 20'd600024-1'b1) begin
            CLK10Hz <= ~ CLK10Hz;
            CLK_CNTER_10Hz <= 20'd0;
        end
        else CLK_CNTER_10Hz <= CLK_CNTER_10Hz + 1'b1;
    end
end

always@(posedge CLK1500Hz, negedge rstn)begin
if(!rstn) begin
    signal<=0;
    light<=0;
    end
else if(pezio && CLK10Hz) begin
    light<=CLK10Hz;
    signal<=~signal;
    end
else
    signal<=0;
end

reg [3:0] sec_unit_bcd_r,sec_deca_bcd_r,min_unit_bcd_r,min_deca_bcd_r; //Register - (Minute Decade,Minute Unit, Second Decade, Second Unit);

//Generate HalfHz CLK or button fn;
always@(posedge CLK10Hz, negedge rstn)begin
    if(!rstn) begin
        CLK_CNTER_HalfHz<=6'd0;
        sec_unit_bcd_r <= 4'd0; //Clear BCD Number Counter;
        sec_deca_bcd_r <= 4'd3; 
        min_unit_bcd_r <= 4'd0; //Clear BCD Number Counter;
        min_deca_bcd_r <= 4'd3;
        pezio<=0;
        seconds<=0;
    end
    else if (running)begin
            if(CLK_CNTER_HalfHz == 4'd10-1'b1) begin
            CLK_CNTER_HalfHz <= 4'd0;
              seconds<=~seconds;
              /*------------------------------------*/
        if(sec_unit_bcd_r == 4'h0)
            if(sec_deca_bcd_r ==4'h0)
                if(min_unit_bcd_r==4'h0)
                    if(min_deca_bcd_r==4'h0)
                        pezio<=1;
                    else begin
                        min_deca_bcd_r<=min_deca_bcd_r-1'b1;
                        min_unit_bcd_r<=4'h9;
                        sec_deca_bcd_r<=4'h5;
                        sec_unit_bcd_r<=4'h9;
                        end
                else begin
                    min_unit_bcd_r<=min_unit_bcd_r-1'b1;
                    sec_deca_bcd_r<=4'h5;
                    sec_unit_bcd_r<=4'h9;
                    end
            else begin
                sec_deca_bcd_r<=sec_deca_bcd_r-1'b1;
                sec_unit_bcd_r<=4'h9;
                end
        else 
            sec_unit_bcd_r<=sec_unit_bcd_r-1'b1;
        end
        else 
        CLK_CNTER_HalfHz <= CLK_CNTER_HalfHz + 1'b1; 
    end
            /*-----------------*/
    else if (!secup)
        if(sec_unit_bcd_r == 4'h9)
            if(sec_deca_bcd_r == 4'h5)begin
                sec_unit_bcd_r <= 4'h0;
                sec_deca_bcd_r <= 4'h0; 
                end
            else begin
                sec_deca_bcd_r<=sec_deca_bcd_r+1'b1;
                sec_unit_bcd_r<=4'h0;
                end
        else
            sec_unit_bcd_r<=sec_unit_bcd_r+1'd1;
    else if (!secdn)
        if(sec_unit_bcd_r == 4'h0)
            if(sec_deca_bcd_r ==4'h0) begin
                sec_unit_bcd_r<= 4'h9;
                sec_deca_bcd_r<= 4'h5;
                end
            else begin
                sec_deca_bcd_r<=sec_deca_bcd_r-1'b1;
                sec_unit_bcd_r<=4'h9;
                end
        else
            sec_unit_bcd_r<=sec_unit_bcd_r-1'b1;
    else if (!minup)
        if(min_unit_bcd_r == 4'h9)
            if(min_deca_bcd_r == 4'h5)begin
                min_unit_bcd_r<= 4'h0;
                min_deca_bcd_r <= 4'h0; 
                end
            else begin
                min_deca_bcd_r<=min_deca_bcd_r+1'b1;
                min_unit_bcd_r<=4'h0;
                end
        else
            min_unit_bcd_r<=min_unit_bcd_r+1'b1;
    else if (!mindn)begin
        if(min_unit_bcd_r == 4'h0)
            if(min_deca_bcd_r ==4'h0) begin
                min_unit_bcd_r<= 4'h9;
                min_deca_bcd_r <= 4'h5;
                end
            else begin
                min_deca_bcd_r<=min_deca_bcd_r-1'b1;
                min_unit_bcd_r<=4'h9;
                end
            else
                min_unit_bcd_r<=min_unit_bcd_r-1'b1;
        end
    else begin
        min_deca_bcd_r<=min_deca_bcd_r;
        min_unit_bcd_r<=min_unit_bcd_r;
        sec_deca_bcd_r<=sec_deca_bcd_r;
        sec_unit_bcd_r<=sec_unit_bcd_r;
        end
    
     end



//Counter           Upper Limit
//Minute Decade     5
//Minute Unit       9
//Second Decade     5
//Second Unit       9



//When DIG4 on, BCD Number Display at this moment is bcd_tim[3:0];  (i.e Stop Watch - Second Unit)
//When DIG3 on, BCD Number Display at this moment is bcd_tim[7:4];  (i.e Stop Watch - Second Decade)
//When DIG2 on, BCD Number Display at this moment is bcd_tim[11:8]; (i.e Stop Watch - Minute Unit)
//When DIG1 on, BCD Number Display at this moment is bcd_tim[15:12];(i.e Stop Watch - Minute Decade)
assign  bcd_tim[15:12]  = min_deca_bcd_r;
assign  bcd_tim[11:8]   = min_unit_bcd_r;
assign  bcd_tim[7:4]    = sec_deca_bcd_r;
assign  bcd_tim[3:0]    = sec_unit_bcd_r;



Segment segment_u0(rstn,CLK500Hz,bcd_tim,{pio43,pio46,pio47,pio37},{pio38,pio45,pio42,pio41,pio39,pio48,pio44});



endmodule