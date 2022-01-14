//发送逻辑电路
module UART_launcher(
    CLK_BPS,
    reset,
    en_launch,
    launch_data,
    uart_rxd_out,
    launch_data_counter
    );

    input CLK_BPS;
    input reset;
    input en_launch;
    input [7:0] launch_data;
    output reg uart_rxd_out = 1;
    output reg [3:0] launch_data_counter  = 0;

    always @(posedge CLK_BPS) begin
        case (reset)
            1'b0: begin
                case (en_launch)
                    1'b1: begin
                        case (launch_data_counter)
                            4'b0000: uart_rxd_out = 0;
                            4'b0001: uart_rxd_out = launch_data[0];
                            4'b0010: uart_rxd_out = launch_data[1];
                            4'b0011: uart_rxd_out = launch_data[2];
                            4'b0100: uart_rxd_out = launch_data[3];
                            4'b0101: uart_rxd_out = launch_data[4];
                            4'b0110: uart_rxd_out = launch_data[5];
                            4'b0111: uart_rxd_out = launch_data[6];
                            4'b1000: uart_rxd_out = launch_data[7];
                            4'b1001: uart_rxd_out = 1; //RAM更换下一排数据
                            default: uart_rxd_out = 1;
                        endcase
                        if (launch_data_counter >= 9)
                            launch_data_counter = 0;
                        else
                            launch_data_counter = launch_data_counter + 1;
                    end
                    1'b0: begin
                        launch_data_counter = 0;
                        uart_rxd_out = 1;
                    end
                    default: begin
                        launch_data_counter = 0;
                        uart_rxd_out = 1;
                    end

                endcase
            end
            1'b1: begin
                launch_data_counter = 0;
                uart_rxd_out = 1;
            end
            default: begin
                launch_data_counter = 0;
                uart_rxd_out = 1;
            end
        endcase
    end
  
endmodule
