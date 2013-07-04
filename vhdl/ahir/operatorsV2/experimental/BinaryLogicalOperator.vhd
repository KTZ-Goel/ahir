library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ahir;
use ahir.Types.all;
use ahir.Subprograms.all;
use ahir.OperatorPackage.all;
use ahir.BaseComponents.all;
use ahir.FloatOperatorPackage.all;

--
-- output = input_1 op input_2.
--
-- input_1 uses the higher bits of data_in, and the (1) index of sample-req/ack.
--
entity BinaryLogicalOperator is
  generic
    (
      operator_id         : string;            -- operator id
      input_width         : integer;           -- input width
      output_width        : integer;           -- the width of the output.
      input_1_buffer_depth: integer;           -- buffering at input 1.
      input_2_buffer_depth: integer;           -- buffering at input 2.
      output_buffer_depth : integer;           -- buffering at output.
	-- both should never be constants.
      input_1_is_constant : boolean := false;
      input_2_is_constant : boolean := false
      );
  port (
    -- input operands.
    sample_req : in BooleanArray(1 downto 0);  -- sample reqs, one per input.
    sample_ack : out BooleanArray(1 downto 0); -- sample acks, one per output.
    data_in      : in  std_logic_vector((2*input_width)-1 downto 0);
    -- result.
    update_req : in Boolean;  -- req for output update.
    update_ack : out Boolean; -- ack for output update.
    data_out      : out std_logic_vector(output_width-1 downto 0);
    -- clock, reset.
    clk, reset : in  std_logic);
end BinaryLogicalOperator;


architecture Vanilla of BinaryLogicalOperator is
	signal in_data_1: std_logic_vector(input_width-1 downto 0);
	signal in_data_1_valid, in_data_1_accept, in_data_1_kill: std_logic;

	signal in_data_2: std_logic_vector(input_width-1 downto 0);
	signal in_data_2_valid, in_data_2_accept, in_data_2_kill: std_logic;

	signal out_data: std_logic_vector(output_width-1 downto 0);
	signal out_data_valid, out_data_accept: std_logic;

begin  -- Vanilla

        -- receive buffers.
	i1NoConst: if (not input_1_is_constant) generate
		rx1: ReceiveBuffer generic map(name => name & " receiver-buffer-input-1 ",
						buffer_size => 	input_1_buffer_depth,
						data_width => input_width,
						kill_counter_range => 65535)
			port map(write_req => sample_req(1),
				 write_ack => sample_ack(1),
			         write_data => data_in((2*input_width)-1 downto input_width),
				 read_req => in_data_1_valid,
				 read_ack => in_data_1_accept,
				 read_data => in_data_1,
				 kill => in_data_1_kill,
				 clk => clk, reset => reset);	
        end generate i1NoConst;

	i1Const: if (input_1_is_constant) generate
		in_data_1 <=  data_in((2*input_width)-1 downto input_width);
		in_data_1_valid <= '1';
		in_data_1_kill <= '0';
		sample_ack(1) <= sample_req(1);
        end generate i1Const;

	i2NoConst: if (not input_2_is_constant) generate
		rx2: ReceiveBuffer generic map(name => name & " receiver-buffer-input-2 ",
						buffer_size => 	input_2_buffer_depth,
						data_width => input_width,
						kill_counter_range => 65535)
			port map(write_req => sample_req(0),
				 write_ack => sample_ack(0),
			         write_data => data_in(input_width-1 downto 0),
				 read_req => in_data_2_valid,
				 read_ack => in_data_2_accept,
				 read_data => in_data_2,
				 kill => in_data_2_kill,
				 clk => clk, reset => reset);	
        end generate i22oConst;

	i2Const: if (input_2_is_constant) generate
		in_data_2 <=  data_in(input_width-1 downto 0);
		in_data_2_valid <= '1';
		in_data_2_kill <= '0';
		sample_ack(0) <= sample_req(0);
        end generate i2Const;
        
	-- the operator itself. operator-id can be ApIntAnd, ApIntOr, ApIntXor, ApIntNor, 
        -- ApIntNand, ApIntXnor.
	andGen: if ((operator_id = "ApIntAnd") or (operator_id = "ApIntNand")) generate

		in_data_1_kill <= '1' when ((in_data_1_valid = '0') and (in_data_2_valid = '1') and
						(in_data_2 = (others => '0'))) else '0';
		in_data_1_accept <=  '1' when ((in_data_1_valid = '1') and (out_data_accept = '1'))
					else '0';

		in_data_2_kill <= '1' when ((in_data_2_valid = '0') and (in_data_1_valid = '1') and
						(in_data_1 = (others => '0'))) else '0';
		in_data_2_accept <=  '1' when ((in_data_2_valid = '1') and (out_data_accept = '1'))
					else '0';

		out_data_valid <= (in_data_1_valid or in_data_1_kill) and 
						(in_data_2_valid or in_data_2_kill);

		andCase: if(operator_id = "ApIntAnd") generate
			out_data <= (in_data_1 and in_data_2);
		end generate andCase;

		nandCase: if(operator_id = "ApIntNand") generate
			out_data <= not (in_data_1 and in_data_2);
		end generate nandCase;
        end generate andGen;

	orGen: if ((operator_id = "ApIntOr") or (operator_id = "ApIntNor")) generate
		in_data_1_kill <= '1' when ((in_data_1_valid = '0') and (in_data_2_valid = '1') and
						(in_data_2 = (others => '1'))) else '0';
		in_data_1_accept <=  '1' when ((in_data_1_valid = '1') and (out_data_accept = '1'))
					else '0';

		in_data_2_kill <= '1' when ((in_data_2_valid = '0') and (in_data_1_valid = '1') and
						(in_data_1 = (others => '1'))) else '0';
		in_data_2_accept <=  '1' when ((in_data_2_valid = '1') and (out_data_accept = '1'))
					else '0';

		out_data_valid <= (in_data_1_valid or in_data_1_kill) and 
						(in_data_2_valid or in_data_2_kill);

		orCase: if(operator_id = "ApIntOr") generate
			out_data <= (in_data_1 or in_data_2);
		end generate orCase;

		norCase: if(operator_id = "ApIntNor") generate
			out_data <= not (in_data_1 or in_data_2);
		end generate norCase;

        end generate orGen;

	xorGen: if ((operator_id = "ApIntXor") or (operator_id = "ApIntXnor")) generate
		in_data_1_kill <= '0';
		in_data_1_accept <=  '1' when ((in_data_1_valid = '1') and (out_data_accept = '1'))
					else '0';

		in_data_2_kill <= '0';
		in_data_2_accept <=  '1' when ((in_data_2_valid = '1') and (out_data_accept = '1'))
					else '0';

		out_data_valid <= in_data_1_valid and in_data_2_valid;

		xorCase: if(operator_id = "ApIntXor") generate
			out_data <= (in_data_1 xor in_data_2);
		end generate xorCase;

		xnorCase: if(operator_id = "ApIntXnor") generate
			out_data <= not (in_data_1 xor in_data_2);
		end generate xnorCase;

        end generate xorGen;

       
	
	-- unload buffer on the output side. 
        ub: UnloadBuffer generic map (name => name & " output-buffer ",
					buffer_size => output_buffer_depth,
					data_width => output_width)
		port map(write_req => out_data_valid,
			 write_ack => out_data_accept,
			 write_data => out_data,
			 unload_req => update_req,
			 unload_ack => update_ack,
			 read_data => data_out,
			 clk => clk, reset => reset); 

end Vanilla;
