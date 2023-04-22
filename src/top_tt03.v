`timescale 1ns / 1ps

module top_tt03(input [7:0] io_in, output [7:0] io_out);

wire en, reset, rx, rx_ready, tx, tx_start, tx_busy, sum_ready, sum_en, test;
wire [23:0] promedio;
wire [7:0] rx_data;
reg [7:0] tx_data;
wire [1:0] send_sel;

wire clk_external, clk_sel, clk_internal;
wire clk;

wire osc_sel;

//INPUTS
assign clk_internal = io_in[0];
assign clk_external = io_in[1];
assign clk_sel = io_in[2];
assign en = io_in[3];
assign reset = io_in[4];
assign rx = io_in[5];
assign osc_sel = io_in[6];

//OUTPUTS
assign io_out[0] = tx;
assign io_out[7:1] = 0;

wire out_osc_inv, out_osc_nand, out_osc;
wire [15:0] count;

mux m(clk_external, clk_internal, clk_sel, clk);

always @* begin
	case(send_sel)
		0: tx_data = promedio[7:0];
		1: tx_data = promedio[15:8];
		2: tx_data = promedio[23:16];
		default: tx_data = promedio[7:0];
	endcase
end

USM_ringoscillator_inv2 osc1(en, out_osc_inv);
USM_ringoscillator_nand4 osc2(en, out_osc_nand);

mux m2(out_osc_inv, out_osc_nand, osc_sel, out_osc);

contador #(16) cont(out_osc, en, reset, clk, count);
promedio #(24) prom(clk, reset, en, sum_en, count, promedio, sum_ready);

FSM_controller controller(clk, reset, sum_ready, test, rx_ready, rx_data, sum_en, tx_start, send_sel);

uart_basic #(10000,1000) uart(clk, reset, rx, rx_data, rx_ready, tx, tx_start, tx_data, test);

endmodule
