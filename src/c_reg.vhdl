library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity c_reg is
  port 
  (
	clk : in std_logic;
	reset: in std_logic;
	c_data_in: in std_logic;
	c_valid: in std_logic;
	c_data_out: out std_logic
  );
end entity;

architecture arc of c_reg is
	signal c_data: std_logic;

begin

c_proc : process(clk,c_data_in,c_valid,reset)
begin
	if (clk'event and clk = '1') then
		if (reset = '1') then
			c_data <= '0';
		else
			if (c_valid = '1') then
				c_data <= c_data_in;
			end if;
		end if;
	end if;
end process; 

c_data_out <= c_data;

end architecture ;