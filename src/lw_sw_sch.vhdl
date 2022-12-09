library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;

entity lw_sw_sch is
	port (	
		clk: in std_logic;
		reset: in std_logic;

		ls_instr_valid_in: in slv_array_t(0 to 9);
		ls_op_code_in: in slv4_array_t(0 to 9);
		ls_original_dest_in: in slv3_array_t(0 to 9);
		ls_rename_dest_in: in slv6_array_t(0 to 9);
		ls_operand_1_in: in slv16_array_t(0 to 9);
		ls_operand_1_valid_in: in slv_array_t(0 to 9);
		ls_operand_2_in: in slv16_array_t(0 to 9);
		ls_operand_2_valid_in: in slv_array_t(0 to 9);
		ls_operand_3_in: in slv16_array_t(0 to 9);
		ls_operand_3_valid_in: in slv_array_t(0 to 9);
		ls_pc_in: in slv16_array_t(0 to 9);
		ls_sch_valid_in: in slv_array_t(0 to 9);
		ls_btag_in: in slv3_array_t(0 to 9);
		ls_stall_in: in std_logic;

		ls_instr_valid_out: out std_logic;
		ls_op_code_out: out std_logic_vector(3 downto 0);
		ls_original_dest_out: out std_logic_vector(2 downto 0);
		ls_rename_dest_out: out std_logic_vector(5 downto 0);
		ls_operand_1_out: out std_logic_vector(15 downto 0);
		ls_operand_2_out: out std_logic_vector(15 downto 0);
		ls_operand_3_out: out std_logic_vector(15 downto 0);
		ls_pc_out: out std_logic_vector(15 downto 0);
		ls_btag_out: out std_logic_vector(2 downto 0);
		rs_ls_index_out: out std_logic_vector(3 downto 0);
		rs_ls_valid_out: out std_logic
	);
end entity ;

