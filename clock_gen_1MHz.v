module clock_gen_1MHz(
  input clock_in,
  output clock_out);

  reg [5:0] counter_1MHz;
  parameter period_1Mhz = 6 - 1;
  reg CLK_1MHz;

  always @(posedge clock_in)
  begin
    counter_1MHz <= counter_1MHz + 1;

    if(counter_1MHz == period_1Mhz)
    begin
      CLK_1MHz <= ~CLK_1MHz;
      counter_1MHz <= 4'b0;
    end
  end

  assign clock_out = CLK_1MHz;

endmodule
