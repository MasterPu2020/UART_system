//All RIGHTS RESERVED BY CLARK PU
//代码版权归蒲君豪所有
//UART system generation 1.10
//通用串口通信系统模块1.10版本

//NOTE: Avoid to make full use of the RAM! This may lead some errors. 
//It is the best way to reset the RAM after each group of data, and the reset signal expect a BPS-term long.
//注意：尽量避免存满整个RAM，这样很难控制接口协议，容易导致错误，最好在每组数据发送后发送一个BSP周期的reset信号。

module UART_system_top(
    CLK100MHZ,
    reset,
    uart_txd_in,
    uart_rxd_out,
    en_launch, 
    en_write,
    receive_read_address,
    receive_read_data,
    launch_write_address,
    launch_write_data,
    receive_address_counter,
    launch_address_counter
); 

    //GPIO
    input CLK100MHZ;
    input reset;
    input uart_txd_in;
    output uart_rxd_out;

    //internal IO
    input en_launch; //发送使能
    input en_write; //发送ram写使能
    input [7:0] receive_read_address; //接收ram读数据需提供的地址
    output [7:0] receive_read_data; //接收ram读到的数据
    input [7:0] launch_write_address; //发送ram写数据需提供的地址
    input [7:0] launch_write_data; //发送ram写入的数据
    output [7:0] receive_address_counter; //接收ram实时接收并储存到的地址
    output [7:0] launch_address_counter; //发送ram实时发送数据的地址

    //module wire
    wire CLK_BPS;
    wire accept;
    wire [7:0] launch_data;
    wire [3:0] launch_data_counter;
    wire [7:0] receive_data;
    wire [3:0] receive_data_counter;

    //modules
    BPS_timer m1(
        .CLK100MHZ(CLK100MHZ),
        .CLK_BPS(CLK_BPS)
        );

    UART_receiver m2(
        .CLK_BPS(CLK_BPS),
        .reset(reset),
        .uart_txd_in(uart_txd_in),
        .receive_data(receive_data),
        .receive_data_counter(receive_data_counter),
        .accept(accept)
        );

    receive_RAM m3(
        .reset(reset),
        .accept(accept),
        .data_in(receive_data), //接UART_receiver中的receive_data
        .data_out(receive_read_data), //读数据
        .address(receive_read_address), //读地址
        .CLK_BPS(CLK_BPS),
        .CLK100MHZ(CLK100MHZ),
        .receive_data_counter(receive_data_counter),
        .address_counter(receive_address_counter) //写到的位置，根据这个位置去读已写入的数据
    );

    UART_launcher m4(
        .CLK_BPS(CLK_BPS),
        .reset(reset),
        .en_launch(en_launch), //发送使能
        .launch_data(launch_data),
        .uart_rxd_out(uart_rxd_out),
        .launch_data_counter(launch_data_counter)
        );

    lauch_RAM m5(
        .reset(reset),
        .data_in(launch_write_data), //写数据
        .data_out(launch_data), //接UART_launcher中的launch_data
        .address(launch_write_address), //写地址
        .CLK_BPS(CLK_BPS),
        .CLK100MHZ(CLK100MHZ),
        .en_write(en_write), //写使能
        .launch_data_counter(launch_data_counter),
        .address_counter(launch_address_counter) //读到的位置，根据这个位置去判断是否开始下一次写，或是否终止数据发送
    );

endmodule