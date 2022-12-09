library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
  port (
	clk: in std_logic;
	reset: in std_logic;
	inst_1_valid_in: in std_logic;
	inst_2_valid_in: in std_logic;
	Instr1_in: in std_logic_vector(15 downto 0);
	Instr2_in: in std_logic_vector(15 downto 0);
	PC_in: in std_logic_vector(15 downto 0);
	Nxt_PC_in: in std_logic_vector(15 downto 0);
	br_inst_valid_in: in std_logic;
	br_btag_in: in std_logic_vector(2 downto 0);
	br_self_tag_in: in std_logic_vector(2 downto 0);
	stall_in: in std_logic;
	instr_invalidate_in: in std_logic;
	
	I1_valid: out std_logic;
	I1_op_code: out std_logic_vector(3 downto 0);
	I1_op_cz: out std_logic_vector(1 downto 0);
	I1_dest_code: out std_logic_vector(2 downto 0);
	I1_operand_1_code: out std_logic_vector(2 downto 0);
	I1_operand_2_code: out std_logic_vector(2 downto 0);
	I1_Imm: out std_logic_vector(15 downto 0);
	I1_PC: out std_logic_vector(15 downto 0);
	I1_Nxt_PC: out std_logic_vector(15 downto 0);
	I1_BTAG: out std_logic_vector(2 downto 0);
	I1_self_tag: out std_logic_vector(2 downto 0);

	I2_valid: out std_logic;
	I2_op_code: out std_logic_vector(3 downto 0);
	I2_op_cz: out std_logic_vector(1 downto 0);
	I2_dest_code: out std_logic_vector(2 downto 0);
	I2_operand_1_code: out std_logic_vector(2 downto 0);
	I2_operand_2_code: out std_logic_vector(2 downto 0);
	I2_Imm: out std_logic_vector(15 downto 0);
	I2_PC: out std_logic_vector(15 downto 0);
	I2_Nxt_PC: out std_logic_vector(15 downto 0);
	I2_BTAG: out std_logic_vector(2 downto 0);
	I2_self_tag: out std_logic_vector(2 downto 0);
	
	stall_out: out std_logic;
	current_BTAG_out: out std_logic_vector(2 downto 0)
  );
end entity ;

architecture arch of decode is

	signal current_BTAG: std_logic_vector(2 downto 0) := "000";

