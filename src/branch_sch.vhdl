library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;

entity branch_sch is
  port (
		clk: in std_logic;
		reset: in std_logic;
		br_instr_valid_in: in slv_array_t(0 to 9);
		br_op_code_in: in slv4_array_t(0 to 9);
		br_original_dest_in: in slv3_array_t(0 to 9);
		br_rename_dest_in: in slv6_array_t(0 to 9);
		br_operand_1_in: in slv16_array_t(0 to 9);
		br_operand_1_valid_in: in slv_array_t(0 to 9);

		br_operand_2_in: in slv16_array_t(0 to 9);
		br_operand_2_valid_in: in slv_array_t(0 to 9);

		br_operand_3_in: in slv16_array_t(0 to 9);
		br_operand_3_valid_in: in slv_array_t(0 to 9);

		br_pc_in: in slv16_array_t(0 to 9);
		br_nxt_pc_in: in slv16_array_t(0 to 9);
		br_sch_valid_in: in slv_array_t(0 to 9);

		br_btag_in: in slv3_array_t(0 to 9);
		br_self_tag_in: in slv3_array_t(0 to 9);

		br_stall_in: in std_logic;
		

		br_instr_valid_out: out std_logic;
		br_op_code_out: out std_logic_vector(3 downto 0);
		br_original_dest_out: out std_logic_vector(2 downto 0);
		br_rename_dest_out: out std_logic_vector(5 downto 0);
		br_operand_1_out: out std_logic_vector(15 downto 0);--refers to Ra
		
		br_operand_2_out: out std_logic_vector(15 downto 0);--refers to Rb
		
		br_operand_3_out: out std_logic_vector(15 downto 0);--refers to immediate
		
		br_pc_out: out std_logic_vector(15 downto 0);
		br_nxt_pc_out: out std_logic_vector(15 downto 0);
		
		br_btag_out: out std_logic_vector(2 downto 0);
		br_self_tag_out: out std_logic_vector(2 downto 0);
		
		rs_br_index_out: out std_logic_vector(3 downto 0);
		rs_br_valid_out: out std_logic
		);
end entity ;

architecture arc of branch_sch is

