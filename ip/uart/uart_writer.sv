`timescale 1ns / 1ps

module uart_writer #(
    parameter int INPUT_CLK_SPEED = 11_520_000,  // Hz, 11.52 MHz
    parameter int UART_BAUD_RATE = 115_200  // Hz
) (
    input clk_i,
    input rst_ni,
    input [7:0] data_i,
    input wr_i,
    output logic busy_o,
    output logic uart_tx_o
);
  localparam int ClkDiv = INPUT_CLK_SPEED / UART_BAUD_RATE;

  logic [$clog2(ClkDiv)-1:0] div_cnt;
  logic [9:0] shift_reg;  // {stop bit, data[7:0], start bit}, lsb first
  logic [3:0] bit_cnt;

  assign uart_tx_o = busy_o ? shift_reg[0] : 1'b1;  // idles high

  always_ff @(posedge clk_i or negedge rst_ni) begin : uart_clocked
    if (!rst_ni) begin
      div_cnt <= '0;
      bit_cnt <= '0;
      shift_reg <= '0;
      busy_o <= 1'b0;
    end else begin
      if (busy_o) begin
        if (div_cnt == ClkDiv - 1) begin
          div_cnt   <= '0;
          shift_reg <= {1'b1, shift_reg[9:1]};

          if (bit_cnt == 4'd9) begin  // last bit
            busy_o <= 1'b0;
          end else begin
            bit_cnt <= bit_cnt + 1'b1;
          end
        end else begin
          div_cnt <= div_cnt + 1'b1;
        end
      end else begin  // !busy_o
        bit_cnt <= '0;
        div_cnt <= '0;

        if (wr_i) begin
          shift_reg <= {1'b1, data_i, 1'b0};
          busy_o <= 1'b1;
        end
      end
    end
  end
endmodule