begin

	Stall_proc : process(reset, Instr1_in,Instr2_in,current_BTAG,inst_1_valid_in,inst_2_valid_in)
	variable stall_out_v: std_logic;
	begin
		if (reset = '1') then
			stall_out_v := '0';
		else
			if (inst_2_valid_in = '1') then
				if(Instr2_in(15 downto 12) = "1100" or Instr2_in(15 downto 12) = "1000" or Instr2_in(15 downto 12) = "1001") then
					if (current_BTAG = "011") then
						stall_out_v := '1';
					else
						stall_out_v := '0';
					end if ;
				else
					stall_out_v := '0';
				end if;
			else
				stall_out_v := '0';	
			end if ;
		end if ;
		stall_out <= stall_out_v;
	end process ;

	Decoder : process(clk,reset,inst_2_valid_in,inst_1_valid_in,Instr2_in,Instr1_in,PC_in,Nxt_PC_in)
		variable I1_valid_v: std_logic;
		variable I1_opcode_v: std_logic_vector(3 downto 0);
		variable I1_op_cz_v: std_logic_vector(1 downto 0);
		variable I1_dest_code_v: std_logic_vector(2 downto 0);
		variable I1_opr1_code_v: std_logic_vector(2 downto 0);
		variable I1_opr2_code_v: std_logic_vector(2 downto 0);
		variable I1_Imm_v: std_logic_vector(15 downto 0);
		variable I1_PC_v: std_logic_vector(15 downto 0);
		variable I1_Nxt_PC_v: std_logic_vector(15 downto 0);
		variable I1_BTAG_v: std_logic_vector(2 downto 0);
		variable I1_self_tag_v: std_logic_vector(2 downto 0); 

		variable I2_valid_v: std_logic;
		variable I2_opcode_v: std_logic_vector(3 downto 0);
		variable I2_op_cz_v: std_logic_vector(1 downto 0);
		variable I2_dest_code_v: std_logic_vector(2 downto 0);
		variable I2_opr1_code_v: std_logic_vector(2 downto 0);
		variable I2_opr2_code_v: std_logic_vector(2 downto 0);
		variable I2_Imm_v: std_logic_vector(15 downto 0);
		variable I2_PC_v: std_logic_vector(15 downto 0);
		variable I2_Nxt_PC_v: std_logic_vector(15 downto 0);
		variable I2_BTAG_v: std_logic_vector(2 downto 0);
		variable I2_self_tag_v: std_logic_vector(2 downto 0);

		variable current_BTAG_v: std_logic_vector(2 downto 0); 
		variable const_zero: std_logic_vector(15 downto 0) := "0000000000000000";
		variable const_zero_LHI: std_logic_vector(6 downto 0) := "0000000";

	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				I1_valid <= '0';
				I1_op_code <= (others => '0');
				I1_op_cz <= (others => '0');
				I1_dest_code <= (others => '0');
				I1_operand_1_code <= (others => '0');
				I1_operand_2_code <= (others => '0');
				I1_Imm <= (others => '0');
				I1_PC <= (others => '0');
				I1_Nxt_PC <= (others => '0');
				I1_BTAG <= (others => '0');
				I1_self_tag <= (others => '0');
				I2_valid <= '0';
				I2_op_code <= (others => '0');
				I2_op_cz <= (others => '0');
				I2_dest_code <= (others => '0');
				I2_operand_1_code <= (others => '0');
				I2_operand_2_code <= (others => '0');
				I2_Imm <= (others => '0');
				I2_PC <= (others => '0');
				I2_Nxt_PC <= (others => '0');
				I2_BTAG <= (others => '0');
				I2_self_tag <= (others => '0');
				current_BTAG <= (others => '0');
			else
				if (br_inst_valid_in = '1') then
					if (br_self_tag_in = "001" and br_btag_in = "000") then
						current_BTAG_v(0) := '0';
					elsif (br_self_tag_in = "010" and br_btag_in = "000") then
						current_BTAG_v(1) := '0';
					elsif (br_self_tag_in = "011" and br_btag_in = "001") then
						current_BTAG_v(1) := '0';
					elsif (br_self_tag_in = "011" and br_btag_in = "010") then
						current_BTAG_v(0) := '0';
					else
						current_BTAG_v:= current_BTAG;
					end if ;
				else
					current_BTAG_v := current_BTAG;
				end if ;
				if (stall_in = '1') then
					if (instr_invalidate_in = '1') then
						I1_valid <= '0';
						I2_valid <= '0';
					end if ;
				else
					if (instr_invalidate_in = '1') then
						I1_valid <= '0';
						I2_valid <= '0';
					else
						if (inst_1_valid_in = '1') then
							case(Instr1_in(15 downto 12)) is
								when "0000" =>
								--ADD/ADC/ADZ
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := const_zero;
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";
								when "0010" =>
								-- NDU/NDZ/NDC
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := const_zero;
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";
								when "0001" =>
								-- ADI
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(4 downto 0) ;
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";	
								when "0011" =>
								-- LHI
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := Instr1_in(8 downto 0) & const_zero_LHI;
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";
								when "0100" =>
								-- LW
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(4 downto 0);
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";
								when "0101" =>
								-- SW
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(5) & Instr1_in(4 downto 0);
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";
								when others =>
								I1_valid_v := inst_1_valid_in;
								I1_opcode_v := Instr1_in(15 downto 12);
								I1_op_cz_v := Instr1_in(1 downto 0);
								I1_dest_code_v := Instr1_in(11 downto 9);
								I1_opr1_code_v := Instr1_in(8 downto 6);
								I1_opr2_code_v := Instr1_in(5 downto 3);
								I1_Imm_v := const_zero;
								I1_PC_v := PC_in;
								I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I1_BTAG_v := current_BTAG_v;
								I1_self_tag_v := "000";								
							end case ;	
						else
							I1_valid_v := inst_1_valid_in;
							I1_opcode_v := Instr1_in(15 downto 12);
							I1_op_cz_v := Instr1_in(1 downto 0);
							I1_dest_code_v := Instr1_in(11 downto 9);
							I1_opr1_code_v := Instr1_in(8 downto 6);
							I1_opr2_code_v := Instr1_in(5 downto 3);
							I1_Imm_v := const_zero;
							I1_PC_v := PC_in;
							I1_Nxt_PC_v := std_logic_vector(unsigned(PC_in) + 1);
							I1_BTAG_v := current_BTAG_v;
							I1_self_tag_v := "000";
						end if ;
						if (inst_2_valid_in = '1') then
							case(Instr2_in(15 downto 12)) is
								when "0000" =>
								--ADD/ADC/ADZ
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := const_zero;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "0010" =>
								-- NDU/NDZ/NDC
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := const_zero;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "0001" =>
								-- ADI
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(4 downto 0) ;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "0011" =>
								-- LHI
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := Instr2_in(8 downto 0) & const_zero_LHI;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "0100" =>
								-- LW
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(4 downto 0) ;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "0101" =>
								-- SW
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(4 downto 0) ;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v := "000";
								when "1100" =>
								-- BEQ
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(11 downto 9);
								I2_opr2_code_v := Instr2_in(8 downto 6);
								I2_Imm_v := Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(5) & Instr2_in(4 downto 0) ;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								if (current_BTAG_v = "000") then
									current_BTAG_v := "001";
									I2_self_tag_v := "001";
								elsif (current_BTAG_v = "001") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "010") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "011") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "101") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "110") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "100") then
									current_BTAG_v := "101";
									I2_self_tag_v := "101";
								else
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								end if;
								when "1000" =>
								-- JAL
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := Instr2_in(8 downto 0) & const_zero_LHI;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								if (current_BTAG_v = "000") then
									current_BTAG_v := "001";
									I2_self_tag_v := "001";
								elsif (current_BTAG_v = "001") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "010") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "011") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "101") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "110") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "100") then
									current_BTAG_v := "101";
									I2_self_tag_v := "101";
								else
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								end if;
								when "1001" =>
								-- JLR
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := const_zero;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								if (current_BTAG_v = "000") then
									current_BTAG_v := "001";
									I2_self_tag_v := "001";
								elsif (current_BTAG_v = "001") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "010") then
									current_BTAG_v := "011";
									I2_self_tag_v := "011";
								elsif (current_BTAG_v = "011") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "101") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "110") then
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								elsif (current_BTAG_v = "100") then
									current_BTAG_v := "101";
									I2_self_tag_v := "101";
								else
									current_BTAG_v := "111";
									I2_self_tag_v := "111";
								end if;
								when others =>
								I2_valid_v := inst_2_valid_in;
								I2_opcode_v := Instr2_in(15 downto 12);
								I2_op_cz_v := Instr2_in(1 downto 0);
								I2_dest_code_v := Instr2_in(11 downto 9);
								I2_opr1_code_v := Instr2_in(8 downto 6);
								I2_opr2_code_v := Instr2_in(5 downto 3);
								I2_Imm_v := const_zero;
								I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
								I2_Nxt_PC_v := Nxt_PC_in;
								I2_BTAG_v := current_BTAG_v;
								I2_self_tag_v :=  "000";
							end case ;	
						else
							I2_valid_v := inst_2_valid_in;
							I2_opcode_v := Instr2_in(15 downto 12);
							I2_op_cz_v := Instr2_in(1 downto 0);
							I2_dest_code_v := Instr2_in(11 downto 9);
							I2_opr1_code_v := Instr2_in(8 downto 6);
							I2_opr2_code_v := Instr2_in(5 downto 3);
							I2_Imm_v := const_zero;
							I2_PC_v := std_logic_vector(unsigned(PC_in) + 1);
							I2_Nxt_PC_v := Nxt_PC_in;
							I2_BTAG_v := current_BTAG_v;
							I2_self_tag_v :=  "000";
						end if ;

						I1_valid <= I1_valid_v;
						I1_op_code <= I1_opcode_v;
						I1_op_cz <= I1_op_cz_v;
						I1_dest_code <= I1_dest_code_v;
						I1_operand_1_code <= I1_opr1_code_v;
						I1_operand_2_code <= I1_opr2_code_v;
						I1_Imm <= I1_Imm_v;
						I1_PC <= I1_PC_v;
						I1_Nxt_PC <= I1_Nxt_PC_v;
						I1_BTAG <= I1_BTAG_v;
						I1_self_tag <= I1_self_tag_v;
						I2_valid <= I2_valid_v;
						I2_op_code <= I2_opcode_v;
						I2_op_cz <= I2_op_cz_v;
						I2_dest_code <= I2_dest_code_v;
						I2_operand_1_code <= I2_opr1_code_v;
						I2_operand_2_code <= I2_opr2_code_v;
						I2_Imm <= I2_Imm_v;
						I2_PC <= I2_PC_v;
						I2_Nxt_PC <= I2_Nxt_PC_v;
						I2_BTAG <= I2_BTAG_v;
						I2_self_tag <= I2_self_tag_v;
						current_BTAG <= current_BTAG_v;

					end if ;
				end if ;
			end if ;		
		end if ;
	end process ;

	current_BTAG_out <= current_BTAG;

end architecture ; -- arch