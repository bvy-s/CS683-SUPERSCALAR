library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jump_pipeline is
  port(
      pipeline_valid_in: in std_logic;
  		op_code_in: in std_logic_vector(3 downto 0);
  		destn_rename_code_in: in std_logic_vector(5 downto 0);
  		operand1: in std_logic_vector(15 downto 0);--Ra
  		operand2: in std_logic_vector(15 downto 0);--Rb
      operand3: in std_logic_vector(15 downto 0);--immediate
  		b_tag_in: in std_logic_vector(2 downto 0);
  		orig_destn_in: in std_logic_vector(2 downto 0);
      curr_pc_in: in std_logic_vector(15 downto 0);
      next_pc_in: in std_logic_vector(15 downto 0);
      self_branch_tag_in: in std_logic_vector(2 downto 0);

  		data_out: out std_logic_vector(15 downto 0);
      pipeline_valid_out: out std_logic;
      op_code_out: out std_logic_vector(3 downto 0);
  		destn_rename_code_out: out std_logic_vector(5 downto 0);
  		b_tag_out: out std_logic_vector(2 downto 0);
  		orig_destn_out: out std_logic_vector(2 downto 0);
      curr_pc_out: out std_logic_vector(15 downto 0);
      self_branch_tag_out: out std_logic_vector(2 downto 0);
      branch_addr: out std_logic_vector(15 downto 0);
      reg_write: out std_logic;
      correct: out std_logic;

      jump_brdcst_rename_out:out std_logic_vector(5 downto 0);
      jump_brdcst_orig_destn_out:out std_logic_vector(2 downto 0);
      jump_brdcst_data_out:out std_logic_vector(15 downto 0); 
      jump_brdcst_valid_out:out std_logic;
      jump_brdcst_btag_out:out std_logic_vector(2 downto 0);
      jump_branch_mispredictor:out std_logic_vector(1 downto 0) --sent to RS (misprediction)
    );   
end entity;


architecture struc of jump_pipeline is
  
  signal op1: unsigned (15 downto 0):=(others=>'0');
  signal op2: unsigned (15 downto 0):=(others=>'0');
  signal op3: unsigned (15 downto 0):=(others=>'0');
  signal res: unsigned(15 downto 0):=(others=>'0');
  signal inc: unsigned(15 downto 0):=(others=>'0');
  signal brch: unsigned(15 downto 0):=(others=>'0');

begin

  op1<=unsigned(operand1);
  op2<=unsigned(operand2);
  op3<=unsigned(operand3);
  inc<=to_unsigned(1, 16);

  
  process(op_code_in,op1,op2,op3,curr_pc_in,inc)
  begin
    if (op_code_in="1100") then --BEQ

      reg_write<='0';
      res<=(others=>'0');

      if (op1=op2) then      --BEQ
        brch<=(unsigned(curr_pc_in)+op3);
      else
        brch<=(unsigned(curr_pc_in)+inc);  
      end if;
      
    elsif (op_code_in="1000") then --JAL   
      reg_write<='1';
      res<=unsigned(curr_pc_in);
      brch<=(unsigned(curr_pc_in)+op3);

    else --JLR
      reg_write<='1';
      res<=unsigned(curr_pc_in);
      brch<=(op2); 

    end if;
  end process; 


  process(pipeline_valid_in,brch,next_pc_in) 
  begin
    if (brch=unsigned(next_pc_in) or pipeline_valid_in='0' ) then --give correct one
      correct<='1';
    else
      correct<='0';
    end if;
  end process;


  process(op_code_in,pipeline_valid_in) 
  begin
    if (op_code_in="1100") then --BEQ
      jump_brdcst_valid_out <= '0'; 
    else 
      jump_brdcst_valid_out <= pipeline_valid_in;
    end if;
  end process;

  
  process(self_branch_tag_in,pipeline_valid_in,brch,next_pc_in)
  begin
    if(pipeline_valid_in='1' and self_branch_tag_in="001" and not(brch=unsigned(next_pc_in))) then
      jump_branch_mispredictor<="01";
    elsif (pipeline_valid_in='1' and self_branch_tag_in="010" and not(brch=unsigned(next_pc_in))) then
      jump_branch_mispredictor<="10";
    else
      jump_branch_mispredictor<="00";
    end if;  
  end process;


  jump_brdcst_rename_out <= destn_rename_code_in;
  jump_brdcst_orig_destn_out <= orig_destn_in;
  jump_brdcst_data_out <= std_logic_vector(res);
          
  jump_brdcst_btag_out <= b_tag_in;

  branch_addr<=std_logic_vector(brch);
  data_out<=std_logic_vector(res);

  pipeline_valid_out<=pipeline_valid_in;
  op_code_out<=op_code_in;
  destn_rename_code_out<=destn_rename_code_in;
  b_tag_out<=b_tag_in;
  orig_destn_out<=orig_destn_in;
  curr_pc_out<=curr_pc_in;
  self_branch_tag_out<=self_branch_tag_in;

end architecture struc;