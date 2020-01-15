`include "./clock_gen_1MHz.v"
`include "./clock_gen_1Hz.v"


module main(
  input   CLK_IN,
  output  J3_3,
  output  J3_4,
  output LED5);

  wire CLK_1MHz;
  wire CLK_1Hz;

  reg sending = 0;
  reg out = 0;

  reg [31:0] data = 32'b11110000111100001111000011110000;

  reg [29:0] syncFrame = 30'b111111111111111000100000000000;
  reg [18:0] dataHeader = 19'b1111111111111110010;
  reg [18:0] resetFrame = 19'b1111111111111110100;

  parameter syncFrame_bits = 30 - 1;
  parameter dataHeader_bits = 19 - 1;
  parameter resetFrame_bits = 19 - 1;

  reg [7:0] bitIndex = syncFrame_bits;

  reg [9:0] delayCounter = 10'b0;

  localparam  STATE_DELAY       = 4'd0;
  localparam  STATE_SYNC        = 4'd1;
  localparam  STATE_RESET       = 4'd2;
  localparam  STATE_DATA_HEADER = 4'd3;
  localparam  STATE_DATA        = 4'd4;

  reg [3:0] state = STATE_SYNC; // 0 = delay, 1 = sync frame, 2 = reset frame, 3 = data header, 4 = led data
  reg [3:0] nextState = 3;

  reg [38:0] led_data = 39'b011111111111101111111111110111111111111;

  parameter data_bits = 39 - 1;

  reg [2:0] led_index = 3'b0;
  parameter leds = 3;

  reg color = 0;
  reg pause = 1;

  clock_gen_1MHz clock1MHz(CLK_IN,CLK_1MHz);
  clock_gen_1Hz clock1Hz(CLK_1MHz,CLK_1Hz);

  always @(posedge CLK_1MHz) begin

    if (state == STATE_DELAY) begin

      sending <= 0;
      delayCounter <= delayCounter + 1;

      if(delayCounter == 999) begin
        delayCounter <= 0;
        state <= nextState;
      end

    end else if (state == STATE_SYNC) begin

      out <= syncFrame[bitIndex];
      sending <= 1;

      if(bitIndex == 0)
      begin
        bitIndex <= syncFrame_bits;
        nextState <= STATE_DATA_HEADER;
        state <= STATE_DELAY;
      end else begin
        bitIndex <= bitIndex - 1;
      end

    end else if (state == STATE_RESET) begin

      out <= resetFrame[bitIndex];
      sending <= 1;

      if(bitIndex == 0)
      begin
        bitIndex <= resetFrame_bits;
        nextState <= STATE_DATA_HEADER;
        state <= STATE_DELAY;
      end else begin
        bitIndex <= bitIndex - 1;
      end

    end else if (state == STATE_DATA_HEADER) begin

      out <= dataHeader[bitIndex];
      sending <= 1;

      if(bitIndex == 0) begin
        bitIndex <= data_bits;
        state <= STATE_DATA;
      end else begin
        bitIndex <= bitIndex - 1;
      end

    end else if (state == STATE_DATA) begin

      sending <= 1;

      if (pause != 0) begin
        out <= led_data[bitIndex];
      end else begin
        out <= 0;
      end

      if(bitIndex == 0) begin

        if(led_index == leds) begin
          bitIndex <= dataHeader_bits;
          nextState <= STATE_DATA_HEADER;
          state <= STATE_DELAY;
          led_index <= 0;
        end else begin
          bitIndex <= data_bits;
          led_index <= led_index + 1;
        end

      end else begin
        bitIndex <= bitIndex - 1;
      end

    end

  end

  always @(posedge CLK_1Hz) begin

    color <= ~color;

    if(color == 0) begin
      led_data <= 39'b000000000000001111111111110000000000000;
    end else begin
      led_data <= 39'b011111111111100000000000000000000000000;
    end

  end

  assign J3_3 = CLK_1MHz;
  assign J3_4 = (out ^ ~CLK_1MHz) & sending;

endmodule
