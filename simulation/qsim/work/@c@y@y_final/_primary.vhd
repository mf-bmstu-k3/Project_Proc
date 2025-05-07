library verilog;
use verilog.vl_types.all;
entity CYY_final is
    port(
        altera_reserved_tms: in     vl_logic;
        altera_reserved_tck: in     vl_logic;
        altera_reserved_tdi: in     vl_logic;
        altera_reserved_tdo: out    vl_logic;
        clk             : in     vl_logic;
        set             : in     vl_logic;
        f_com           : out    vl_logic_vector(1 downto 0);
        a               : out    vl_logic_vector(7 downto 0);
        b               : out    vl_logic_vector(7 downto 0);
        cop             : out    vl_logic;
        sno             : out    vl_logic;
        rr              : out    vl_logic_vector(15 downto 0);
        priznak         : out    vl_logic_vector(1 downto 0);
        sko             : out    vl_logic;
        RA              : out    vl_logic_vector(7 downto 0);
        CK              : out    vl_logic_vector(7 downto 0);
        RK              : out    vl_logic_vector(7 downto 0);
        s_out           : out    vl_logic_vector(2 downto 0);
        data_in_OP      : out    vl_logic_vector(7 downto 0);
        address_OP      : out    vl_logic_vector(7 downto 0);
        wr_en_OP        : out    vl_logic;
        data_out_OP     : out    vl_logic_vector(7 downto 0);
        address_a_RP    : out    vl_logic_vector(2 downto 0);
        wr_en_a_RP      : out    vl_logic;
        address_b_RP    : out    vl_logic_vector(2 downto 0);
        q_a             : out    vl_logic_vector(7 downto 0);
        q_b             : out    vl_logic_vector(7 downto 0)
    );
end CYY_final;
