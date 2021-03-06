------------------------------------------------------------------------------------------------
--
-- Copyright (C) 2010-: Madhav P. Desai
-- All Rights Reserved.
--  
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the
-- "Software"), to deal with the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
--  * Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimers.
--  * Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimers in the documentation and/or other materials provided
--    with the distribution.
--  * Neither the names of the AHIR Team, the Indian Institute of
--    Technology Bombay, nor the names of its contributors may be used
--    to endorse or promote products derived from this Software
--    without specific prior written permission.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR
-- ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE SOFTWARE.
------------------------------------------------------------------------------------------------
-- copyright: Madhav Desai
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ahir;
use ahir.BaseComponents.all;

entity QueueWithBypass is
  generic(name : string; queue_depth: integer := 1; data_width: integer := 32);
  port(clk: in std_logic;
       reset: in std_logic;
       data_in: in std_logic_vector(data_width-1 downto 0);
       push_req: in std_logic;
       push_ack: out std_logic;
       data_out: out std_logic_vector(data_width-1 downto 0);
       pop_ack : out std_logic;
       pop_req: in std_logic);
end entity QueueWithBypass;

architecture behave of QueueWithBypass is

	signal number_of_elements_in_queue: integer range 0 to queue_depth + 1;

	signal qpush_req, qpush_ack, qpop_req, qpop_ack: std_logic;
	signal qdata_in, qdata_out: std_logic_vector(data_width-1 downto 0);

	signal qhas_data: Boolean;
	signal bypass_active : Boolean;
begin  -- SimModel

  -- count number of elements in queue.
  process(clk, reset)
  begin
	if(clk'event and clk = '1') then
		if(reset = '1') then
			number_of_elements_in_queue <= 0;
		else
			if((qpop_req = '1') and (qpop_ack = '1')) then
				if(not ((qpush_req = '1') and (qpush_ack = '1'))) then
					number_of_elements_in_queue <= number_of_elements_in_queue - 1;
				end if;
			elsif((qpush_req = '1') and (qpush_ack = '1')) then
				number_of_elements_in_queue <= number_of_elements_in_queue + 1;
			end if;
		end if;
	end if;
  end process;

  qhas_data <= (number_of_elements_in_queue > 0);
 
  qinst: QueueBase 
		generic map (name => name & "-qbase", queue_depth => queue_depth, data_width => data_width)
		port map (clk => clk, reset => reset,
				data_in => qdata_in, push_req => qpush_req, push_ack => qpush_ack,
				data_out => qdata_out, pop_req => qpop_req, pop_ack => qpop_ack);

  -- bypass is active?
  bypass_active <= (not qhas_data) and (pop_req = '1');

  -- push into the queue when queue-has-data = '1' or when the world does not care
  qpush_req <= push_req  when (not bypass_active) else  '0';
  push_ack  <= qpush_ack when (not bypass_active) else pop_req;
  qdata_in  <= data_in;

  -- pop from queue when queue-has-data = '1'.
  data_out <= qdata_out when (not bypass_active) else data_in;
  qpop_req <= pop_req   when (not bypass_active) else '0';
  pop_ack  <= qpop_ack  when (not bypass_active) else push_req;

end behave;