architecture arc of lw_sw_sch is
begin

	rl_out : process(reset,ls_instr_valid_in,ls_sch_valid_in,ls_stall_in)

	begin
		if (reset = '1') then
			rs_ls_index_out <= std_logic_vector(to_unsigned(0,rs_ls_index_out'length));
			rs_ls_valid_out <= '0';
		else
			if (ls_stall_in = '1') then
				rs_ls_index_out <= std_logic_vector(to_unsigned(0,rs_ls_index_out'length));
				rs_ls_valid_out <= '0';
			else
				if (ls_instr_valid_in(0) = '1' and ls_sch_valid_in(0) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(0,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(1) = '1' and ls_sch_valid_in(1) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(1,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(2) = '1' and ls_sch_valid_in(2) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(2,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(3) = '1' and ls_sch_valid_in(3) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(3,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(4) = '1' and ls_sch_valid_in(4) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(4,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(5) = '1' and ls_sch_valid_in(5) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(5,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(6) = '1' and ls_sch_valid_in(6) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(6,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(7) = '1' and ls_sch_valid_in(7) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(7,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(8) = '1' and ls_sch_valid_in(8) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(8,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				elsif (ls_instr_valid_in(9) = '1' and ls_sch_valid_in(9) = '1') then
					rs_ls_index_out <= std_logic_vector(to_unsigned(9,rs_ls_index_out'length));
					rs_ls_valid_out <= '1';
				else
					rs_ls_index_out <= std_logic_vector(to_unsigned(0,rs_ls_index_out'length));
					rs_ls_valid_out <= '0';
				end if ;
			end if ;
		end if ;
	end process ;

	Sched_load_store : process(clk,ls_stall_in,ls_instr_valid_in,ls_op_code_in,ls_original_dest_in,ls_rename_dest_in,ls_operand_1_in,ls_operand_2_in,ls_pc_in,ls_sch_valid_in,ls_btag_in)
	
		variable ls_instr_valid_v: slv_array_t(0 to 9);
		variable ls_opcode_v: slv4_array_t(0 to 9);
		variable ls_org_dest_v: slv3_array_t(0 to 9);
		variable ls_rename_dest_v: slv6_array_t(0 to 9);
		variable ls_opr1_v: slv16_array_t(0 to 9);
		variable ls_opr1_valid_v: slv_array_t(0 to 9);
		variable ls_opr2_v: slv16_array_t(0 to 9);
		variable ls_opr2_valid_v: slv_array_t(0 to 9);
		variable ls_opr3_v: slv16_array_t(0 to 9);
		variable ls_opr3_valid_v: slv_array_t(0 to 9);
		variable ls_pc_v: slv16_array_t(0 to 9);
		variable ls_sch_valid_v: slv_array_t(0 to 9);
		variable ls_btag_v: slv3_array_t(0 to 9);

		variable ls_instr_valid_out_v: std_logic;
		variable ls_opcode_out_v: std_logic_vector(3 downto 0);
		variable ls_org_dest_out_v: std_logic_vector(2 downto 0);
		variable ls_rename_dest_out_v: std_logic_vector(5 downto 0);
		variable ls_opr1_out_v: std_logic_vector(15 downto 0);
		variable ls_opr2_out_v: std_logic_vector(15 downto 0);
		variable ls_opr3_out_v: std_logic_vector(15 downto 0);
		variable ls_pc_out_v: std_logic_vector(15 downto 0);
		variable ls_btag_out_v: std_logic_vector(2 downto 0);
	
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				ls_instr_valid_out <= '0';
				ls_op_code_out <= (others => '0');
				ls_original_dest_out <= (others => '0');
				ls_rename_dest_out <= (others => '0');
				ls_operand_1_out <= (others => '0');
				ls_operand_2_out <= (others => '0');
				ls_operand_3_out <= (others => '0');
				ls_pc_out <= (others => '0');
				ls_btag_out <= (others => '0');
			else	
				ls_instr_valid_v := ls_instr_valid_in;
				ls_opcode_v:= ls_op_code_in;
				ls_org_dest_v:= ls_original_dest_in;
				ls_rename_dest_v:= ls_rename_dest_in;
				ls_opr1_v:= ls_operand_1_in;
				ls_opr1_valid_v:= ls_operand_1_valid_in;
				ls_opr2_v:= ls_operand_2_in;
				ls_opr2_valid_v:= ls_operand_2_valid_in;
				ls_opr3_v:= ls_operand_3_in;
				ls_opr3_valid_v:= ls_operand_3_valid_in;
				ls_pc_v:= ls_pc_in;
				ls_sch_valid_v:= ls_sch_valid_in;
				ls_btag_v:= ls_btag_in;

				if (ls_stall_in = '0') then 
					if (ls_instr_valid_v(0) = '1' and ls_sch_valid_v(0) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(0);
						ls_opcode_out_v := ls_opcode_v(0);
						ls_org_dest_out_v := ls_org_dest_v(0);
						ls_rename_dest_out_v := ls_rename_dest_v(0);
						ls_opr1_out_v := ls_opr1_v(0);
						ls_opr2_out_v := ls_opr2_v(0);
						ls_opr3_out_v := ls_opr3_v(0);
						ls_pc_out_v := ls_pc_v(0);
						ls_btag_out_v := ls_btag_v(0);
					elsif (ls_instr_valid_v(1) = '1' and ls_sch_valid_v(1) = '1') then	
						ls_instr_valid_out_v := ls_instr_valid_v(1);
						ls_opcode_out_v := ls_opcode_v(1);
						ls_org_dest_out_v := ls_org_dest_v(1);
						ls_rename_dest_out_v := ls_rename_dest_v(1);
						ls_opr1_out_v := ls_opr1_v(1);
						ls_opr2_out_v := ls_opr2_v(1);
						ls_opr3_out_v := ls_opr3_v(1);
						ls_pc_out_v := ls_pc_v(1);
						ls_btag_out_v := ls_btag_v(1);
					elsif (ls_instr_valid_v(2) = '1' and ls_sch_valid_v(2) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(2);
						ls_opcode_out_v := ls_opcode_v(2);
						ls_org_dest_out_v := ls_org_dest_v(2);
						ls_rename_dest_out_v := ls_rename_dest_v(2);
						ls_opr1_out_v := ls_opr1_v(2);
						ls_opr2_out_v := ls_opr2_v(2);
						ls_opr3_out_v := ls_opr3_v(2);
						ls_pc_out_v := ls_pc_v(2);
						ls_btag_out_v := ls_btag_v(2);
					elsif (ls_instr_valid_v(3) = '1' and ls_sch_valid_v(3) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(3);
						ls_opcode_out_v := ls_opcode_v(3);
						ls_org_dest_out_v := ls_org_dest_v(3);
						ls_rename_dest_out_v := ls_rename_dest_v(3);
						ls_opr1_out_v := ls_opr1_v(3);
						ls_opr2_out_v := ls_opr2_v(3);
						ls_opr3_out_v := ls_opr3_v(3);
						ls_pc_out_v := ls_pc_v(3);
						ls_btag_out_v := ls_btag_v(3);
					elsif (ls_instr_valid_v(4) = '1' and ls_sch_valid_v(4) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(4);
						ls_opcode_out_v := ls_opcode_v(4);
						ls_org_dest_out_v := ls_org_dest_v(4);
						ls_rename_dest_out_v := ls_rename_dest_v(4);
						ls_opr1_out_v := ls_opr1_v(4);
						ls_opr2_out_v := ls_opr2_v(4);
						ls_opr3_out_v := ls_opr3_v(4);
						ls_pc_out_v := ls_pc_v(4);
						ls_btag_out_v := ls_btag_v(4);
					elsif (ls_instr_valid_v(5) = '1' and ls_sch_valid_v(5) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(5);
						ls_opcode_out_v := ls_opcode_v(5);
						ls_org_dest_out_v := ls_org_dest_v(5);
						ls_rename_dest_out_v := ls_rename_dest_v(5);
						ls_opr1_out_v := ls_opr1_v(5);
						ls_opr2_out_v := ls_opr2_v(5);
						ls_opr3_out_v := ls_opr3_v(5);
						ls_pc_out_v := ls_pc_v(5);
						ls_btag_out_v := ls_btag_v(5);
					elsif (ls_instr_valid_v(6) = '1' and ls_sch_valid_v(6) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(6);
						ls_opcode_out_v := ls_opcode_v(6);
						ls_org_dest_out_v := ls_org_dest_v(6);
						ls_rename_dest_out_v := ls_rename_dest_v(6);
						ls_opr1_out_v := ls_opr1_v(6);
						ls_opr2_out_v := ls_opr2_v(6);
						ls_opr3_out_v := ls_opr3_v(6);
						ls_pc_out_v := ls_pc_v(6);
						ls_btag_out_v := ls_btag_v(6);
					elsif (ls_instr_valid_v(7) = '1' and ls_sch_valid_v(7) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(7);
						ls_opcode_out_v := ls_opcode_v(7);
						ls_org_dest_out_v := ls_org_dest_v(7);
						ls_rename_dest_out_v := ls_rename_dest_v(7);
						ls_opr1_out_v := ls_opr1_v(7);
						ls_opr2_out_v := ls_opr2_v(7);
						ls_opr3_out_v := ls_opr3_v(7);
						ls_pc_out_v := ls_pc_v(7);
						ls_btag_out_v := ls_btag_v(7);
					elsif (ls_instr_valid_v(8) = '1' and ls_sch_valid_v(8) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(8);
						ls_opcode_out_v := ls_opcode_v(8);
						ls_org_dest_out_v := ls_org_dest_v(8);
						ls_rename_dest_out_v := ls_rename_dest_v(8);
						ls_opr1_out_v := ls_opr1_v(8);
						ls_opr2_out_v := ls_opr2_v(8);
						ls_opr3_out_v := ls_opr3_v(8);
						ls_pc_out_v := ls_pc_v(8);
						ls_btag_out_v := ls_btag_v(8);
					elsif (ls_instr_valid_v(9) = '1' and ls_sch_valid_v(9) = '1') then
						ls_instr_valid_out_v := ls_instr_valid_v(9);
						ls_opcode_out_v := ls_opcode_v(9);
						ls_org_dest_out_v := ls_org_dest_v(9);
						ls_rename_dest_out_v := ls_rename_dest_v(9);
						ls_opr1_out_v := ls_opr1_v(9);
						ls_opr2_out_v := ls_opr2_v(9);
						ls_opr3_out_v := ls_opr3_v(9);
						ls_pc_out_v := ls_pc_v(9);
						ls_btag_out_v := ls_btag_v(9);
					else
						ls_instr_valid_out_v := '0';
					end if ;				
				end if ;

				ls_instr_valid_out <= ls_instr_valid_out_v;
				ls_op_code_out <= ls_opcode_out_v;
				ls_original_dest_out <= ls_org_dest_out_v;
				ls_rename_dest_out <= ls_rename_dest_out_v;
				ls_operand_1_out <= ls_opr1_out_v;
				ls_operand_2_out <= ls_opr2_out_v;
				ls_operand_3_out <= ls_opr3_out_v;
				ls_pc_out <= ls_pc_out_v;
				ls_btag_out <= ls_btag_out_v;

			end if ;
		end if ;
	end process;

end architecture;