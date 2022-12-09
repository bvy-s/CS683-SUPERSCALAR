library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lw_sw_pipeline is
  port(
      pipeline_valid_in: in std_logic;
  		op_code_in: in std_logic_vector(3 downto 0);
  		destn_rename_code_in: in std_logic_vector(5 downto 0);
  		operand1: in std_logic_vector(15 downto 0);--Rb
  		operand2: in std_logic_vector(15 downto 0);--immediate of LHI
      operand3: in std_logic_vector(15 downto 0);
  		z_flag_in: in std_logic;
  		z_rename_in: in std_logic_vector(2 downto 0);
  		b_tag_in: in std_logic_vector(2 downto 0);
  		orig_destn_in: in std_logic_vector(2 downto 0);
		  curr_pc_in: in std_logic_vector(15 downto 0);

  		addr_out: out std_logic_vector(15 downto 0);
      data_out: out std_logic_vector(15 downto 0);--immediate data of LHI
      pipeline_valid_out: out std_logic;
      op_code_out: out std_logic_vector(3 downto 0);
  		destn_rename_code_out: out std_logic_vector(5 downto 0);
  		z_flag_out: out std_logic;
  		z_rename_out: out std_logic_vector(2 downto 0);
  		b_tag_out: out std_logic_vector(2 downto 0);
  		orig_destn_out: out std_logic_vector(2 downto 0);
		  curr_pc_out: out std_logic_vector(15 downto 0);

      lw_sw_brdcst_rename_out: out std_logic_vector(5 downto 0);--rename register broadcast
      lw_sw_brdcst_orig_destn_out: out std_logic_vector(2 downto 0);--if broadcast signal matches other instr with same src register
      lw_sw_brdcst_data_out: out std_logic_vector(15 downto 0); --data of rename register broadcasted
      lw_sw_brdcst_valid_out: out std_logic;--broadcasted data is valid or not 
      
      lw_sw_brdcst_c_flag_out: out std_logic;
      lw_sw_brdcst_c_flag_rename_out: out std_logic_vector(2 downto 0);
      lw_sw_brdcst_c_flag_valid_out: out std_logic;

      lw_sw_brdcst_z_flag_out: out std_logic;
      lw_sw_brdcst_z_flag_rename_out: out std_logic_vector(2 downto 0);
      lw_sw_brdcst_z_flag_valid_out: out std_logic;

      lw_sw_brdcst_btag_out: out std_logic_vector(2 downto 0)--btag of branch for updating copies
    );
end entity;


architecture struc of lw_sw_pipeline is

  signal op1:unsigned (15 downto 0):=(others=>'0');
  signal op2:unsigned (15 downto 0):=(others=>'0');
  signal res:unsigned (15 downto 0):=(others=>'0');
  signal c_res_out:std_logic;
  signal z_res_out:std_logic;

begin

  op1<=unsigned(operand1);
  op2<=unsigned(operand2);

  process(op_code_in,op1,op2,operand3,operand2)
  begin
    if (op_code_in="0100" or op_code_in="0101") then --refers to LW/SW
      res<=op1+op2;
      data_out<=operand3;
    else --LHI
      res<=(others=>'0');
      data_out<=operand2;
    end if;
  end process;

  process(op_code_in,operand2,pipeline_valid_in)
  begin
    if (op_code_in="0100" or op_code_in="0101") then --LW/SW
      lw_sw_brdcst_valid_out <= '0';
      lw_sw_brdcst_data_out <= operand2;
    else --LHI
      lw_sw_brdcst_valid_out <= pipeline_valid_in;
      lw_sw_brdcst_data_out <= operand2; 
    end if;
  end process;

  lw_sw_brdcst_rename_out <= destn_rename_code_in;
  lw_sw_brdcst_orig_destn_out <= orig_destn_in;

  lw_sw_brdcst_c_flag_out <= z_flag_in;
  lw_sw_brdcst_c_flag_rename_out <= z_rename_in;
  lw_sw_brdcst_c_flag_valid_out <= '0';

  lw_sw_brdcst_z_flag_out <= z_flag_in;
  lw_sw_brdcst_z_flag_rename_out <= z_rename_in;
  lw_sw_brdcst_z_flag_valid_out <= '0';

  lw_sw_brdcst_btag_out <= b_tag_in;

  pipeline_valid_out<=pipeline_valid_in;
  op_code_out<=op_code_in;
  destn_rename_code_out<=destn_rename_code_in;
  z_rename_out<=z_rename_in;
  z_flag_out<=z_flag_in;
  b_tag_out<=b_tag_in;
  orig_destn_out<=orig_destn_in;
  curr_pc_out<=curr_pc_in;

  addr_out <= std_logic_vector(res(15 downto 0));

end architecture struc; 