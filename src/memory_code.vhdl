library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity memory_code is 
  port (clk : in std_logic;
  		reset : in std_logic;  
        we  : in std_logic;   
        a   : in std_logic_vector(15 downto 0);   
        di  : in std_logic_vector(15 downto 0);   
        do  : out std_logic_vector(31 downto 0));   -- 2-way fetch width
end memory_code;

architecture syn of memory_code is   
  type ram_type is array (1023 downto 0) of std_logic_vector (15 downto 0);   

	function load_from(file_name : in string) return ram_type is
		file 	 mif_file : text open read_mode is file_name;
		variable mif_line : line;
		variable temp_bv  : bit_vector(16-1 downto 0);
		variable temp_mem : ram_type;
	begin
		for i in ram_type'range loop
			if not endfile(mif_file) then
				readline(mif_file, mif_line); -- Read into mifline
				read(mif_line, temp_bv); -- Read into a bit vector
				temp_mem(i) := to_stdlogicvector(temp_bv); --convert it std vec and store
			else
			temp_mem(i) := x"0000";
			end if;
			end loop;
		return temp_mem;
	end function;

  signal RAM : ram_type:=load_from("INSTR.txt");	

begin   
  process (clk)   
  begin   
    if (clk'event and clk = '1') then   
	  if reset = '1' then
		RAM <= load_from("INSTR.txt");
      elsif (we = '1') then   
        RAM(to_integer(unsigned(a))) <= di;   
      end if;   
    end if;
  end process;
do <= RAM(to_integer(unsigned(a))) & RAM(to_integer(unsigned(a)+1));   

end syn;
