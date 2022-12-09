library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;
entity rob is
  port (
		clk: in std_logic;
		reset: in std_logic;
		rs_1_pc_in: in std_logic_vector(15 downto 0);
		rs_1_original_dest_code_in: in std_logic_vector(2 downto 0);
		rs_1_rename_dest_in: in std_logic_vector(5 downto 0);
		rs_1_rename_c_in: in std_logic_vector(2 downto 0);
		rs_1_rename_z_in: in std_logic_vector(2 downto 0);
		rs_1_btag_in: in std_logic_vector(2 downto 0);
		rs_1_op_code_in: in std_logic_vector(3 downto 0);
		rs_1_inst_valid_in: in std_logic;
		rs_2_pc_in: in std_logic_vector(15 downto 0);
		rs_2_original_dest_code_in: in std_logic_vector(2 downto 0);
		rs_2_rename_dest_in: in std_logic_vector(5 downto 0);
		rs_2_rename_c_in: in std_logic_vector(2 downto 0);
		rs_2_rename_z_in: in std_logic_vector(2 downto 0);
		rs_2_btag_in: in std_logic_vector(2 downto 0);
		rs_2_op_code_in: in std_logic_vector(3 downto 0);
		rs_2_inst_valid_in: in std_logic;
		alu_1_pc_in: in std_logic_vector(15 downto 0);
		alu_1_inst_valid_in: in std_logic;
		alu_1_rf_data_in: in std_logic_vector(15 downto 0);
		alu_1_c_flag_in: in std_logic;
		alu_1_z_flag_in: in std_logic;
		alu_2_pc_in: in std_logic_vector(15 downto 0);
		alu_2_inst_valid_in: in std_logic;
		alu_2_rf_data_in: in std_logic_vector(15 downto 0);
		alu_2_c_flag_in: in std_logic;
		alu_2_z_flag_in: in std_logic;
		ls_pc_in: in std_logic_vector(15 downto 0);
		ls_inst_valid_in: in std_logic;
		ls_addr_in: in std_logic_vector(15 downto 0);
		ls_data_in: in std_logic_vector(15 downto 0);
		br_pc_in: in std_logic_vector(15 downto 0);
		br_inst_valid_in: in std_logic;
		br_btag_in: in std_logic_vector(2 downto 0);
		br_correct_in: in std_logic;
		br_data_in: in std_logic_vector(15 downto 0);
		br_self_tag_in: in std_logic_vector(2 downto 0);
		rf_dest_code_out: out std_logic_vector(2 downto 0);
		rf_data_out: out std_logic_vector(15 downto 0);
		rf_write_en: out std_logic;
		c_flag: out std_logic;
		c_flag_valid: out std_logic;
		z_flag: out std_logic;
		z_flag_valid: out std_logic;
		mem_dest_add: out std_logic_vector(15 downto 0);
		mem_dest_data_out: out std_logic_vector(15 downto 0); -- For SW
		mem_write_en: out std_logic;
		mem_data_in: in std_logic_vector(15 downto 0); -- For LHI
		broadcast_rename_reg_out: out std_logic_vector(5 downto 0);
		broadcast_original_dest_code: out std_logic_vector(2 downto 0);
		broadcast_data_out: out std_logic_vector(15 downto 0);
		broadcast_valid: out std_logic;
		broadcast_btag: out std_logic_vector(2 downto 0);
		rob_stall_out: out std_logic
  );
end entity ;

architecture arc of rob is

	signal rb_pc: slv16_array_t(0 to 63);
	signal rb_original_dest_code: slv3_array_t(0 to 63);
	signal rb_opcode: slv4_array_t(0 to 63);
	signal rb_rf_rename: slv6_array_t(0 to 63);
	signal rb_rf_data: slv16_array_t(0 to 63);
	signal rb_rf_data_valid: slv_array_t(0 to 63);
	signal rb_c_rename: slv3_array_t(0 to 63);
	signal rob_c_data: slv_array_t(0 to 63);
	signal rob_c_data_valid: slv_array_t(0 to 63);
	signal rob_z_rename: slv3_array_t(0 to 63);
	signal rob_z_data: slv_array_t(0 to 63);
	signal rob_z_data_valid: slv_array_t(0 to 63);
	signal rob_mem_add: slv16_array_t(0 to 63);
	signal rob_mem_add_valid: slv_array_t(0 to 63);
	signal rob_mem_data: slv16_array_t(0 to 63);
	signal rob_mem_data_valid: slv_array_t(0 to 63);
	signal rob_btag: slv3_array_t(0 to 63);
	signal rob_entry_valid: slv_array_t(0 to 63);
	signal rob_done: slv_array_t(0 to 63);
	signal current_head: integer := 0;
	signal rob_top:integer := 0;

