library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF is
	port(a1, a2, a3:in std_logic_vector(2 downto 0); 
		clk,we_rf,reset:in std_logic;
		d3: in std_logic_vector(15 downto 0); 
		d1, d2:out std_logic_vector(15 downto 0));
end entity RF;

architecture beh of RF is

	type regfile is array(0 to 7) of std_logic_vector(15 downto 0);

	signal reg_num:regfile:=(others=>(others=>'0'));

begin
	d1 <= reg_num(to_integer(unsigned(a1)));
	d2 <= reg_num(to_integer(unsigned(a2)));
	reg_write:process(clk,reset)
	begin 
		if (reset='1') then
			reg_num <= (others=>(others=>'0'));
		elsif(clk'event and clk = '1') then
			if (we_rf = '1') then
				reg_num(to_integer(unsigned(a3))) <= d3;
			end if;
		end if;
	end process;
end beh;