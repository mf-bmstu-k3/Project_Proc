library verilog;
use verilog.vl_types.all;
entity CYY_final_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        set             : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end CYY_final_vlg_sample_tst;
