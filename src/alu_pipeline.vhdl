library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_pipeline is
  port(
      pipeline_valid_in: in std_logic;
  		op_code_in: in std_logic_vector(3 downto 0);
  		destn_rename_code_in: in std_logic_vector(5 downto 0);
  		operand1: in std_logic_vector(15 downto 0);
  		operand2: in std_logic_vector(15 downto 0);
		  operand3: in std_logic_vector(15 downto 0);
  		c_flag_in: in std_logic;
  		z_flag_in: in std_logic;
  		c_rename_in: in std_logic_vector(2 downto 0);
  		z_rename_in: in std_logic_vector(2 downto 0);
  		b_tag_in: in std_logic_vector(2 downto 0);
  		orig_destn_in: in std_logic_vector(2 downto 0);
  		op_code_cz: in std_logic_vector(1 downto 0);
      curr_pc_in: in std_logic_vector(15 downto 0);
  		
      data_out: out std_logic_vector(15 downto 0);
      pipeline_valid_out: out std_logic;
      op_code_out: out std_logic_vector(3 downto 0);
  		destn_rename_code_out: out std_logic_vector(5 downto 0);
   		c_flag_out: out std_logic;
  		z_flag_out: out std_logic;
  		c_rename_out: out std_logic_vector(2 downto 0);
  		z_rename_out: out std_logic_vector(2 downto 0);
  		b_tag_out: out std_logic_vector(2 downto 0);
  		orig_destn_out: out std_logic_vector(2 downto 0);
      curr_pc_out: out std_logic_vector(15 downto 0);

      alu_brdcst_rename_out: out std_logic_vector(5 downto 0);
      alu_brdcst_orig_destn_out: out std_logic_vector(2 downto 0);
      alu_brdcst_data_out: out std_logic_vector(15 downto 0);
      alu_brdcst_valid_out: out std_logic;

      alu_brdcst_c_flag_out: out std_logic;
      alu_brdcst_c_flag_rename_out: out std_logic_vector(2 downto 0);
      alu_brdcst_c_flag_valid_out: out std_logic;

      alu_brdcst_z_flag_out: out std_logic;
      alu_brdcst_z_flag_rename_out: out std_logic_vector(2 downto 0);
      alu_brdcst_z_flag_valid_out: out std_logic;

      alu_brdcst_btag_out: out std_logic_vector(2 downto 0)
    );
end entity;


architecture alu of ALU_pipeline is

  signal res, in_a: unsigned(16 downto 0):= (others => '0');
  signal in_b, in_c:unsigned (16 downto 0):=(others=>'0');
  signal c_res_out:std_logic;
  signal z_res_out:std_logic;

