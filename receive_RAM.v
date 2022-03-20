
module receive_RAM

//----------------------------------------------------------------
// Param
//----------------------------------------------------------------

#(
    parameter EN_RESET = 1'b1
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_i
    ,clk_BPS_i
    ,rst_i
    ,accept_i
    ,rece_addr_i //读地址
    ,rece_data_i //接UART_receiver中的receive_data
    ,rece_data_counter_i
    ,rece_data_o //读数据
    ,rece_addr_counter_o //写到的位置，根据这个位置去读已写入的数据
);

    // Inputs
    input rst_i;
    input accept_i;
    input [7:0] rece_data_i;
    input [7:0] rece_addr_i; //256b Local RAM
    input clk_BPS_i;
    input clk_i;
    input [3:0] rece_data_counter_i;

    // Outputs
    output reg [7:0] rece_data_o;
    output reg [7:0] rece_addr_counter_o = 0; 

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

reg [7:0] RAM[255:0]; //宽度8 深度256
integer row;
parameter OFF_RESET = ~ EN_RESET;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

//写逻辑电路
always @(negedge clk_BPS_i) begin //比UART_receiver晚半个周期
    case (rst_i)
        OFF_RESET: begin
            if (rece_data_counter_i == 0 && accept_i == 1) begin //发送数据写入
                RAM[rece_addr_counter_o] <= rece_data_i;
                rece_addr_counter_o <= rece_addr_counter_o + 1;
            end
            if (rece_addr_counter_o >= 255) begin //循环写，不中断
                rece_addr_counter_o = 0;
            end
        end
        EN_RESET: begin
            for(row = 0; row <= 255; row = row + 1)
                RAM[row] <= 0;
            rece_addr_counter_o <= 0;
        end
        default: begin
            for(row = 0; row <= 255; row = row + 1)
                RAM[row] <= 0;
            rece_addr_counter_o <= 0;
        end
    endcase
end


//读逻辑电路
always @(posedge clk_i) begin
    rece_data_o = RAM[rece_addr_i]; //始终读
end

endmodule