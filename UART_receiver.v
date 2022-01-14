//接收逻辑电路
module UART_receiver(
    CLK_BPS,
    reset,
    uart_txd_in,
    receive_data,
    receive_data_counter,
    accept
    );

    input CLK_BPS;
    input reset;
    input uart_txd_in;
    output reg [7:0] receive_data = 0;
    output reg [3:0] receive_data_counter = 0;
    output reg accept = 0;

    always @(posedge CLK_BPS) begin
        case (reset)
            1'b0: begin
                if (receive_data_counter == 0 && uart_txd_in == 0) begin
                    receive_data_counter = receive_data_counter + 1;
                    accept = 0;
                end
                else if (receive_data_counter > 0 && receive_data_counter < 9) begin
                    case (receive_data_counter)
                        4'b0001: receive_data[0] = uart_txd_in;
                        4'b0010: receive_data[1] = uart_txd_in;
                        4'b0011: receive_data[2] = uart_txd_in;
                        4'b0100: receive_data[3] = uart_txd_in;
                        4'b0101: receive_data[4] = uart_txd_in;
                        4'b0110: receive_data[5] = uart_txd_in;
                        4'b0111: receive_data[6] = uart_txd_in;
                        4'b1000: receive_data[7] = uart_txd_in;
                        default: receive_data = 0;
                    endcase
                    receive_data_counter = receive_data_counter + 1;
                end
                else if (receive_data_counter == 9 && uart_txd_in == 1) begin
                    receive_data_counter = 0;
                    accept = 1;
                end
                else begin
                    receive_data = 0;
                    receive_data_counter = 0;
                    accept = 0;
                end
            end
            1'b1: begin
                receive_data = 0;
                receive_data_counter = 0;
                accept = 0;
            end
            default: begin
                receive_data = 0;
                receive_data_counter = 0;
                accept = 0;
            end
        endcase
    end

endmodule
