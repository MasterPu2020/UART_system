//All RIGHTS RESERVED BY CLARK PU
//代码版权归蒲君豪所有
//UART system generation 2.0
//通用串口通信系统模块2.0版本

//NOTE: Avoid to make full use of the RAM! This may lead some errors. 
//It is the best way to reset the RAM after each group of data, and the reset signal expect a BPS-term long.
//注意：尽量避免存满整个RAM，这样很难控制接口协议，容易导致错误，最好在每组数据发送后发送一个BSP周期的reset信号。

module UART_system_top

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     CLK100MHZ
    ,reset
    ,uart_txd_in
    ,uart_rxd_out
    ,en_launch
    ,en_write
    ,receive_read_address
    ,receive_read_data
    ,launch_write_address
    ,launch_write_data
    ,receive_address_counter
    ,launch_address_counter
); 

    // Inputs
    input CLK100MHZ;
    input reset;
    input uart_txd_in;
    input en_launch; //发送使能
    input en_write; //发送ram写使能
    input [7:0] receive_read_address; //接收ram读数据需提供的地址
    input [7:0] launch_write_address; //发送ram写数据需提供的地址
    input [7:0] launch_write_data; //发送ram写入的数据

    // Outputs
    output uart_rxd_out;
    output [7:0] receive_read_data; //接收ram读到的数据
    output [7:0] receive_address_counter; //接收ram实时接收并储存到的地址
    output [7:0] launch_address_counter; //发送ram实时发送数据的地址

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

wire CLK_BPS;
wire accept;
wire [7:0] launch_data;
wire [3:0] launch_data_counter;
wire [7:0] receive_data;
wire [3:0] receive_data_counter;

//----------------------------------------------------------------
// Params
//----------------------------------------------------------------

parameter CLK_rate = 100000000;
parameter Baud_rate = 9600;
parameter EN_RESET = 1'b1;
parameter EN_LAUNCH = 1'b1;
parameter EN_W = 1'b1;

//----------------------------------------------------------------
// Modules
//----------------------------------------------------------------

BPS_timer #(CLK_rate, Baud_rate) BPS_timer(
     .clk_i(CLK100MHZ)
    ,.clk_BPS_o(CLK_BPS)
);

UART_receiver #(EN_RESET) UART_receiver(
     .clk_BPS_i(CLK_BPS)
    ,.rst_i(reset)
    ,.uart_i(uart_txd_in)
    ,.rece_data_o(receive_data)
    ,.rece_data_counter_o(receive_data_counter)
    ,.accept_o(accept)
);

receive_RAM #(EN_RESET) receive_RAM(
     .clk_i(CLK100MHZ)
    ,.clk_BPS_i(CLK_BPS)
    ,.rst_i(reset)
    ,.accept_i(accept)
    ,.rece_addr_i() //读地址
    ,.rece_data_i(receive_data) //接UART_receiver中的receive_data
    ,.rece_data_counter_i(receive_data_counter)
    ,.rece_data_o(receive_read_data) //读数据
    ,.rece_addr_counter_o(receive_address_counter) //写到的位置，根据这个位置去读已写入的数据
);

UART_launcher #(EN_RESET, EN_LAUNCH) UART_launcher(
     .clk_BPS_i(CLK_BPS)
    ,.rst_i(reset)
    ,.en_launch_i(en_launch)
    ,.launch_data_i(launch_data)
    ,.uart_o(uart_rxd_out)
    ,.l_data_counter_o(launch_data_counter)
);

lauch_RAM #(EN_RESET, EN_W) lauch_RAM(
     .clk_i(CLK100MHZ)
    ,.clk_BPS_i(CLK_BPS)
    ,.rst_i(reset)
    ,.l_en_w_i(en_write) //写使能
    ,.l_w_addr_i(launch_write_address) //写地址
    ,.l_data_i(launch_write_data) //写数据
    ,.l_data_counter_i(launch_data_counter)
    ,.l_data_o(launch_data) //接UART_launcher中的launch_data
    ,.l_addr_counter_o(launch_address_counter) //读到的位置，根据这个位置去判断是否开始下一次写，或是否终止数据发送
);

endmodule