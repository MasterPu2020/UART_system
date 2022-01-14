//波特率分频模块，将100MHz的系统时钟信号分频为9600波特率的单周期信号。
//8位数据宽度，10位数据总长，f_new = baud，分频到9600Hz的时钟周期，f_origin/f_new = 10416分频
module BPS_timer(
    CLK100MHZ,
    CLK_BPS	
    );
    
    input CLK100MHZ;
    output reg CLK_BPS = 0;

    reg [12:0] BPS_counter = 0; //10416分频,10416/2计数
	 
    always @ (posedge CLK100MHZ) begin
        if(BPS_counter == 5207) begin //10416分频,10416/2计数
            CLK_BPS = ~ CLK_BPS;
            BPS_counter = 0;
        end
        else
            BPS_counter = BPS_counter + 1; 
    end  

endmodule
