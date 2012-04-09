/*
 DCPU16 Verilog Implementation
 Copyright (C) 2012 Shawn Tan <shawn.tan@sybreon.com>
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.  This program is
 distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or
 FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this program.  If not, see
 <http://www.gnu.org/licenses/>.  */

module dcpu16_alu (/*AUTOARG*/
   // Outputs
   fs_dto, rwd, regR, regO,
   // Inputs
   ab_dti, rrd, opc, regA, regB, clk, pha, rst, ena
   );

   output [15:0] fs_dto,
		 rwd;
   
   output [15:0] regR,
		 regO;

   input [15:0]  ab_dti;
   input [15:0]  rrd;   
   
   input [3:0] 	 opc;

   input [15:0]  regA,
		 regB;   
   
   input 	 clk,
		 pha,
		 rst,
		 ena;

   wire [15:0] 	 src, // a
		 tgt; // b
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		regO;
   reg [15:0]		regR;
   // End of automatics

   assign fs_dto = regR;
   assign rwd = regR;   
   
   assign src = regA;
   assign tgt = regB;   
   
   always @(posedge clk)
     if (rst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	regO <= 16'h0;
	regR <= 16'h0;
	// End of automatics
     end else if (ena) begin
	case (opc)
	  /* Assignment */
	  // 0x1: SET a, b - sets a to b
	  4'h1: {regO, regR} <= {16'hX, tgt};

	  /* Arithmetic */
	  // 0x2: ADD a, b - sets a to a+b, sets O to 0x0001 if there's an overflow, 0x0 otherwise
	  // 0x3: SUB a, b - sets a to a-b, sets O to 0xffff if there's an underflow, 0x0 otherwise
	  // 0x4: MUL a, b - sets a to a*b, sets O to ((a*b)>>16)&0xffff
	  // 0x5: DIV a, b - sets a to a/b, sets O to ((a<<16)/b)&0xffff. if b==0, sets a and O to 0 instead.
	  // 0x6: MOD a, b - sets a to a%b. if b==0, sets a to 0 instead.
	  4'h2: {regO, regR} <= src + tgt;
	  4'h3: {regO, regR} <= src - tgt;
	  4'h4: {regO, regR} <= src * tgt;

	  /* Shift */
	  // 0x7: SHL a, b - sets a to a<<b, sets O to ((a<<b)>>16)&0xffff
	  // 0x8: SHR a, b - sets a to a>>b, sets O to ((a<<16)>>b)&0xffff	 

	  /* Logic */
	  // 0x9: AND a, b - sets a to a&b
	  // 0xa: BOR a, b - sets a to a|b
	  // 0xb: XOR a, b - sets a to a^b
	  4'h9: {regO, regR} <= {16'hX, src & tgt};
	  4'hA: {regO, regR} <= {16'hX, src | tgt};
	  4'hB: {regO, regR} <= {16'hX, src ^ tgt};	  

	  /* Condition */
	  // 0xc: IFE a, b - performs next instruction only if a==b
	  // 0xd: IFN a, b - performs next instruction only if a!=b
	  // 0xe: IFG a, b - performs next instruction only if a>b
	  // 0xf: IFB a, b - performs next instruction only if (a&b)!=0	  	  
	  
	  default: {regO, regR} <= 32'hX;
	  
	endcase // case (opc)	
     end
   
endmodule // dcpu16_alu
