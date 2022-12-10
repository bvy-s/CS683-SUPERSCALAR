library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpubench is
end cpubench;

architecture test of cpubench is
  -- constant num_cycles : integer := 50;

  signal clk: std_logic := '1';
  signal reset: std_logic;
  
  component superScaler is 
    port (
        top_clock:in std_logic;
        system_reset:in std_logic;
        c_reg_data_out: out std_logic;
        z_reg_data_out: out std_logic
     );
  end component;

  constant clk_period : time := 1 ns; --1 Ghz

  signal C,Z:std_logic ; -- to monitor values inside gtkwave
begin

  -- start off with a short reset
  reset <= '1', '0' after 1 ns;

  -- create a clock
  process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  cpuinstance: superScaler port map(top_clock=>clk,system_reset=>reset,c_reg_data_out=>C,z_reg_data_out=>Z);

end test;