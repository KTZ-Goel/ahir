library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ahir;
use ahir.Types.all;
use ahir.Subprograms.all;
use ahir.Utilities.all;
use ahir.BaseComponents.all;
use ahir.mem_component_pack.all;

entity StoreReqSharedWithInputBuffers is
    generic
    (
	name : string;
	addr_width: integer;
	data_width : integer;
	time_stamp_width : integer;
      	num_reqs : integer; -- how many requesters?
	tag_length: integer;
	no_arbitration: Boolean := false;
        min_clock_period: Boolean := true;
	input_buffering: IntegerArray
    );
  port (
    -- req/ack follow pulse protocol
    reqL                     : in BooleanArray(num_reqs-1 downto 0);
    ackL                     : out BooleanArray(num_reqs-1 downto 0);
    -- address corresponding to access
    addr                    : in std_logic_vector((addr_width*num_reqs)-1 downto 0);
    data                    : in std_logic_vector((data_width*num_reqs)-1 downto 0);
    -- address to memory
    maddr                   : out std_logic_vector(addr_width-1 downto 0);
    mdata                   : out std_logic_vector(data_width-1 downto 0);
    mtag                    : out std_logic_vector(tag_length+time_stamp_width-1 downto 0);
    mreq                    : out std_logic;
    mack                    : in std_logic;
    -- clock, reset (active high)
    clk, reset              : in std_logic);
end StoreReqSharedWithInputBuffers;

architecture Vanilla of StoreReqSharedWithInputBuffers is

  constant iwidth: integer := addr_width*num_reqs;
  constant owidth: integer := addr_width;

  constant debug_flag : boolean := false;

  -- must register..  ack implies that address has been sampled.
  constant registered_output : boolean := true; 

  type TagWordArray is array (natural range <>) of unsigned(tag_length-1 downto 0);
  signal rx_tag_in: TagWordArray(num_reqs-1 downto 0);

  constant rx_word_length: integer := addr_width + data_width + tag_length + time_stamp_width;
  type RxBufWordArray is array (natural range <>) of std_logic_vector(rx_word_length-1 downto 0);

  signal rx_data_in, rx_data_out : RxBufWordArray(num_reqs-1 downto 0);
  signal kill_sig : std_logic;

  signal imux_data_in_accept,  imux_data_in_valid: std_logic_vector(num_reqs-1 downto 0);
  signal imux_data_in: std_logic_vector((rx_word_length*num_reqs)-1 downto 0);

  signal imux_data_out_accept,  imux_data_out_valid: std_logic;
  signal imux_data_out: std_logic_vector(rx_word_length-1 downto 0);
  
  alias IBUFs: IntegerArray(num_reqs-1 downto 0) is input_buffering;
begin  -- Behave
  assert(tag_length >= Ceil_Log2(num_reqs)) report "insufficient tag width" severity error;
 
  kill_sig <= '0'; -- no killing!

  tagGen: for I in 0 to num_reqs-1 generate
	rx_tag_in(I) <= To_Unsigned(I,tag_length);	
  end generate tagGen;


  TstampGen: if time_stamp_width > 0 generate
	Tsb: block 
		signal time_stamp: std_logic_vector(time_stamp_width-1 downto 0);
	begin
		tsc: CounterBase generic map(data_width => time_stamp_width)
			port map(clk => clk, reset => reset, count_out => time_stamp);

		rxInDataGen: for I in 0 to num_reqs-1 generate
			rx_data_in(I) <= addr(((I+1)*addr_width)-1 downto I*addr_width) &
					 data(((I+1)*data_width)-1 downto I*data_width)  &  std_logic_vector(rx_tag_in(I)) & time_stamp;
		end generate rxInDataGen;
	end block Tsb;
  end generate TstampGen;

  NoTstampGen: if time_stamp_width < 1 generate
	rxInDataGen: for I in 0 to num_reqs-1 generate
		rx_data_in(I) <= addr(((I+1)*addr_width)-1 downto I*addr_width)  &
					 data(((I+1)*data_width)-1 downto I*data_width) & std_logic_vector(rx_tag_in(I));
	end generate rxInDataGen;
  end generate NoTstampGen;

  -- receive buffers.
  RxGen: for I in 0 to num_reqs-1 generate
	rb: ReceiveBuffer generic map(name => name & " RxBuf " & Convert_To_String(I),
					buffer_size => IBUFs(I),
					data_width => rx_word_length,
					kill_counter_range => 655535)
		port map(write_req => reqL(I), 
			 write_ack => ackL(I), 
			 write_data => rx_data_in(I), 
			 read_req => imux_data_in_accept(I), 
			 read_ack => imux_data_in_valid(I), 
                         read_data => rx_data_out(I),
			 kill => kill_sig, 
			 clk => clk, 
			 reset => reset);

  end generate RxGen;

  -- the multiplexor.
  NonTrivTstamp: if time_stamp_width > 0 generate
  	imux: merge_tree
    	   generic map(g_number_of_inputs => num_reqs,
		g_data_width => rx_word_length,
                g_time_stamp_width => time_stamp_width, 
                g_tag_width => tag_length,
		g_mux_degree => 4096, -- some large number.. allow big muxes.
		g_num_stages => 1,    -- with single stage delay 
		g_port_id_width => 0)
           port map(merge_data_in => imux_data_in,
	            merge_req_in  => imux_data_in_valid,
	            merge_ack_out => imux_data_in_accept,
	            merge_data_out => imux_data_out,
                    merge_req_out => imux_data_out_valid,
	            merge_ack_in  => imux_data_out_accept,
      	            clock        => clk,
      	            reset      => reset);
  end generate NonTrivTstamp;

  TrivTstamp: if time_stamp_width < 1 generate
	imux: LevelMux generic map (num_reqs => num_reqs, data_width => rx_word_length, no_arbitration => false)
		port map(write_req => imux_data_in_valid,
			 write_ack => imux_data_in_accept,
			 write_data => imux_data_in,
			 read_req => imux_data_out_accept,
		         read_ack => imux_data_out_valid,
			 read_data => imux_data_out,
			 clk => clk, reset => reset);
  end generate TrivTstamp;


  -- outgoing tag, address, data
  mreq <= imux_data_out_valid;
  imux_data_out_accept <= mack;
  maddr <= imux_data_out(rx_word_length-1 downto (data_width + tag_length + time_stamp_width));
  mdata <= imux_data_out((rx_word_length - addr_width)-1 downto (tag_length + time_stamp_width));
  mtag <= imux_data_out(tag_length+time_stamp_width-1 downto 0);

end Vanilla;
