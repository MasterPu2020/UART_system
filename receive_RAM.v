//接收排队数据储存器：单次接收数据量最多254b
module receive_RAM(
    reset,
    accept,
    data_in, //接UART_receiver中的receive_data
    data_out, //读数据
    address, //读地址
    CLK_BPS,
    CLK100MHZ,
    receive_data_counter,
    address_counter //写到的位置，根据这个位置去读已写入的数据
);
    
    input reset;
    input accept;
    input [7:0] data_in;
    output reg [7:0] data_out;
    input [7:0] address; //256b Local RAM
    input CLK_BPS;
    input CLK100MHZ;
    input [3:0] receive_data_counter;
    output reg [7:0] address_counter = 0; 

    reg [7:0] RAM[255:0]; //宽度8 深度256
    integer row;

    //写逻辑电路
    always @(negedge CLK_BPS) begin //比UART_receiver晚半个周期
        case (reset)
            1'b0: begin
                if (receive_data_counter == 0 && accept == 1) begin //发送数据写入
                    RAM[address_counter] <= data_in;
                    address_counter <= address_counter + 1;
                end
                if (address_counter >= 255) begin //循环写，不中断
                    address_counter = 0;
                end
            end
            1'b1: begin
                for(row = 0; row <= 255; row = row + 1)
                    RAM[row] <= 0;
                address_counter <= 0;
            end
            default: begin
                for(row = 0; row <= 255; row = row + 1)
                    RAM[row] <= 0;
                address_counter <= 0;
            end
        endcase
    end


    //读逻辑电路
    always @(posedge CLK100MHZ) begin
        data_out = RAM[address]; //始终读
    end

endmodule