begin

	ROB_stall_proc : process(current_head,rob_entry_valid,reset)
		variable index: integer:= 0 ;
		variable done: integer:= 0;
	begin
		if (reset = '1') then
			rob_stall_out <= '0';
		else
			index := 0;
			done := 0;
			stall_check : for i in 0 to 62 loop
				if (rob_entry_valid((i+current_head) mod 64) = '1' or (done = 1)) then
				else
					index := i;
					done := 1;
				end if ;
			end loop ; 
			if (done = 1) then
				rob_stall_out <= '0';
			else
				rob_stall_out <= '1';
			end if ;
		end if ;
	end process ; 

	RS_ROB_Entry_Proc : process(clk,rob_btag,reset,current_head,rs_1_inst_valid_in,rs_2_inst_valid_in,rob_c_data,rob_z_data,rob_top,rob_entry_valid,rob_done,rb_rf_data,rob_mem_data,rb_original_dest_code,mem_data_in,rob_mem_add,rb_rf_rename,rb_opcode)
		variable index:integer:= 0; 
		variable done: integer := 0; 
	begin
		if (reset = '1') then
			rf_write_en <= '0';
			rf_data_out <= (others =>'0');
			rf_dest_code_out <= (others => '0');
			c_flag <= '0';
			c_flag_valid <= '0';
			z_flag <= '0';
			z_flag_valid <= '0';
			mem_write_en <= '0';
			mem_dest_add <= (others =>'0');
			mem_dest_data_out <= (others =>'0');
			broadcast_valid <= '0';
			broadcast_data_out <= (others =>'0');
			broadcast_original_dest_code <= (others =>'0');
			broadcast_rename_reg_out <= (others =>'0');
			broadcast_btag <= (others => '0');
		else
			if (rob_entry_valid(rob_top) = '1' and rob_done(rob_top) = '1') then
				if (rb_opcode(rob_top) = "0000" or rb_opcode(rob_top) = "0001" or rb_opcode(rob_top) = "0010") then --ADD,ADI,NDU
					rf_write_en <= '1';
					rf_data_out <= rb_rf_data(rob_top);
					rf_dest_code_out <= rb_original_dest_code(rob_top);
					c_flag <= rob_c_data(rob_top);
					c_flag_valid <= '1';
					z_flag <= rob_z_data(rob_top);
					z_flag_valid <= '1';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');	
				elsif (rb_opcode(rob_top) = "0100") then --LW
					rf_write_en <= '1';
					rf_data_out <= mem_data_in;
					rf_dest_code_out <= rb_original_dest_code(rob_top);
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= rob_mem_add(rob_top);
					mem_dest_data_out <= (others => '0');
					broadcast_valid <= '0';
					broadcast_data_out <= mem_data_in;
					broadcast_original_dest_code <= rb_original_dest_code(rob_top);
					broadcast_rename_reg_out <= rb_rf_rename(rob_top);
					broadcast_btag <= rob_btag(rob_top);
				elsif (rb_opcode(rob_top) = "0101") then --SW
					rf_write_en <= '0';
					rf_data_out <= (others => '0');
					rf_dest_code_out <= (others => '0');
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '1';
					mem_dest_add <= rob_mem_add(rob_top);
					mem_dest_data_out <= rob_mem_data(rob_top);
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');
				elsif (rb_opcode(rob_top) = "0011") then --LHI
					rf_write_en <= '1';
					rf_data_out <= rob_mem_data(rob_top);
					rf_dest_code_out <= rb_original_dest_code(rob_top);
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');					
				elsif (rb_opcode(rob_top) = "1100") then --BEQ
					rf_write_en <= '0';
					rf_data_out <= (others =>'0');
					rf_dest_code_out <= (others => '0');
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');
				elsif (rb_opcode(rob_top) = "1000") then --JAL
					rf_write_en <= '1';
					rf_data_out <= rb_rf_data(rob_top);
					rf_dest_code_out <= rb_original_dest_code(rob_top);
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');
				elsif (rb_opcode(rob_top) = "1001") then --JLR
					rf_write_en <= '1';
					rf_data_out <= rb_rf_data(rob_top);
					rf_dest_code_out <= rb_original_dest_code(rob_top);
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');
				else
					rf_write_en <= '0';
					rf_data_out <= (others =>'0');
					rf_dest_code_out <= (others => '0');
					c_flag <= '0';
					c_flag_valid <= '0';
					z_flag <= '0';
					z_flag_valid <= '0';
					mem_write_en <= '0';
					mem_dest_add <= (others =>'0');
					mem_dest_data_out <= (others =>'0');
					broadcast_valid <= '0';
					broadcast_data_out <= (others =>'0');
					broadcast_original_dest_code <= (others =>'0');
					broadcast_rename_reg_out <= (others =>'0');
					broadcast_btag <= (others => '0');
				end if ;
			else
				rf_write_en <= '0';
				rf_data_out <= (others =>'0');
				rf_dest_code_out <= (others => '0');
				c_flag <= '0';
				c_flag_valid <= '0';
				z_flag <= '0';
				z_flag_valid <= '0';
				mem_write_en <= '0';
				mem_dest_add <= (others =>'0');
				mem_dest_data_out <= (others =>'0');
				broadcast_valid <= '0';
				broadcast_data_out <= (others =>'0');
				broadcast_original_dest_code <= (others =>'0');
				broadcast_rename_reg_out <= (others =>'0');
				broadcast_btag <= (others => '0');
			end if ;
		end if ;
		if (clk'event and clk = '1') then
			if (reset = '1') then
				resetting : for i in 0 to 63 loop
					rob_entry_valid(i) <= '0';
					rob_done(i) <= '0';
					rob_btag(i) <= (others => '0');
					rb_pc(i) <= (others => '0');
					rb_rf_data(i) <= (others => '0');
					rb_rf_rename(i) <= (others => '0');
					rb_rf_data_valid(i) <= '0';
					rob_mem_add(i) <= (others => '0');
					rob_mem_data(i) <= (others => '0');
					rob_mem_data_valid(i) <= '0';
					rob_mem_add_valid(i) <= '0';
					rb_opcode(i) <= (others => '0');
					rb_original_dest_code(i) <= (others => '0');
					rob_c_data(i) <= '0';
					rb_c_rename(i) <= (others => '0');
					rob_c_data_valid(i) <= '0';
					rob_z_data_valid(i) <= '0';
					rob_z_data(i) <= '0';
					rob_z_rename(i) <= (others => '0');
				end loop ; 
				rob_top <= 0;
				current_head <= 0;
			else
				if (rob_entry_valid(rob_top) = '1' and rob_done(rob_top) = '1') then
					rob_entry_valid(rob_top) <= '0';
					rob_top <= (rob_top + 1) mod 64;
				end if ;
				index := 0;
				done := 0;
				index_finding : for i in 0 to 62 loop
					if (rob_entry_valid((i+current_head) mod 64) = '1' or (done = 1)) then
					else
						index := i;
						done := 1;
					end if ;
				end loop ; 
				if (done = 0) then
				else
					if (rs_1_inst_valid_in = '1' and rs_2_inst_valid_in = '1') then
						rb_pc((index+current_head) mod 64) <=  rs_1_pc_in;
						rb_original_dest_code((index+current_head) mod 64) <= rs_1_original_dest_code_in;
						rb_rf_rename((index+current_head) mod 64) <= rs_1_rename_dest_in;
						rb_c_rename((index+current_head) mod 64) <= rs_1_rename_c_in;
						rob_z_rename((index+current_head) mod 64) <= rs_1_rename_z_in;
						rob_btag((index+current_head) mod 64) <=  rs_1_btag_in;
						rb_opcode((index+current_head) mod 64) <= rs_1_op_code_in;
						rob_entry_valid((index+current_head) mod 64) <= rs_1_inst_valid_in;
						rb_rf_data_valid((index+current_head) mod 64) <= '0';
						rob_z_data_valid((index+current_head) mod 64) <= '0';
						rob_c_data_valid((index+current_head) mod 64) <= '0';
						rob_mem_data_valid((index+current_head) mod 64) <= '0';
						rob_mem_add_valid((index+current_head) mod 64) <= '0';
						rob_done((index+current_head) mod 64) <= '0';
						rb_pc((index+1+current_head) mod 64) <=  rs_2_pc_in;
						rb_original_dest_code((index+1+current_head) mod 64) <= rs_2_original_dest_code_in;
						rb_rf_rename((index+1+current_head) mod 64) <= rs_2_rename_dest_in;
						rb_c_rename((index+1+current_head) mod 64) <= rs_2_rename_c_in;
						rob_z_rename((index+1+current_head) mod 64) <= rs_2_rename_z_in;
						rob_btag((index+1+current_head) mod 64) <=  rs_2_btag_in;
						rb_opcode((index+1+current_head) mod 64) <= rs_2_op_code_in;
						rob_entry_valid((index+1+current_head) mod 64) <= rs_2_inst_valid_in;
						rb_rf_data_valid((index+1+current_head) mod 64) <= '0';
						rob_z_data_valid((index+1+current_head) mod 64) <= '0';
						rob_c_data_valid((index+1+current_head) mod 64) <= '0';
						rob_mem_data_valid((index+1+current_head) mod 64) <= '0';
						rob_mem_add_valid((index+1+current_head) mod 64) <= '0';
						rob_done((index+1+current_head) mod 64) <= '0';
						current_head <= current_head + 2;
					end if ;			
				end if ;
				updating_rob_done : for i in 0 to 63 loop
					if (rob_entry_valid(i) = '1') then
						if (rb_opcode(i) = "0000" or rb_opcode(i) = "0001" or rb_opcode(i) = "0010") then
							if (rb_rf_data_valid(i) = '1' and rob_c_data_valid(i) = '1' and rob_z_data_valid(i) = '1' and rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
						elsif (rb_opcode(i) = "0100" or rb_opcode(i) = "0101" or rb_opcode(i) = "0011") then
							if (rob_mem_data_valid(i) = '1' and rob_mem_add_valid(i) = '1' and rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
						elsif (rb_opcode(i) = "1100" and rb_opcode(i) = "1000" and rb_opcode(i) = "1001") then
							if (rb_rf_data_valid(i) = '1' and rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
						end if ;
					end if ;
				end loop ; 
				Inputting_data_loop : for i in 0 to 63 loop
					if (alu_1_pc_in = rb_pc(i)) then
						if (alu_1_inst_valid_in = '1' and rob_entry_valid(i) = '1') then
							rb_rf_data(i) <= alu_1_rf_data_in;
							rb_rf_data_valid(i) <= '1';
							rob_c_data(i) <= alu_1_c_flag_in;
							rob_c_data_valid(i) <= '1';
							rob_z_data(i) <= alu_1_z_flag_in;
							rob_z_data_valid(i) <= '1';
							if (rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
						end if ;
					end if ; 
					if (alu_2_pc_in = rb_pc(i)) then
						if (alu_2_inst_valid_in = '1' and rob_entry_valid(i) = '1') then
							rb_rf_data(i) <= alu_2_rf_data_in;
							rb_rf_data_valid(i) <= '1';
							rob_c_data(i) <= alu_2_c_flag_in;
							rob_c_data_valid(i) <= '1';
							rob_z_data(i) <= alu_2_z_flag_in;
							rob_z_data_valid(i) <= '1';
							if (rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
						end if ;
					end if ; 
					if (ls_pc_in = rb_pc(i)) then
						if (ls_inst_valid_in = '1' and rob_entry_valid(i) = '1') then
							if (ls_inst_valid_in = '1' and rob_entry_valid(i) = '1') then
								rob_mem_data(i) <= ls_data_in;
								rob_mem_data_valid(i) <= '1';
								rob_mem_add(i) <= ls_addr_in;
								rob_mem_add_valid(i) <= '1';
								if (rob_btag(i) = "000") then
									rob_done(i) <= '1';
								else
									rob_done(i) <= '0';
								end if ;
							end if ;
						end if ;
					end if ; 
					if (br_pc_in = rb_pc(i)) then
						if (br_inst_valid_in = '1' and rob_entry_valid(i) = '1') then
							rb_rf_data(i) <= br_data_in;
							rb_rf_data_valid(i) <= '1';
							if (rob_btag(i) = "000") then
								rob_done(i) <= '1';
							else
								rob_done(i) <= '0';
							end if ;
							if (br_self_tag_in = "001" and br_btag_in = "000") then
								if (br_correct_in = '1') then
									btag_clearing_1 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_btag(k)(0) <= '0';
										end if ;
									end loop ; 
								else
									current_head <= i + 1;
									Instruction_invalidating_loop_1 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_entry_valid(k) <= '0';
										end if ;
									end loop ; 
								end if ;
							elsif (br_self_tag_in = "010" and br_btag_in = "000") then
								if (br_correct_in = '1') then
									btag_clearing_2 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_btag(k)(1) <= '0';
										end if ;
									end loop ; 
								else
									current_head <= i + 1;
									Instruction_invalidating_loop_2 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_entry_valid(k) <= '0';
										end if ;
									end loop ; 
								end if ;
							elsif (br_self_tag_in = "011" and br_btag_in = "001") then
								if (br_correct_in = '1') then
									btag_clearing_3 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_btag(k)(1) <= '0';
										end if ;
									end loop ; 
								else
									current_head <= i + 1;
									Instruction_invalidating_loop_3 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_entry_valid(k) <= '0';
										end if ;-- Instruction_invalidating_loop
									end loop ;
								end if ;
							elsif (br_self_tag_in = "011" and br_btag_in = "010") then
								if (br_correct_in = '1') then
									btag_clearing_4 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_btag(k)(0) <= '0';
										end if ;
									end loop ; 
								else
									current_head <= i + 1;
									Instruction_invalidating_loop_4 : for k in 0 to 63 loop
										if (rob_btag(k) = br_self_tag_in) then
											rob_entry_valid(k) <= '0';
										end if ;
									end loop ; 
								end if ;
							end if ;
						end if ;
					end if ; 
				end loop ; 
			end if ;
		end if ;		
	end process ; 

end architecture ; -- arch