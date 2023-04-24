module FSM_controller (
	//INPUTS
	input clk, reset, sum_ready, 
	input tx_busy, 
	input rx_ready,
	input [7:0] rx_data,
	//OUTPUTS
	output reg sum_en,
	output reg tx_send,
	output reg [1:0] send_sel
);

reg [15:0] timer;
reg comand_ready, comand_ready_down;

reg [3:0] state, next_state;
localparam IDLE = 0;
localparam DECODER = 1;
localparam WAIT_SUM = 2;
localparam SEND_SUM_1 = 3;
localparam WAIT_SEND_1 = 4;
localparam SEND_SUM_2 = 5;
localparam WAIT_SEND_2 = 6;
localparam SEND_SUM_3 = 7;
localparam WAIT_SEND_3 = 8;

localparam START_CODE = 0;

always @* begin
	//Default state of outputs
	next_state = state;
	sum_en = 0;
	tx_send = 0;
	send_sel = 0;
	comand_ready_down = 0;
	//FSM core
	case(state)
		//Default state: de cicle start once a uart data has been receive.
		IDLE: begin
			if(comand_ready) begin
				next_state = DECODER;
				comand_ready_down = 1;
			end 
			else next_state = state;
		end
		//Decoder state
		DECODER: begin
			if(rx_data == START_CODE) next_state = WAIT_SUM;
			else next_state = IDLE;
		end
		//State that starts de adder and wait for a result. Also wait for a code sent throught UART
		WAIT_SUM: begin
			sum_en = 1;
			if(comand_ready) begin
				next_state = DECODER;
				comand_ready_down = 1;
			end
			else if(sum_ready) next_state = SEND_SUM_1;
			else next_state = state;
		end
		//send state: enable the uart signal to send the sum with the UART.
		SEND_SUM_1: begin
			tx_send = 1;
			next_state = WAIT_SEND_1;
		end
		WAIT_SEND_1: begin
			if(timer >= 100) next_state = SEND_SUM_2;
		end
		SEND_SUM_2: begin
			tx_send = 1;
			send_sel = 1;
			next_state = WAIT_SEND_2;
		end
		WAIT_SEND_2: begin
			send_sel = 1;
			if(timer >= 100) next_state = SEND_SUM_3;
		end
		SEND_SUM_3: begin
			tx_send = 1;
			send_sel = 2;
			next_state = WAIT_SEND_3;
		end
		WAIT_SEND_3: begin
			send_sel = 2;
			if(timer >= 100) next_state = WAIT_SUM;
		end
	endcase
end
//Stete control
always @(posedge clk) begin
	if(reset) state <= IDLE;
	else state <= next_state;
end

always @(posedge clk) begin
	if(reset) timer <= 0;
	else if(state != next_state) timer <= 0;
	else timer <= timer + 1;
end

always @(posedge clk) begin
	if(reset) comand_ready <= 0;
	else if(rx_ready) comand_ready <= 1;
	else if(comand_ready_down) comand_ready <= 0;
end

endmodule
