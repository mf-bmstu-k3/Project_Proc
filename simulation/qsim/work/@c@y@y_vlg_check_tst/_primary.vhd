library verilog;
use verilog.vl_types.all;
entity CYY_vlg_check_tst is
    port(
        a               : in     vl_logic_vector(7 downto 0);
        address_OP      : in     vl_logic_vector(7 downto 0);
        b               : in     vl_logic_vector(7 downto 0);
        CK              : in     vl_logic_vector(7 downto 0);
        cop             : in     vl_logic;
        data_in_OP      : in     vl_logic_vector(7 downto 0);
        data_out_OP     : in     vl_logic_vector(7 downto 0);
        priznak         : in     vl_logic_vector(1 downto 0);
        RA              : in     vl_logic_vector(7 downto 0);
        RK              : in     vl_logic_vector(7 downto 0);
        rr              : in     vl_logic_vector(15 downto 0);
        s_out           : in     vl_logic_vector(2 downto 0);
        sko             : in     vl_logic;
        sno             : in     vl_logic;
        wr_en_OP        : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end CYY_vlg_check_tst;
