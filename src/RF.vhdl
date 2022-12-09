library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF is
	port(a1, a2, a3:in std_logic_vector(2 downto 0); 
		clk,we_rf,reset:in std_logic;
		d3: in std_logic_vector(15 downto 0); 
		d1, d2, r0, r1, r2, r3, r4, r5, r6, r7:out std_logic_vector(15 downto 0));
end entity RF;

architecture beh of RF is

	type regfile is array(0 to 7) of std_logic_vector(15 downto 0);

	signal reg_num:regfile:=(others=>(others=>'0'));

begin
	d1 <= reg_num(to_integer(unsigned(a1)));
	d2 <= reg_num(to_integer(unsigned(a2)));
	r0 <= reg_num(0);
	r1 <= reg_num(1);
	r2 <= reg_num(2);
	r3 <= reg_num(3);
	r4 <= reg_num(4);
	r5 <= reg_num(5);
	r6 <= reg_num(6);
	r7 <= reg_num(7);

	reg_write:process(clk,reset)
	begin 
		
		if (reset='1') then
			reg_num(0) <= (others => '0');
			reg_num(1) <= (others => '0');
			reg_num(2) <= (others => '0');
			reg_num(3) <= (others => '0');
			reg_num(4) <= (others => '0');
			reg_num(5) <= (others => '0');
			reg_num(6) <= (others => '0');
			reg_num(7) <= (others => '0');
		
		elsif(clk'event and clk = '1') then
			
			if (we_rf = '1') then
				reg_num(to_integer(unsigned(a3))) <= d3;
			end if;

		end if;

	end process;

end beh;