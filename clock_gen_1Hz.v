module clock_gen_1Hz(
  input clock_in,
  output clock_out);

  reg [20:0] counter_1Hz;
  parameter period_1Hz = 500000 - 1;
  reg CLK_1Hz;

  always @(posedge clock_in)
  begin
    counter_1Hz <= counter_1Hz + 1;

    if(counter_1Hz == period_1Hz)
    begin
      CLK_1Hz <= ~CLK_1Hz;
      counter_1Hz <= 19'b0;
    end
  end

  assign clock_out = CLK_1Hz;

endmodule
