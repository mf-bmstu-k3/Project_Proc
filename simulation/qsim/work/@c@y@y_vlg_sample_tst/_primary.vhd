library verilog;
use verilog.vl_types.all;
entity CYY_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        q_a             : in     vl_logic_vector(7 downto 0);
        q_b             : in     vl_logic_vector(7 downto 0);
        set             : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end CYY_vlg_sample_tst;