begin

	rb_asynchronous : process(reset,br_instr_valid_in,br_sch_valid_in,br_stall_in)
	begin
		if (reset = '1') then
			rs_br_index_out <= std_logic_vector(to_unsigned(0,rs_br_index_out'length));
			rs_br_valid_out <= '0';
		else
			if (br_stall_in = '1') then
				rs_br_valid_out <= '0';
				rs_br_index_out <= std_logic_vector(to_unsigned(0,rs_br_index_out'length));
			else
				if (br_instr_valid_in(0) = '1' and br_sch_valid_in(0) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(0,rs_br_index_out'length));
				elsif (br_instr_valid_in(1) = '1' and br_sch_valid_in(1) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(1,rs_br_index_out'length));
				elsif (br_instr_valid_in(2) = '1' and br_sch_valid_in(2) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(2,rs_br_index_out'length));
				elsif (br_instr_valid_in(3) = '1' and br_sch_valid_in(3) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(3,rs_br_index_out'length));
				elsif (br_instr_valid_in(4) = '1' and br_sch_valid_in(4) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(4,rs_br_index_out'length));
				elsif (br_instr_valid_in(5) = '1' and br_sch_valid_in(5) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(5,rs_br_index_out'length));
				elsif (br_instr_valid_in(6) = '1' and br_sch_valid_in(6) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(6,rs_br_index_out'length));
				elsif (br_instr_valid_in(7) = '1' and br_sch_valid_in(7) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(7,rs_br_index_out'length));
				elsif (br_instr_valid_in(8) = '1' and br_sch_valid_in(8) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(8,rs_br_index_out'length));
				elsif (br_instr_valid_in(9) = '1' and br_sch_valid_in(9) = '1') then
					rs_br_valid_out <= '1';
					rs_br_index_out <= std_logic_vector(to_unsigned(9,rs_br_index_out'length));
				else
					rs_br_index_out <= std_logic_vector(to_unsigned(0,rs_br_index_out'length));
					rs_br_valid_out <= '0';
				end if ;
			end if ;
		end if ;
	end process ;


	Branch_Scheduler : process(clk,br_stall_in,br_instr_valid_in,br_op_code_in,br_original_dest_in,br_rename_dest_in,br_operand_1_in,br_operand_1_valid_in,br_operand_2_in,br_operand_2_valid_in,br_operand_3_in,br_operand_3_valid_in,br_pc_in,br_nxt_pc_in,br_sch_valid_in,br_self_tag_in,br_btag_in)
	
	variable br_instr_valid_v: slv_array_t(0 to 9);
	variable br_opcode_v: slv4_array_t(0 to 9);
	variable br_org_dest_v: slv3_array_t(0 to 9);
	variable br_rename_dest_v: slv6_array_t(0 to 9);

	variable br_opr1_v: slv16_array_t(0 to 9);
	variable br_opr1_valid_v: slv_array_t(0 to 9);

	variable br_opr2_v: slv16_array_t(0 to 9);
	variable br_opr2_valid_v: slv_array_t(0 to 9);

	variable br_opr3_v: slv16_array_t(0 to 9);
	variable br_opr3_valid_v: slv_array_t(0 to 9);

	variable br_pc_v: slv16_array_t(0 to 9);
	variable br_nxt_pc_v: slv16_array_t(0 to 9);
	variable br_sch_valid_v: slv_array_t(0 to 9);

	variable br_btag_v: slv3_array_t(0 to 9);
	variable br_self_tag_v: slv3_array_t(0 to 9);
	

	variable br_instr_valid_out_v: std_logic;
	variable br_opcode_out_v: std_logic_vector(3 downto 0);
	variable br_org_dest_out_v: std_logic_vector(2 downto 0);
	variable br_rename_dest_out_v: std_logic_vector(5 downto 0);
	variable br_opr1_out_v: std_logic_vector(15 downto 0);
	variable br_opr2_out_v: std_logic_vector(15 downto 0);
	variable br_opr3_out_v: std_logic_vector(15 downto 0);

	variable br_pc_out_v: std_logic_vector(15 downto 0);
	variable br_nxt_pc_out_v: std_logic_vector(15 downto 0);
	
	variable br_btag_out_v: std_logic_vector(2 downto 0);
	variable br_self_tag_out_v: std_logic_vector(2 downto 0);


	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				br_instr_valid_out <= '0';
				br_op_code_out <= (others => '0');
				br_original_dest_out <= (others => '0');
				br_rename_dest_out <= (others => '0');
				br_operand_1_out <= (others => '0');
				br_operand_2_out <= (others => '0');
				br_operand_3_out <= (others => '0');
				br_pc_out <= (others => '0');
				br_nxt_pc_out <= (others => '0');
				br_btag_out <= (others => '0');
				br_self_tag_out <= (others => '0');
			else
				br_instr_valid_v:= br_instr_valid_in;  
				br_opcode_v:=  br_op_code_in;
				br_org_dest_v:=  br_original_dest_in;
				br_rename_dest_v:=  br_rename_dest_in;
				br_opr1_v:=  br_operand_1_in;
				br_opr1_valid_v:=  br_operand_1_valid_in;
				br_opr2_v:=  br_operand_2_in;
				br_opr2_valid_v:=  br_operand_2_valid_in;
				br_opr3_v:=  br_operand_3_in;
				br_opr3_valid_v:=  br_operand_3_valid_in;
				br_pc_v:=  br_pc_in;
				br_nxt_pc_v:=  br_nxt_pc_in;
				br_sch_valid_v:=  br_sch_valid_in;
				br_btag_v:=  br_btag_in;
				br_self_tag_v:=  br_self_tag_in;
				if (br_stall_in = '1') then
					--br_instr_valid_out_v := '0';
				else
					if (br_instr_valid_v(0) = '1' and br_sch_valid_v(0) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(0);  
						br_opcode_out_v:=  br_opcode_v(0);
						br_org_dest_out_v:=  br_org_dest_v(0);
						br_rename_dest_out_v:=  br_rename_dest_v(0);
						br_opr1_out_v:=  br_opr1_v(0);
						br_opr2_out_v:=  br_opr2_v(0);
						br_opr3_out_v:=  br_opr3_v(0);
						br_pc_out_v:=  br_pc_v(0);
						br_nxt_pc_out_v:=  br_nxt_pc_v(0);
						br_btag_out_v:=  br_btag_v(0);
						br_self_tag_out_v:=  br_self_tag_v(0);
					elsif (br_instr_valid_v(1) = '1' and br_sch_valid_v(1) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(1);  
						br_opcode_out_v:=  br_opcode_v(1);
						br_org_dest_out_v:=  br_org_dest_v(1);
						br_rename_dest_out_v:=  br_rename_dest_v(1);
						br_opr1_out_v:=  br_opr1_v(1);
						br_opr2_out_v:=  br_opr2_v(1);
						br_opr3_out_v:=  br_opr3_v(1);
						br_pc_out_v:=  br_pc_v(1);
						br_nxt_pc_out_v:=  br_nxt_pc_v(1);
						br_btag_out_v:=  br_btag_v(1);
						br_self_tag_out_v:=  br_self_tag_v(1);
					elsif (br_instr_valid_v(2) = '1' and br_sch_valid_v(2) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(2);  
						br_opcode_out_v:=  br_opcode_v(2);
						br_org_dest_out_v:=  br_org_dest_v(2);
						br_rename_dest_out_v:=  br_rename_dest_v(2);
						br_opr1_out_v:=  br_opr1_v(2);
						br_opr2_out_v:=  br_opr2_v(2);
						br_opr3_out_v:=  br_opr3_v(2);
						br_pc_out_v:=  br_pc_v(2);
						br_nxt_pc_out_v:=  br_nxt_pc_v(2);
						br_btag_out_v:=  br_btag_v(2);
						br_self_tag_out_v:=  br_self_tag_v(2);
					elsif (br_instr_valid_v(3) = '1' and br_sch_valid_v(3) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(3);  
						br_opcode_out_v:=  br_opcode_v(3);
						br_org_dest_out_v:=  br_org_dest_v(3);
						br_rename_dest_out_v:=  br_rename_dest_v(3);
						br_opr1_out_v:=  br_opr1_v(3);
						br_opr2_out_v:=  br_opr2_v(3);
						br_opr3_out_v:=  br_opr3_v(3);
						br_pc_out_v:=  br_pc_v(3);
						br_nxt_pc_out_v:=  br_nxt_pc_v(3);
						br_btag_out_v:=  br_btag_v(3);
						br_self_tag_out_v:=  br_self_tag_v(3);
					elsif (br_instr_valid_v(4) = '1' and br_sch_valid_v(4) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(4);  
						br_opcode_out_v:=  br_opcode_v(4);
						br_org_dest_out_v:=  br_org_dest_v(4);
						br_rename_dest_out_v:=  br_rename_dest_v(4);
						br_opr1_out_v:=  br_opr1_v(4);
						br_opr2_out_v:=  br_opr2_v(4);
						br_opr3_out_v:=  br_opr3_v(4);
						br_pc_out_v:=  br_pc_v(4);
						br_nxt_pc_out_v:=  br_nxt_pc_v(4);
						br_btag_out_v:=  br_btag_v(4);
						br_self_tag_out_v:=  br_self_tag_v(4);
					elsif (br_instr_valid_v(5) = '1' and br_sch_valid_v(5) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(5);  
						br_opcode_out_v:=  br_opcode_v(5);
						br_org_dest_out_v:=  br_org_dest_v(5);
						br_rename_dest_out_v:=  br_rename_dest_v(5);
						br_opr1_out_v:=  br_opr1_v(5);
						br_opr2_out_v:=  br_opr2_v(5);
						br_opr3_out_v:=  br_opr3_v(5);
						br_pc_out_v:=  br_pc_v(5);
						br_nxt_pc_out_v:=  br_nxt_pc_v(5);
						br_btag_out_v:=  br_btag_v(5);
						br_self_tag_out_v:=  br_self_tag_v(5);
					elsif (br_instr_valid_v(6) = '1' and br_sch_valid_v(6) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(6);  
						br_opcode_out_v:=  br_opcode_v(6);
						br_org_dest_out_v:=  br_org_dest_v(6);
						br_rename_dest_out_v:=  br_rename_dest_v(6);
						br_opr1_out_v:=  br_opr1_v(6);
						br_opr2_out_v:=  br_opr2_v(6);
						br_opr3_out_v:=  br_opr3_v(6);
						br_pc_out_v:=  br_pc_v(6);
						br_nxt_pc_out_v:=  br_nxt_pc_v(6);
						br_btag_out_v:=  br_btag_v(6);
						br_self_tag_out_v:=  br_self_tag_v(6);
					elsif (br_instr_valid_v(7) = '1' and br_sch_valid_v(7) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(7);  
						br_opcode_out_v:=  br_opcode_v(7);
						br_org_dest_out_v:=  br_org_dest_v(7);
						br_rename_dest_out_v:=  br_rename_dest_v(7);
						br_opr1_out_v:=  br_opr1_v(7);
						br_opr2_out_v:=  br_opr2_v(7);
						br_opr3_out_v:=  br_opr3_v(7);
						br_pc_out_v:=  br_pc_v(7);
						br_nxt_pc_out_v:=  br_nxt_pc_v(7);
						br_btag_out_v:=  br_btag_v(7);
						br_self_tag_out_v:=  br_self_tag_v(7);
					elsif (br_instr_valid_v(8) = '1' and br_sch_valid_v(8) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(8);  
						br_opcode_out_v:=  br_opcode_v(8);
						br_org_dest_out_v:=  br_org_dest_v(8);
						br_rename_dest_out_v:=  br_rename_dest_v(8);
						br_opr1_out_v:=  br_opr1_v(8);
						br_opr2_out_v:=  br_opr2_v(8);
						br_opr3_out_v:=  br_opr3_v(8);
						br_pc_out_v:=  br_pc_v(8);
						br_nxt_pc_out_v:=  br_nxt_pc_v(8);
						br_btag_out_v:=  br_btag_v(8);
						br_self_tag_out_v:=  br_self_tag_v(8);
					elsif (br_instr_valid_v(9) = '1' and br_sch_valid_v(9) = '1') then
						br_instr_valid_out_v:= br_instr_valid_v(9);  
						br_opcode_out_v:=  br_opcode_v(9);
						br_org_dest_out_v:=  br_org_dest_v(9);
						br_rename_dest_out_v:=  br_rename_dest_v(9);
						br_opr1_out_v:=  br_opr1_v(9);
						br_opr2_out_v:=  br_opr2_v(9);
						br_opr3_out_v:=  br_opr3_v(9);
						br_pc_out_v:=  br_pc_v(9);
						br_nxt_pc_out_v:=  br_nxt_pc_v(9);
						br_btag_out_v:=  br_btag_v(9);
						br_self_tag_out_v:=  br_self_tag_v(9);
					else
						br_instr_valid_out_v := '0';
					end if ;
				end if ;

				br_instr_valid_out <= br_instr_valid_out_v;
				br_op_code_out <= br_opcode_out_v;
				br_original_dest_out <= br_org_dest_out_v;
				br_rename_dest_out <= br_rename_dest_out_v;
				br_operand_1_out <= br_opr1_out_v;
				br_operand_2_out <= br_opr2_out_v;
				br_operand_3_out <= br_opr3_out_v;
				br_pc_out <= br_pc_out_v;
				br_nxt_pc_out <= br_nxt_pc_out_v;
				br_btag_out <= br_btag_out_v;
				br_self_tag_out <= br_self_tag_out_v;

			end if ;
		
		end if ;
	
	end process ; -- Branch_Instruction_scheduler

end architecture ; -- arch