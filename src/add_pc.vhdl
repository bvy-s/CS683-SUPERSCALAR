library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_pc is
  port (
	PC_in: in std_logic_vector(15 downto 0);
	PC_out: out std_logic_vector(15 downto 0)
  );
end entity; 

architecture arc of add_pc is

begin

	adding : process(PC_in)
		variable addend: unsigned(15 downto 0) := "0000000000000010";
		variable sum:unsigned(15 downto 0) := "0000000000000000";
	begin
		sum := unsigned(PC_in) +  addend;
		PC_out <= std_logic_vector(sum);
	end process; 

end architecture; 