/*
 *	Testbench for Project 2 Part 3
 *	Copyright (C) 2026  Hong-Ming Kang or any person belong IEESLab.
 *	All Right Reserved.
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *	This file is for people who have taken the cource (1102 Computer
 *	Organizarion) to use.
 *	We (ESSLab) are not responsible for any illegal use.
 *
 *	NOTE	: FOR COMPATIBILITY OF YOUR CODE, PLEASE DONT CHANGE ANY THING
 *			  IN THIS FILE!
 *
 */

`timescale 1ns/1ps

`define PERIOD                  20.0
`define RST_CLOCK_CYLCE         2.0
`define TERMINATE_CLOCK_CYCLE   10000.0
`define RUN_CLOCK_CYCLE         32

`define LOW     1'b0
`define HIGH    1'b1

`define INSTR_MAX   128
`define DATA_MAX    128
`define REG_MAX     32

`define INSTR_FILE  "C:/Users/USER/Desktop/PA3/part3/dat/IM.dat"
`define DATA_FILE   "C:/Users/USER/Desktop/PA3/part3/dat/DM.dat"
`define OUTPUT_DATA "DM_test.out"

module tb_FinalCPU;

    // --- Signals ---
    reg  [31:0] ext_addr, ext_data;
    reg         ext_we, mem_sel, test_normal;
    wire        clk, rst_n;
    wire [31:0] mem_out;

    reg  [7:0] instrMem [0:`INSTR_MAX-1];
    reg  [7:0] dataMem  [0:`DATA_MAX-1];

    integer output_data, i;

`ifndef USE_EXTERNAL_GLBL
    glbl glbl();
`endif
    wire glbl_GSR = glbl.GSR;

    // --- Clock / Reset Generator ---
    clk_gen U_clk_gen(
        .glbl_GSR(glbl_GSR),
        .clk     (clk     ),
        .rst     (        ),
        .rst_n   (rst_n   )
    );

    // --- UUT Instance ---
    FinalCPU UUT (
        .mem_out    (mem_out    ),
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .test_normal(test_normal),
        .ext_addr   (ext_addr   ),
        .ext_data   (ext_data   ),
        .ext_we     (ext_we     ),
        .mem_sel    (mem_sel    )
    );

    // --- Initialization ---
    initial begin : Preprocess
        ext_addr    = 32'd0;
        ext_data    = 32'd0;
        ext_we      = `LOW;
        mem_sel     = `LOW;
        test_normal = `HIGH;

        $readmemh(`INSTR_FILE, instrMem);
        $readmemh(`DATA_FILE,  dataMem);

        output_data = $fopen(`OUTPUT_DATA, "w");
        if (output_data == 0) begin
            $display("[ERROR] Cannot open output file: %s", `OUTPUT_DATA);
            $finish;
        end
    end

    // --- Main Test Flow ---
    initial begin : StimuliProcess
        wait (rst_n === 1'b0);
        ext_addr    <= 32'd0;
        ext_data    <= 32'd0;
        ext_we      <= `LOW;
        mem_sel     <= `LOW;
        test_normal <= `HIGH;

        wait (rst_n === 1'b1);
        @(negedge clk);

        /////////////////////////////////////////////////////////////////////
        // Start to load external data into memories                       //
        // All external input changes are aligned to negedge clk.          //
        /////////////////////////////////////////////////////////////////////

        // 1. Load IM
        $display("IM Loading...");
        test_normal <= `HIGH;
        mem_sel     <= `LOW;   // Select IM
        ext_we      <= `LOW;
        ext_addr    <= 32'd0;
        ext_data    <= 32'd0;

        for (i = 0; i < `INSTR_MAX; i = i + 4) begin
            @(negedge clk);
            ext_we   <= `HIGH;
            ext_addr <= i;
            ext_data <= {instrMem[i], instrMem[i+1], instrMem[i+2], instrMem[i+3]};
        end

        @(negedge clk);
        ext_we   <= `LOW;
        ext_addr <= 32'd0;
        ext_data <= 32'd0;
        @(negedge clk);
        $display("IM loaded");

        // 2. Load DM
        $display("DM Loading...");
        mem_sel <= `HIGH;      // Select DM
        ext_we  <= `LOW;

        for (i = 0; i < `DATA_MAX; i = i + 4) begin
            @(negedge clk);
            ext_we   <= `HIGH;
            ext_addr <= i;
            ext_data <= {dataMem[i], dataMem[i+1], dataMem[i+2], dataMem[i+3]};
        end

        @(negedge clk);
        ext_we   <= `LOW;
        ext_addr <= 32'd0;
        ext_data <= 32'd0;
        @(negedge clk);
        $display("DM loaded");

        /////////////////////////////////////////////////////////////////////
        // Start to run instructions in IM                                 //
        /////////////////////////////////////////////////////////////////////

        $display("\n--- Start to Run Instructions in IM ---");
        @(negedge clk);
        test_normal <= `LOW;
        mem_sel     <= `LOW;
        ext_we      <= `LOW;
        ext_addr    <= 32'd0;
        ext_data    <= 32'd0;
        repeat (`RUN_CLOCK_CYCLE) @(negedge clk);
        $display("--- Instructions in IM are done ---");

        /////////////////////////////////////////////////////////////////////
        // Dump Results after Instructions in IM are done                  //
        /////////////////////////////////////////////////////////////////////

        $display("\n--- [Data Memory Results] ---");
        @(negedge clk);
        test_normal <= `HIGH;
        mem_sel     <= `HIGH;  // Read out DM
        ext_we      <= `LOW;

        for (i = 0; i < (`DATA_MAX + 8); i = i + 4) begin
            @(negedge clk);

            if (i < `DATA_MAX) begin
                ext_addr <= i;
            end

            if (i >= 8) begin
                $display("DM[%3d] : %h", i - 8, mem_out);
                $fwrite(output_data, "%h\n", mem_out);
            end
        end

        @(negedge clk);
        $fclose(output_data);

        $display("\nSimulation Completed. By IEESLab\n");
        $display("   /\\_/\\   /\\_/\\   /\\_/\\    Congratulations !");
        $display("  ( o.o ) ( -.- ) ( ^_^ )   Please Check <<DM_test.out>>");
        $display("   > ^ <   > ^ <   > ^ <    Wishing you continued success and happiness.  By IEESLab\n");

        $finish;
    end

endmodule

module clk_gen (
    input      glbl_GSR,
    output reg clk,
    output reg rst,
    output reg rst_n
);
    always #(`PERIOD / 2.0) clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        rst_n = 1'b1;

        wait (glbl_GSR === 1'b1);
        wait (glbl_GSR === 1'b0);

        @(posedge clk);
        rst   = 1'b0;
        rst_n = 1'b1;
        #(                    0.5  * `PERIOD);

        rst   = 1'b1;
        rst_n = 1'b0;
        #((`RST_CLOCK_CYLCE - 0.5) * `PERIOD);

        rst   = 1'b0;
        rst_n = 1'b1;
        #( `TERMINATE_CLOCK_CYCLE  * `PERIOD);
        $finish;
    end
endmodule