begin

	in_b(15 downto 0) <= unsigned (operand1);
	in_a(15 downto 0) <= unsigned (operand2);
	in_c(15 downto 0) <= unsigned (operand3);


	process(op_code_in,op_code_cz,in_a,in_b,in_c,c_flag_in,z_flag_in,res)
	begin

	  if(op_code_in = "0000" ) then

      if (op_code_cz = "00" ) then --add
        res<=in_a+in_b;
        c_flag_out<=std_logic(res(16));
        z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                              or res(11)or res(10)or res(9)or res(8)
	                            or res(7)or res(6)or res(5)or res(4)
	                            or res(3)or res(2)or res(1)or res(0)));
        c_res_out<=std_logic(res(16));
        z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
                                or res(7)or res(6)or res(5)or res(4)
                                or res(3)or res(2)or res(1)or res(0)));

      elsif (op_code_cz="10") then --c flag
        if (c_flag_in = '0') then
          res<=in_c;
          c_flag_out<=c_flag_in;
          z_flag_out<=z_flag_in;
          c_res_out<=c_flag_in;
          z_res_out<=z_flag_in;
        else
          res<=in_a+in_b;
          c_flag_out<=std_logic(res(16));
          z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
	                              or res(7)or res(6)or res(5)or res(4)
	                              or res(3)or res(2)or res(1)or res(0)));   
          c_res_out<=std_logic(res(16));
          z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                  or res(11)or res(10)or res(9)or res(8)
                                  or res(7)or res(6)or res(5)or res(4)
                                  or res(3)or res(2)or res(1)or res(0)));    
        end if;

      else   --z flag 
        if (z_flag_in = '0') then
          res<=in_c;
          c_flag_out<=c_flag_in;
          z_flag_out<=z_flag_in;
          c_res_out<=c_flag_in;
          z_res_out<=z_flag_in;
        else
          res<=in_a+in_b;
          c_flag_out<=std_logic(res(16));
          z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
	                              or res(7)or res(6)or res(5)or res(4)
	                              or res(3)or res(2)or res(1)or res(0)));
           c_res_out<=std_logic(res(16));
           z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                    or res(11)or res(10)or res(9)or res(8)
                                    or res(7)or res(6)or res(5)or res(4)
                                    or res(3)or res(2)or res(1)or res(0)));               
        end if;  

      end if;

    elsif (op_code_in = "0001") then --adi
      res<=in_a+in_b;
      c_flag_out<=std_logic(res(16));
      z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                            or res(11)or res(10)or res(9)or res(8)
	                          or res(7)or res(6)or res(5)or res(4)
	                          or res(3)or res(2)or res(1)or res(0)));
      c_res_out<=std_logic(res(16));
      z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                              or res(11)or res(10)or res(9)or res(8)
                              or res(7)or res(6)or res(5)or res(4)
                              or res(3)or res(2)or res(1)or res(0)));

    else
      if (op_code_cz="00") then --uncondition
        res<=(in_a) nand (in_b);
        c_flag_out<=c_flag_in;
        z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                             or res(11)or res(10)or res(9)or res(8)
	                           or res(7)or res(6)or res(5)or res(4)
	                           or res(3)or res(2)or res(1)or res(0)));
        c_res_out<=c_flag_in;
        z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
                                or res(7)or res(6)or res(5)or res(4)
                                or res(3)or res(2)or res(1)or res(0)));
      elsif (op_code_cz="10") then --if carry
        if (c_flag_in = '0') then
          res<=in_c;
          c_flag_out<=c_flag_in;
          z_flag_out<=z_flag_in;
          c_res_out<=c_flag_in;
          z_res_out<=z_flag_in;
        else
          res<=(in_a) nand (in_b);
          c_flag_out<=c_flag_in;
          z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
	                              or res(7)or res(6)or res(5)or res(4)
	                              or res(3)or res(2)or res(1)or res(0)));   
          c_res_out<=c_flag_in;
          z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                  or res(11)or res(10)or res(9)or res(8)
                                  or res(7)or res(6)or res(5)or res(4)
                                  or res(3)or res(2)or res(1)or res(0)));   
        end if;

      else  --if zero
        if (z_flag_in = '0') then 
          res<=in_c;
          c_flag_out<=c_flag_in;
          z_flag_out<=z_flag_in;
          c_res_out<=c_flag_in;
          z_res_out<=z_flag_in;
        else
          res<=(in_a) nand (in_b);
          c_flag_out<=c_flag_in;
          z_flag_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                or res(11)or res(10)or res(9)or res(8)
                                or res(7)or res(6)or res(5)or res(4)
                                or res(3)or res(2)or res(1)or res(0)));
          c_res_out<=c_flag_in;
          z_res_out<=std_logic(not(res(15)or res(14)or res(13)or res(12) 
                                  or res(11)or res(10)or res(9)or res(8)
                                  or res(7)or res(6)or res(5)or res(4)
                                  or res(3)or res(2)or res(1)or res(0)));    
        end if; 

      end if; 
      
    end if;
  end process;


  process(op_code_in,pipeline_valid_in)
  begin
    if(op_code_in = "0000" ) then  --add
      alu_brdcst_c_flag_valid_out <= pipeline_valid_in;
      alu_brdcst_z_flag_valid_out <= pipeline_valid_in;
    elsif (op_code_in = "0001") then  --adi
      alu_brdcst_c_flag_valid_out <= pipeline_valid_in;
      alu_brdcst_z_flag_valid_out <= pipeline_valid_in;
    else   --nand
      alu_brdcst_c_flag_valid_out <= '0';
      alu_brdcst_z_flag_valid_out <= pipeline_valid_in;
    end if;
  end process;


  alu_brdcst_valid_out <= pipeline_valid_in;
  alu_brdcst_rename_out <= destn_rename_code_in;
  alu_brdcst_orig_destn_out <= orig_destn_in;
  alu_brdcst_data_out <= std_logic_vector(res(15 downto 0));
  
  alu_brdcst_c_flag_out <= std_logic(c_res_out);
  alu_brdcst_c_flag_rename_out <= c_rename_in;
  
  alu_brdcst_z_flag_out <= std_logic(z_res_out);
  alu_brdcst_z_flag_rename_out <= z_rename_in;
  
  alu_brdcst_btag_out <= b_tag_in;  

  pipeline_valid_out<=pipeline_valid_in;
  op_code_out<=op_code_in;
  destn_rename_code_out<=destn_rename_code_in;
  c_rename_out<=c_rename_in;
  z_rename_out<=z_rename_in;
  b_tag_out<=b_tag_in;
  orig_destn_out<=orig_destn_in;
  curr_pc_out<=curr_pc_in;

  data_out <= std_logic_vector(res(15 downto 0));

end architecture alu;