//发送排队数据储存器：单次发送数据量最多254b
module lauch_RAM(
    reset,
    data_in, //写数据
    data_out, //接UART_launcher中的launch_data
    address, //写地址
    CLK_BPS,
    CLK100MHZ,
    en_write, //写使能
    launch_data_counter,
    address_counter //读到的位置，根据这个位置去判断是否开始下一次写，或是否终止数据发送
);

    input reset;
    input [7:0]data_in;
    output reg [7:0] data_out = 0;
    input [7:0] address; //256b Local RAM
    input CLK_BPS;
    input CLK100MHZ;
    input en_write;
    input [3:0] launch_data_counter;
    output reg [7:0] address_counter = 0;

    reg [7:0] RAM[255:0]; //宽度8 深度256
    integer row;

    //写逻辑电路(无接口协议): 只要有地址，写使能就可以写
    always @(posedge CLK100MHZ) begin
        if (en_write == 1 && reset == 0) //无else产生锁存器
            RAM[address] = data_in;
        else if (reset == 1) begin
            for(row = 0; row <= 255; row = row + 1)
                    RAM[row] = 0;
        end
    end


    //读逻辑电路
    always @(negedge CLK_BPS) begin
        case (reset)
            1'b0: begin
                if (address_counter >= 255) //溢出重读
                    address_counter = 0;
                else begin
                    case (launch_data_counter) //计数与读逻辑
                        4'b1001: address_counter = address_counter + 1;
                        default: data_out = RAM[address_counter];
                    endcase 
                end
            end
            1'b1: begin
                data_out = 0;
                address_counter = 0;
            end
            default: begin
                data_out = 0;
                address_counter = 0;
            end
        endcase
    end

endmodule
