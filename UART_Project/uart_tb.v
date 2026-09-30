`timescale 1ns/1ps

module uart_tb;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire tx_busy;

wire [7:0] rx_data;
wire rx_done;

// UART TX
uart_tx tx_unit (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

// UART RX
// TX output directly connected to RX input
uart_rx rx_unit (
    .clk(clk),
    .rst(rst),
    .rx(tx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

// 50 MHz clock
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    #100;
    rst = 0;

    // Send A5
    #100;
    tx_data = 8'hA5;
    tx_start = 1;

    #20;
    tx_start = 0;

    // Wait for complete TX/RX
    #200000;

    $finish;
end

// Display received data
always @(posedge rx_done) begin
    $display("Received Data = %h", rx_data);
end

// Generate waveform
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_tb);
end

endmodule
