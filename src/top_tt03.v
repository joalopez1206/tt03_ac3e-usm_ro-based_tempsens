`timescale 1ns / 1ps

module top_tt03(input [7:0] io_in, output [7:0] io_out);

wire clk, en, reset, rx, rx_ready, tx, tx_start, tx_busy, sum_ready, sum_en, test;
wire [15:0] promedio;
wire [7:0] rx_data;
reg [7:0] tx_data;
wire [1:0] send_sel;

assign clk = io_in[0];
assign en = io_in[1];
assign reset = io_in[2];
assign rx = io_in[3];

assign io_out[0] = tx;

wire out_osc;
wire [15:0] count;

always @* begin
	case(send_sel)
		0: tx_data = promedio[7:0];
		1: tx_data = promedio[15:8];
		default: tx_data = promedio[7:0];
	endcase
end

//test_ringosc_vargen osc(en, out_osc);
//ring_osc osc(en, out_osc);
USM_ringoscillator osc(en, out_osc);
contador #(16) cont(out_osc, en, reset, clk, count);
promedio #(16) prom(clk, reset, en, sum_en, count, promedio, sum_ready);

FSM_controller controller(clk, reset, sum_ready, test, rx_ready, rx_data, sum_en, tx_start, send_sel);

uart_basic #(1000000,9600) uart(clk, reset, rx, rx_data, rx_ready, tx, tx_start, tx_data, test);

endmodule
