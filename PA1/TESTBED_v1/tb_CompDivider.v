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

`define PERIOD                  20.0
`define RST_CLOCK_CYLCE         2.0
`define TERMINATE_CLOCK_CYCLE   1000.0
 
`define INPUT_FILE              "C:/Users/USER/Desktop/PA1/TESTBED_v1/test_patterns/CompDivider_in.dat"
`define OUTPUT_FILE             "C:/Users/USER/Desktop/PA1/TESTBED_v1/test_patterns/CompDivider_out.dat"

`define NUM_TEST_PATTERN        5

module tb_CompDivider;

    wire            clk;
    wire            rst_n;
    reg             start;
    reg             preload;
    reg [31:0]      divisor;
    reg [31:0]      dividend;

    wire [31:0]     quotient;
    wire [31:0]     remainder;
    wire            valid;

    integer         total_cnt;
    integer         pass_cnt;
    integer         fail_cnt;

    wire glbl_GSR = glbl.GSR;

    clk_gen U_clk_gen(
        .glbl_GSR(glbl_GSR),
        .clk     (clk     ),
        .rst     (        ),
        .rst_n   (rst_n   )
    );

    CompDivider DUT (
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .start      (start      ),
        .preload    (preload    ),
        .divisor    (divisor    ),
        .dividend   (dividend   ),
        .remainder  (remainder  ),
        .quotient   (quotient   ),
        .valid      (valid      )
    );

    integer i;
    integer input_file, output_file;
    reg [127:0] test_pattern;
    reg [31:0] remainder_golden;
    reg [31:0] quotient_golden;

    initial begin
        wait (rst_n === 1'b0);
        total_cnt  <= 0;
        pass_cnt   <= 0;
        fail_cnt   <= 0;
        start      <= 0;
        dividend   <= 32'd0;
        divisor    <= 32'd0;
        preload    <= 1'd0;

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
            {dividend, divisor, remainder_golden, quotient_golden} = test_pattern;
            run_test(dividend, divisor, remainder_golden, quotient_golden);
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
        input [31:0] remainder_golden,
        input [31:0] quotient_golden
    );

        begin

            @(negedge clk);
            dividend  <= a;
            divisor   <= b;
            preload   <= 1'b1;

            @(negedge clk);
            preload   <= 1'b0;
            dividend  <= 32'd0;
            divisor   <= 32'd0;
            start     <= 1'b1;

            @(negedge clk);
            start <= 1'b0;

            wait (valid === 1'b1);
            @(negedge clk);

            total_cnt = total_cnt + 1;

            if (quotient !== quotient_golden || remainder !== remainder_golden) begin
                fail_cnt = fail_cnt + 1;
                $display("[FAILED] %0d / %0d = Q:%0d R:%0d (expect Q:%0d R:%0d)",
                        a, b, quotient, remainder, quotient_golden, remainder_golden);
            end else begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] %0d / %0d = Q:%0d R:%0d",
                        a, b, quotient, remainder);
            end
            $fdisplay(output_file, "%h\_%h", remainder, quotient);
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
