module uart_rx(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

parameter CLKS_PER_BIT = 868;

reg [15:0] clk_count;
reg [3:0] bit_index;
reg [7:0] rx_shift_reg;
reg rx_busy;

always @(posedge clk or posedge rst) begin

    if (rst) begin
        rx_busy      <= 1'b0;
        clk_count    <= 16'd0;
        bit_index    <= 4'd0;
        rx_shift_reg <= 8'd0;
        rx_data      <= 8'd0;
        rx_done      <= 1'b0;
    end

    else begin

        rx_done <= 1'b0;

        // Detect START bit
        if (!rx_busy) begin

            if (!rx) begin
                rx_busy   <= 1'b1;
                clk_count <= 16'd0;
                bit_index <= 4'd0;
            end

        end

        else begin

            // Wait half bit to reach middle of START bit
            if (bit_index == 0) begin

                if (clk_count < (CLKS_PER_BIT/2)-1) begin
                    clk_count <= clk_count + 1;
                end

                else begin
                    clk_count <= 0;

                    // Confirm START bit
                    if (!rx) begin
                        bit_index <= 1;
                    end
                    else begin
                        rx_busy <= 0;
                    end
                end

            end

            // Receive 8 DATA bits
            else if (bit_index <= 8) begin

                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end

                else begin
                    clk_count <= 0;

                    rx_shift_reg[bit_index-1] <= rx;
                    bit_index <= bit_index + 1;
                end

            end

            // STOP bit
            else begin

                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end

                else begin
                    clk_count <= 0;
                    rx_busy <= 0;
                    rx_data <= rx_shift_reg;
                    rx_done <= 1;
                end

            end
        end
    end
end

endmodule
