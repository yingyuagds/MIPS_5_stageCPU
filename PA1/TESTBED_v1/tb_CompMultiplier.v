/*
 *	Testbench for Project Assignment 1
 *	Copyright (C) 2026 Wei Wen Lin, Hong Ming Kang or any person belong IEESLab.
 *	All Right Reserved.
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *	This file is for people who have taken the cource (1142 Computer
 *	Organizarion) to use.
 *	We (IEESLab) are not responsible for any illegal use.
 *
 */
 
`timescale 1ns/1ps

`define PERIOD                  18.0
`define RST_CLOCK_CYLCE         2.0
`define TERMINATE_CLOCK_CYCLE   1000.0

`define INPUT_FILE              "C:/Users/USER/Desktop/PA1/TESTBED_v1/test_patterns/CompMultiplier_in.dat"
`define OUTPUT_FILE             "C:/Users/USER/Desktop/PA1/TESTBED_v1/test_patterns/CompMultiplier_out.dat"

`define NUM_TEST_PATTERN        5

module tb_CompMultiplier;

    wire            clk;
    wire            rst_n;
    reg             start;
    reg             preload;
    reg [31:0]      multiplier;
    reg [31:0]      multiplicand;

    wire [63:0]     product;
    wire            valid;

    // test pattern counters
    integer         total_cnt;
    integer         pass_cnt;
    integer         fail_cnt;

    wire glbl_GSR = glbl.GSR;
    // clock instantiation
    clk_gen U_clk_gen(
        .glbl_GSR(glbl_GSR),
        .clk     (clk     ),
        .rst     (        ),
        .rst_n   (rst_n   )
    );

    // design instantiation
    CompMultiplier DUT (
        .clk            (clk            ),
        .rst_n          (rst_n          ),
        .preload        (preload        ),
        .start          (start          ),
        .multiplier     (multiplier     ),
        .multiplicand   (multiplicand   ),
        .product        (product        ),
        .valid          (valid          )
    );

    integer i;
    integer input_file, output_file;
    reg [127:0] test_pattern;
    reg [63:0] product_golden;

    initial begin

        // wait for reset
        wait (rst_n === 1'b0);
        total_cnt       <= 0;
        pass_cnt        <= 0;
        fail_cnt        <= 0;
        start           <= 0;
        multiplier      <= 32'd0;
        multiplicand    <= 32'd0;
        preload         <= 1'd0;

        input_file = $fopen(`INPUT_FILE,  "r");
        if (input_file === 0) begin
            $display("[ERROR] Cannot open input file: %s. Please check your directory", `INPUT_FILE);
           $finish;
        end

        output_file = $fopen(`OUTPUT_FILE, "w");
        if (output_file === 0) begin
            $display("[ERROR] Cannot open output file: %s. Please check your directory", `OUTPUT_FILE);
            $finish;
        end

        wait (rst_n === 1'b1);
        @(posedge clk);

        // stimulus
        for (i = 0; i < `NUM_TEST_PATTERN; i = i + 1) begin
            $fscanf(input_file, "%h\n", test_pattern);
            {multiplier, multiplicand, product_golden} = test_pattern;
            run_test(multiplier, multiplicand, product_golden);
        end

        // end of stimulis
        check_number_of_passed_test();
        $fclose(input_file);
        $fclose(output_file);
        $finish;
    end

    task run_test(
        input [31:0] a,
        input [31:0] b,
        input [63:0] golden
    );

        begin
            // preload input data
            @(negedge clk);
            multiplier   <= a;
            multiplicand <= b;
            preload      <= 1'b1;

            @(negedge clk);
            preload <= 1'b0;
            multiplier   <= 32'd0;
            multiplicand <= 32'd0;
            // start pulse
            start <= 1'b1;

            @(negedge clk);
            start <= 1'b0;

            // wait until valid
            wait (valid === 1'b1);
            @(negedge clk);

            // update total counter
            total_cnt = total_cnt + 1;

            // check result
            if ($signed(product) !== $signed(golden)) begin
                fail_cnt = fail_cnt + 1;
                $display("[FAILED] %0d * %0d = %0d (expect %0d). Please check your design.",
                          a, b, product, golden);
            end else begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] %0d * %0d = %0d",
                          a, b, product);
            end
            // write out data to output file
            $fdisplay(output_file, "%h", product);
            // delay for 2 clock cycles
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    task check_number_of_passed_test;
        begin
            $display("------------------------------------------------------------");
            $display("[SUMMARY] Total: %0d, Pass: %0d, Fail: %0d", total_cnt, pass_cnt, fail_cnt);

            if (fail_cnt !== 0) begin
                $display("[RESULT] FAIL: There are %0d failed test(s). Please check your design", fail_cnt);
            end else begin
                $display("[RESULT] PASS: All tests passed.");
            end
            $display("------------------------------------------------------------");
        end
    endtask

endmodule

module clk_gen (
    input      glbl_GSR ,
    output reg clk      ,
    output reg rst      ,
    output reg rst_n    
);
    always #(`PERIOD / 2.0) clk = ~clk;

    initial begin
        clk = 1'b0;
        wait (glbl_GSR === 1'b1);
        wait (glbl_GSR === 1'b0);
        @(posedge clk);
        rst = 1'b0; rst_n = 1'b1; #(                    0.5  * `PERIOD);
        rst = 1'b1; rst_n = 1'b0; #((`RST_CLOCK_CYLCE - 0.5) * `PERIOD);
        rst = 1'b0; rst_n = 1'b1; #( `TERMINATE_CLOCK_CYCLE  * `PERIOD);
        $finish;
    end
endmodule
