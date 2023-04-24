module contador#(parameter N = 8)(input osc_clk, input en, input reset, input clk, output reg [N-1:0] count);

reg aux;
reg pre_aux;

always @(posedge osc_clk) begin
	if(reset) aux <= 1;
	//else aux <= pre_aux;
end

always @(posedge osc_clk) begin
	if(clk && aux) begin
		aux <= 0;
		count <= 0;
	end
	else if(en) begin
		if(!clk) aux<= 1;
		count <= count + 1;
	end
end

//reg clk_aux;

//always @(posedge osc_clk) begin
//	if(reset) clk_aux <= 0;
//	else clk_aux <= clk;
//end

//wire clk_pulse;
//and andd(clk_pulse, clk, ~clk_aux);

//always @(posedge osc_clk) begin
//	if(reset | clk_pulse | !en) count <= 0;
//	else count <= count + 1;
//end

endmodule
