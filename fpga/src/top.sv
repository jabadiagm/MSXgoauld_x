`define ENABLE_SOUND
`define ENABLE_MAPPER
`define ENABLE_SDCARD
`define ENABLE_SCAN_LINES

module top
#(
    parameter SD_SLOT = 3
)(
    input ex_clk_50m,
    input s1,
    input s2,

    input ex_bus_wait_n,
    input ex_bus_int_n,
    input ex_bus_reset_n,
    input ex_bus_clk_3m6,

    inout [7:0] ex_bus_data,
    
    output ex_bus_m1_n,
    output ex_bus_rfsh_n,
    output reg ex_bus_mreq_n,
    output reg ex_bus_iorq_n,
    output reg ex_bus_rd_n,
    output reg ex_bus_wr_n,

    output ex_bus_data_reverse_n,
    output [15:0] ex_bus_addr,
    
    //hdmi out
    output [2:0] data_p,
    output [2:0] data_n,
    output clk_p,
    output clk_n,

    // flash
    output mspi_cs,
    //output mspi_sclk,
    inout mspi_miso,
    inout mspi_mosi,
 
    // MicroSD
    output sd_sclk,
    inout sd_cmd,      // MOSI
    inout  sd_dat0,     // MISO
    output sd_dat1,     // 1
    output sd_dat2,     // 1
    output sd_dat3,     // 1
   
    // SDRAM
    output O_sdram_clk,
    output O_sdram_cke,
    output O_sdram_cs_n,            // chip select
    output O_sdram_cas_n,           // columns address select
    output O_sdram_ras_n,           // row address select
    output O_sdram_wen_n,           // write enable
    inout [15:0] IO_sdram_dq,       // 32 bit bidirectional data bus
    output [12:0] O_sdram_addr,     // 11 bit multiplexed address bus
    output [1:0] O_sdram_ba,        // two banks
    output [1:0] O_sdram_dqm,      // 32/4
    
    output led[1:0]

    //7 segments
//    output display_select,
//    output a,
//    output b,
//    output c,
//    output d,
//    output e,
//    output f,
//    output g    

);

initial begin

end

    //clocks
    wire clk_27m;
    wire clk_81m;
    wire clk_81m_n;
    wire clk_135m;

    clk_wiz_0 pll(
        .clk_out1(clk_27m),        // MHZ main clock
        .clk_out2(clk_81m),     // MHZ phase shifted (90 degrees)
        .clk_out3(clk_81m_n),     // MHZ phase shifted (90 degrees)
        .clk_out4(clk_135m),     // hdmi pixel clock
        .clk_in1(ex_clk_50m)      // 27Mhz system clock
    ); 

    wire clk_enable_27m;
    wire clk_enable_54m;
    reg [1:0] cnt_clk_enable_27m;
    always @ (posedge clk_81m) begin
        cnt_clk_enable_27m <= cnt_clk_enable_27m + 1;
    end
    assign clk_enable_27m = ( cnt_clk_enable_27m == 2'b00 ) ? 1: 0;
    assign clk_enable_54m = ( cnt_clk_enable_27m[0] == 1 ) ? 1: 0;

    //sync input signals
    reg bus_clk_3m6;
    reg bus_wait_n;
    reg bus_int_n;
    reg [7:0] bus_data;

    always @ (posedge clk_81m) begin
        bus_clk_3m6 <= ex_bus_clk_3m6;
        bus_wait_n <= ex_bus_wait_n;
        bus_int_n <= ex_bus_int_n;
        bus_data <= ex_bus_data;
    end

    wire clk_enable_3m6;
    wire clk_falling_3m6;
    reg bus_clk_3m6_prev;
    always @ (posedge clk_81m) begin
        bus_clk_3m6_prev <= bus_clk_3m6;
    end
    assign clk_enable_3m6 = (bus_clk_3m6_prev == 0 && bus_clk_3m6 == 1);
    assign clk_falling_3m6 = (bus_clk_3m6_prev == 1 && bus_clk_3m6 == 0);


    wire bus_reset_n;
    PINFILTER dn3(
        .clk(clk_81m),
        .reset_n(1),
        .din(ex_bus_reset_n),
        .dout(bus_reset_n)
    );


    //startup logic
    reg reset1_n_ff;
    reg reset2_n_ff;
    reg reset3_n_ff;
    wire reset1_n;
    wire reset2_n;
    wire reset3_n;

    reg [15:0] counter_reset = 0;
    reg [1:0] rst_seq;
    reg rst_step;

    always @ (posedge clk_27m or negedge bus_reset_n) begin
        if (bus_reset_n == 0) begin
            rst_step <= 0;
            counter_reset <= 0;
        end
        else begin
            rst_step <= 0;
            if ( counter_reset <= 16'h8000 ) 
                counter_reset <= counter_reset + 1;
            else begin
                rst_step <= 1;
                counter_reset <= 0;
            end
        end
    end

    always @ (posedge clk_27m or negedge bus_reset_n or posedge ram_fail_w) begin
        if (bus_reset_n == 0 || ram_fail_w == 1) begin
            rst_seq <= 2'b00;
            reset1_n_ff <= 0;
            reset2_n_ff <= 0;
            reset3_n_ff <= 0;
        end
        else begin
            case ( rst_seq )
                2'b00: 
                    if (rst_step == 1 ) begin
                        reset1_n_ff <= 1;
                        rst_seq <= 2'b01;
                    end
                2'b01: 
                    if (rst_step == 1) begin
                        reset2_n_ff <= 1;
                        rst_seq <= 2'b10;
                    end
                2'b10:
                    if (rst_step == 1) begin
                        reset3_n_ff <= 1;
                        rst_seq <= 2'b11;
                    end
            endcase
        end
    end
    assign reset1_n = reset1_n_ff;
    assign reset2_n = reset2_n_ff;
    assign reset3_n = reset3_n_ff;


    //bus isolation
    wire bus_data_reverse;
    wire bus_m1_n;
    wire bus_mreq_n;
    wire bus_iorq_n;
    wire bus_rd_n;
    wire bus_wr_n;
    wire bus_rfsh_n;
    reg [7:0] cpu_din;
    wire [7:0] cpu_dout;
    wire bus_mreq_disable;
    wire bus_iorq_disable;
    wire bus_disable;
    assign ex_bus_m1_n = bus_m1_n;
    assign ex_bus_rfsh_n = bus_rfsh_n;
    assign ex_bus_data_reverse_n = ~ bus_data_reverse;
    //assign ex_bus_mreq_n = bus_mreq_n;
    //assign ex_bus_iorq_n = bus_iorq_n;
    //assign ex_bus_rd_n = bus_rd_n;
    //assign ex_bus_wr_n = bus_wr_n;

    assign bus_mreq_disable = ( 
                                exp_slot3_req_r == 1
                        `ifdef ENABLE_SOUND
                                || scc_req == 1 
                                || fmrom_req == 1
                        `endif
                        `ifdef ENABLE_MAPPER
                                || mapper_read == 1 || mapper_write == 1
                        `endif                       
                                || bios_req == 1 || subrom_req == 1 || msx_logo_req == 1
                        `ifdef ENABLE_SDCARD
                                || sram_busreq_w == 1 || sd_busreq_w == 1 || megarom_req == 1
                        `endif
                                ) ? 1 : 0;
    assign bus_iorq_disable = ( vdp_csr_n == 0 || vdp_csw_n == 0 || rtc_req_r == 1 || rtc_req_w == 1 ) ? 1 : 0;
    assign bus_disable = bus_mreq_disable | bus_iorq_disable;
    assign ex_bus_data = ( bus_data_reverse == 1 /* && bus_disable == 0 */ ) ? cpu_dout : 8'hzz;
    assign cpu_din = 
                     ( exp_slot3_req_r == 1) ? ~exp_slot3  :
                `ifdef ENABLE_MAPPER
                    ( mapper_read == 1) ? sdram_dout :
                `endif
                `ifdef ENABLE_SDCARD
                     ( sd_busreq_w == 1) ? sd_cd_w :
                     ( sram_busreq_w == 1) ? sram_cd_w :
                     ( megarom_req == 1) ? sdram_dout :
                 `endif    
                     ( bios_req == 1) ? sdram_dout :
                     ( subrom_req == 1) ? sdram_dout :
                     ( msx_logo_req == 1) ? sdram_dout :
                `ifdef ENABLE_SOUND
                     ( fmrom_req == 1) ? sdram_dout :
                     ( scc_req == 1) ? scc_dout :
                `endif
                     ( vdp_csr_n == 0) ? vdp_dout :
                     ( rtc_req_r == 1 ) ? rtc_dout :
                      bus_data;

    reg ex_bus_rd_n_ff;
    reg ex_bus_wr_n_ff;
    reg ex_bus_iorq_n_ff;
    reg ex_bus_mreq_n_ff;
    localparam IDLE_ISO = 2'd0;
    localparam ACTIVE_ISO = 2'd1;
    localparam WAIT_ISO = 2'd2;
    reg [1:0] state_iso;
    reg [2:0] counter_iso;

    assign ex_bus_rd_n = ( bus_rd_n | ex_bus_rd_n_ff | bus_disable);
    assign ex_bus_wr_n = ( bus_wr_n | ex_bus_wr_n_ff | bus_disable);
    assign ex_bus_iorq_n = ( bus_iorq_n | bus_iorq_disable );
    assign ex_bus_mreq_n = ( bus_mreq_n | bus_mreq_disable );

    always @ ( posedge clk_81m ) begin
        if (~bus_reset_n) begin
            state_iso <= IDLE_ISO;
            ex_bus_rd_n_ff <= 1;
            ex_bus_wr_n_ff <= 1;
        end 
        else begin
            counter_iso = counter_iso + 3'd1;
            casex ({state_iso, counter_iso})
                {IDLE_ISO, 3'bxxx}: begin
                    ex_bus_rd_n_ff <= 1;
                    ex_bus_wr_n_ff <= 1;
                    counter_iso <= 3'd0;
                    if (bus_rd_n == 0 || bus_wr_n == 0 ) begin
                        state_iso <= ACTIVE_ISO;
                    end
                end
                {ACTIVE_ISO, 3'd2} : begin
                    ex_bus_rd_n_ff <= bus_rd_n;
                    ex_bus_wr_n_ff <= bus_wr_n;
                    state_iso <= WAIT_ISO;
                end
                {WAIT_ISO, 3'bxxx} : begin
                    if ( bus_rd_n == 1 && bus_wr_n == 1 ) begin
                        state_iso <= IDLE_ISO;
                    end
                end
            endcase
        end
    end

    wire [15:0] bus_addr;
    assign ex_bus_addr = bus_addr;

    T80a  #(
        .Mode    (0),     // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
        //.T2Write (0),     //0 => WR_n active in T3, /=0 => WR_n active in T2
        .IOWait   (1)      // 0 => Single I/O cycle, 1 => Std I/O cycle
    ) cpu1 (
        .RESET_n   (bus_reset_n & reset3_n & flash_idle_w),
        .CLK_n     (clk_81m),
		.clk_enable (clk_enable_3m6),
		.clk_falling (clk_falling_3m6),
        .WAIT_n    (bus_wait_n),
        .INT_n     (bus_int_n & vdp_int),
        .NMI_n     (1),
        .BUSRQ_n   (1),
        .M1_n      (bus_m1_n),
        .MREQ_n    (bus_mreq_n),
        .IORQ_n    (bus_iorq_n),
        .RD_n      (bus_rd_n),
        .WR_n      (bus_wr_n),
        .RFSH_n    (bus_rfsh_n),
        .HALT_n    ( ),
        .BUSAK_n   ( ),
        .A         ( bus_addr ),
        .DI         (cpu_din),
        .DO         (cpu_dout),
        .Data_Reverse (bus_data_reverse)
    );

    //slots decoding
    reg [7:0] ppi_port_a;
    wire ppi_req;
    wire [1:0] pri_slot;
    wire [3:0] pri_slot_num;
    wire [3:0] page_num;

    //----------------------------------------------------------------
    //-- PPI(8255) / primary-slot
    //----------------------------------------------------------------
    assign ppi_req = (bus_addr[7:0] == 8'ha8 && bus_iorq_n == 0 && bus_m1_n == 1 && bus_wr_n == 0)? 1:0;

    always @ (posedge clk_81m or negedge bus_reset_n) begin
        if ( bus_reset_n == 0)
            ppi_port_a <= 8'h00;
        else begin
            if (ppi_req == 1 && bus_wr_n == 0 && bus_addr[1:0] == 2'b00) begin
                ppi_port_a <= cpu_dout;
            end
        end
    end

    //expanded slot 3
    reg [7:0] exp_slot3;
    wire [1:0] exp_slot3_page;
    wire [3:0] exp_slot3_num;
    wire exp_slot3_req_r;
    wire exp_slot3_req_w;
    wire xffff;

    assign xffff = ( bus_addr == 16'hffff ) ? 1 : 0;
    assign exp_slot3_req_w = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_wr_n == 0 && xffff == 1 && pri_slot_num[SD_SLOT] == 1 ) ? 1: 0;
    assign exp_slot3_req_r = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && xffff == 1 && pri_slot_num[SD_SLOT] == 1 ) ? 1: 0;

    // slot #3
    always @ (posedge clk_81m or negedge bus_reset_n) begin
        if ( bus_reset_n == 0 )
            exp_slot3 <= 8'h00;
        else begin
            if (exp_slot3_req_w == 1 ) begin
                exp_slot3 <= cpu_dout;
            end
        end
    end

    // slots decoding
    assign pri_slot = ( bus_addr[15:14] == 2'b00) ? ppi_port_a[1:0] :
                      ( bus_addr[15:14] == 2'b01) ? ppi_port_a[3:2] :
                      ( bus_addr[15:14] == 2'b10) ? ppi_port_a[5:4] :
                                             ppi_port_a[7:6];

    assign pri_slot_num = ( pri_slot == 2'b00 ) ? 4'b0001 :
                          ( pri_slot == 2'b01 ) ? 4'b0010 :
                          ( pri_slot == 2'b10 ) ? 4'b0100 :
                                                  4'b1000;

    assign page_num = ( bus_addr[15:14] == 2'b00) ? 4'b0001 :
                      ( bus_addr[15:14] == 2'b01) ? 4'b0010 :
                      ( bus_addr[15:14] == 2'b10) ? 4'b0100 :
                                                    4'b1000;

    assign exp_slot3_page = ( bus_addr[15:14] == 2'b00) ? exp_slot3[1:0] :
                            ( bus_addr[15:14] == 2'b01) ? exp_slot3[3:2] :
                            ( bus_addr[15:14] == 2'b10) ? exp_slot3[5:4] :
                                                          exp_slot3[7:6];

    assign exp_slot3_num = ( exp_slot3_page == 2'b00 ) ? 4'b0001 :
                           ( exp_slot3_page == 2'b01 ) ? 4'b0010 :
                           ( exp_slot3_page == 2'b10 ) ? 4'b0100 :
                                                         4'b1000;

    //bios
    wire bios_req;
    wire [24:0] bios_addr;
    //assign bios_req = ( bus_addr[15] == 0 && bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[0] == 1 && exp_slot3_num[0] == 1 ) ? 1 : 0;
    assign bios_req = ( bus_addr[15] == 0 && bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[0] == 1 ) ? 1 : 0;
    assign bios_addr = { 10'b1, bus_addr[14:0] };

    //subrom
    wire subrom_req;
    wire [24:0] subrom_addr;
    assign subrom_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[SD_SLOT] == 1 && page_num[0] == 1 && exp_slot3_num[0] == 1 ) ? 1 : 0;
    //assign subrom_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[2] == 1 && page_num[0] == 1 ) ? 1 : 0;
    assign subrom_addr = { 11'b100, bus_addr[13:0] };

    //msx logo
    wire msx_logo_req;
    wire [24:0] msx_logo_addr;
    assign msx_logo_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[SD_SLOT] == 1 && page_num[1] == 1 && exp_slot3_num[0] == 1 ) ? 1 : 0;
    //assign msx_logo_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[2] == 1 && page_num[1] == 1 ) ? 1 : 0;
    assign msx_logo_addr = { 11'b101, bus_addr[13:0] };
    
    //fmrom
    wire fmrom_req;
    wire [24:0] fmrom_addr;
    assign fmrom_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[SD_SLOT] == 1 && page_num[1] == 1 && exp_slot3_num[2] == 1 ) ? 1 : 0;
    //assign fmrom_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[3] == 1 && page_num[1] == 1 ) ? 1 : 0;
    assign fmrom_addr = { 11'b110, bus_addr[13:0] };

    //megarom
    wire megarom_req;
    wire [24:0] megarom_addr;
    reg [2:0] megarom_page_ff;
    wire megarom_page_req;
    wire [2:0] megarom_page;

    assign megarom_req =     ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[1] == 1 && (page_num[1] == 1 || page_num[2] == 1) ) ? 1 : 0;
    assign megarom_page_req = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_wr_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[1] == 1 && bus_addr == 16'h6000 ) ? 1 : 0;
    assign megarom_page = megarom_page_ff;
    assign megarom_addr = { 8'b00000001, megarom_page, bus_addr[13:0] };

    always @(posedge clk_81m or negedge bus_reset_n) begin
        if (bus_reset_n == 0) begin
           megarom_page_ff <= 3'b0;
        end 
        else begin
            if (bus_clk_3m6 == 1) begin
                if (megarom_page_req == 1) begin
                    megarom_page_ff <= cpu_dout[2:0]; // select page
                end
            end
        end
    end
    
`ifdef ENABLE_MAPPER
    wire mapper_read;
    wire mapper_write;
    wire [24:0] mapper_addr;
    reg [7:0] mapper_reg0;
    reg [7:0] mapper_reg1;
    reg [7:0] mapper_reg2;
    reg [7:0] mapper_reg3;
    wire mapper_reg_write;

    assign mapper_addr = (bus_addr [15:14] == 2'b00 ) ? { 3'b001, mapper_reg0, bus_addr[13:0] } :
                         (bus_addr [15:14] == 2'b01 ) ? { 3'b001, mapper_reg1, bus_addr[13:0] } :
                         (bus_addr [15:14] == 2'b10 ) ? { 3'b001, mapper_reg2, bus_addr[13:0] } :
                                                        { 3'b001, mapper_reg3, bus_addr[13:0] };

    assign mapper_read = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[3] == 1 && xffff == 0 ) ? 1 : 0;
    assign mapper_write = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_wr_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[3] == 1 && xffff == 0 ) ? 1 : 0;
    //assign mapper_read = ( s1 == 1 && bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_rd_n == 0 && pri_slot_num[3] == 1 ) ? 1 : 0;
    //assign mapper_write = ( bus_mreq_n == 0 && bus_rfsh_n == 1 && bus_wr_n == 0 && pri_slot_num[3] == 1 ) ? 1 : 0;
    assign mapper_reg_write = ( (bus_iorq_n == 0 && bus_m1_n == 1 && bus_wr_n == 0) && (bus_addr [7:2] == 6'b111111) )?1:0;

    always @(posedge clk_81m or negedge bus_reset_n) begin
        if (bus_reset_n == 0) begin
            mapper_reg0	<= 8'b00000011;
            mapper_reg1	<= 8'b00000010;
            mapper_reg2	<= 8'b00000001;
            mapper_reg3	<= 8'b00000000;
        end
        else if (mapper_reg_write == 1) begin
            case (bus_addr[1:0])
                2'b00: mapper_reg0 <= cpu_dout;
                2'b01: mapper_reg1 <= cpu_dout;
                2'b10: mapper_reg2 <= cpu_dout;
                2'b11: mapper_reg3 <= cpu_dout;
            endcase
        end
    end

`endif


    //rtc
    wire rtc_req_r;
    wire rtc_req_w;
    wire [7:0] rtc_dout;
    assign rtc_req_w = (bus_addr[7:1] == 7'b1011010 && bus_iorq_n == 0 && bus_m1_n == 1 && bus_wr_n == 0)? 1 : 0; // I/O:B4-B5h   / RTC
    assign rtc_req_r = (bus_addr[7:1] == 7'b1011010 && bus_iorq_n == 0 && bus_m1_n == 1 && bus_rd_n == 0)? 1 : 0; // I/O:B4-B5h   / RTC

    rtc rtc1(
        .clk21m(clk_81m),
        .reset(0),
        .clkena(1),
        .req(rtc_req_w | rtc_req_r),
        .ack(),
        .wrt(rtc_req_w),
        .adr(bus_addr),
        .dbi(rtc_dout),
        .dbo(cpu_dout)
    );

    //vdp
	wire vdp_csw_n; //VDP write request
	wire vdp_csr_n; //VDP read request	
    wire [7:0] vdp_dout;
    wire vdp_int;
    wire WeVdp_n;
    wire [16:0] VdpAdr;
    wire [15:0] VrmDbi;
    wire [7:0] VrmDbo;
    wire VideoDHClk;
    wire VideoDLClk;
    //wire [15:0] audio_sample;
    assign vdp_csw_n = (bus_addr[7:2] == 6'b100110 && bus_iorq_n == 0 && bus_m1_n == 1 && bus_wr_n == 0)? 0:1; // I/O:98-9Bh   / VDP (V9938/V9958)
    assign vdp_csr_n = (bus_addr[7:2] == 6'b100110 && bus_iorq_n == 0 && bus_m1_n == 1 && bus_rd_n == 0)? 0:1; // I/O:98-9Bh   / VDP (V9938/V9958)

    v9958_top vdp4 (
        .clk (clk_27m),
        .s1 (0),
        .clk_50 (0),
        .clk_125 (0),
        .clk_135m(clk_135m),

        .reset_n (bus_reset_n ),
        .mode    (bus_addr[1:0]),
        .csw_n   (vdp_csw_n),
        .csr_n   (vdp_csr_n),

        .int_n   (vdp_int),
        .gromclk (),
        .cpuclk  (),
        .cdi     (vdp_dout),
        .cdo     (cpu_dout),

        .audio_sample   (audio_sample),

        .adc_clk  (),
        .adc_cs   (),
        .adc_mosi (),
        .adc_miso (0),

        .maxspr_n    (1),
    `ifdef ENABLE_SCAN_LINES
        .scanlin_n   (0),
    `else
        .scanlin_n   (1),
    `endif
        .gromclk_ena_n (1),
        .cpuclk_ena_n  (1),

        .WeVdp_n(WeVdp_n),

        .VdpAdr(VdpAdr),
        .VrmDbi(VrmDbi),
        .VrmDbo(VrmDbo),

        .VideoDHClk(VideoDHClk),
        .VideoDLClk(VideoDLClk),

        .tmds_clk_p    (clk_p),
        .tmds_clk_n    (clk_n),
        .tmds_data_p   (data_p),
        .tmds_data_n   (data_n)
        
    );

    wire vramW;
    wire vram1W;
    wire vram2W;
    wire [7:0] vram1DataOut;
    wire [7:0] vram2DataOut;
    assign vramW =  ~WeVdp_n;
    assign vram1W = (VdpAdr[16] == 0) ? vramW : 0;
    assign vram2W = (VdpAdr[16] == 1) ? vramW : 0;
    
    ram64k vram1(
      .clk(clk_27m),
      .we(vram1W & VideoDLClk),
      .re(1'b1), //~ReVdp_n & VideoDLClk),
      .addr(VdpAdr[15:0] ),
      .din(VrmDbo),
      .dout(vram1DataOut)
    );
    ram64k vram2(
      .clk(clk_27m),
      .we(vram2W & VideoDLClk),
      .re(1'b1), //~ReVdp_n & VideoDLClk),
      .addr(VdpAdr[15:0] ),
      .din(VrmDbo),
      .dout(vram2DataOut)
    );    
    assign VrmDbi = { vram2DataOut, vram1DataOut };


`ifdef ENABLE_SOUND

    //YM219 PSG
    wire psgBdir;
    wire psgBc1;
    wire iorq_wr_n;
    wire iorq_rd_n;
    wire [7:0] psg_dout;
    wire [7:0] psgSound1;
    wire [7:0] psgPA;
    //wire [7:0] psgPB;
    reg clk_1m8;
    assign iorq_wr_n = bus_iorq_n | bus_wr_n;
    assign iorq_rd_n = bus_iorq_n | bus_rd_n;
    assign psgBdir = ( bus_addr[7:3]== 5'b10100 && iorq_wr_n == 0 && bus_addr[1]== 0 ) ?  1 : 0; // I/O:A0-A2h / PSG(AY-3-8910) bdir = 1 when writing to &HA0-&Ha1
    assign psgBc1 = ( bus_addr[7:3]== 5'b10100 && ((iorq_rd_n==0 && bus_addr[1]== 1) || (bus_addr[1]==0 && iorq_wr_n==0 && bus_addr[0]==0))) ? 1 : 0; // I/O:A0-A2h / PSG(AY-3-8910) bc1 = 1 when writing A0 or reading A2
    assign psgPA =8'h00;
    //reg [7:0] psgPB = 8'hff;

    wire clk_enable_1m8;
    reg clk_1m8_prev;
    always @ (posedge clk_81m) begin
        if (clk_enable_3m6) begin
            clk_1m8 <= ~clk_1m8;
        end
    end
    assign clk_enable_1m8 = (clk_enable_3m6 == 1 && clk_1m8 == 1);
    //assign audio_sample = { 4'b0000 , psgSound1 , 4'b0000 };

    YM2149 psg1 (
        .I_DA(cpu_dout),
        .O_DA(),
        .O_DA_OE_L(),
        .I_A9_L(0),
        .I_A8(1),
        .I_BDIR(psgBdir),
        .I_BC2(1),
        .I_BC1(psgBc1),
        .I_SEL_L(1),
        .O_AUDIO(psgSound1),
        .I_IOA(psgPA),
        .O_IOA(),
        .O_IOA_OE_L(),
        .I_IOB(8'hff),
        .O_IOB( ),
        .O_IOB_OE_L(),
        
        .ENA(clk_enable_1m8), // clock enable for higher speed operation
        .RESET_L(bus_reset_n),
        .CLK(clk_81m),
        .clkHigh(clk_81m),
        .debug ()
    );

    //opll
    wire opll_req_n; 
    wire [9:0] opll_mo;
    wire [9:0] opll_ro;
    reg [11:0] opll_mix;
    wire [15:0] jt2413_wav;

    assign opll_req_n = ( bus_iorq_n == 1'b0 && bus_addr[7:1] == 7'b0111110  &&  bus_wr_n == 1'b0 )  ? 1'b0 : 1'b1;    // I/O:7C-7Dh   / OPLL (YM2413)
  
    jt2413 opll(
        .rst (~bus_reset_n),        // rst should be at least 6 clk&cen cycles long
        .clk (bus_clk_3m6),        // CPU clock
        .cen (1),        // optional clock enable, it not needed leave as 1'b1
        .din (cpu_dout),
        .addr (bus_addr[0]),
        .cs_n (opll_req_n),
        .wr_n (1'b0),
        // combined output
        .snd (jt2413_wav),
        .sample   ( )
    ); 

    //scc
    wire [14:0] scc_wav;
    wire [7:0] scc_dout;
    wire scc_req;
    wire scc_wrt;

    assign scc_req = ( page_num[2] == 1'b1 && bus_mreq_n == 1'b0 && (bus_wr_n == 1'b0 || bus_rd_n == 1'b0 ) && pri_slot_num[0] == 1'b1 ) ? 1'b1 : 1'b0;
    assign scc_wrt = ( scc_req == 1'b1 && bus_wr_n == 1'b0 ) ? 1'b1 : 1'b0;

    megaram scc1 (
        .clk21m (bus_clk_3m6),
        .reset (~bus_reset_n),
        .clkena (1),
        .req (scc_req),
        .ack (),
        .wrt (scc_wrt),
        .adr (bus_addr),
        .dbi (scc_dout),
        .dbo (cpu_dout),

        .ramreq (),
        .ramwrt (), 
        .ramadr (), 
        .ramdbi (8'h00),
        .ramdbo  (),

        .mapsel (2'b00),        // "0-":SCC+, "10":ASC8K, "11":ASC16K

        .wavl (scc_wav),
        .wavr ()
    );

    wire [14:0] scc2_wav;
    wire scc2_req;
    wire scc2_wrt;

    assign scc2_req = ( page_num[2] == 1'b1 && bus_mreq_n == 1'b0 && (bus_wr_n == 1'b0 || bus_rd_n == 1'b0 ) && pri_slot_num[1] == 1'b1 ) ? 1'b1 : 1'b0;
    assign scc2_wrt = ( scc2_req == 1'b1 && bus_wr_n == 1'b0 ) ? 1'b1 : 1'b0;

    megaram scc2 (
        .clk21m (bus_clk_3m6),
        .reset (~bus_reset_n),
        .clkena (1),
        .req (scc2_req),
        .ack (),
        .wrt (scc2_wrt),
        .adr (bus_addr),
        .dbi (),
        .dbo (cpu_dout),

        .ramreq (),
        .ramwrt (), 
        .ramadr (), 
        .ramdbi (8'h00),
        .ramdbo  (),

        .mapsel (2'b00),        // "0-":SCC+, "10":ASC8K, "11":ASC16K

        .wavl (scc2_wav),
        .wavr ()
    );

    //mixer
	reg [15:0] audio_sample;
	reg [15:0] audio_sample1;
	reg [15:0] audio_sample2;

    always @ (posedge bus_clk_3m6) begin
        audio_sample1 <= { 3'b000 , psgSound1 , 5'b00000 };
        audio_sample2 <= { scc_wav, 1'b0 } + { scc2_wav, 1'b0 } + jt2413_wav;
        audio_sample <= audio_sample1 + audio_sample2;
    end

`endif

    //// SDRAM
    wire ram_re_w;
    wire ram_we_w;
    wire [15:0] ram_dout16_w;
    wire [7:0] sdram_dout;
    wire [24:0] ram_addr_w;
    
    reg ff_mem_ack = 0;
    
    always @(posedge clk_81m) begin
    
        if ( (bios_req == 1 || subrom_req == 1 || msx_logo_req == 1 || megarom_req == 1 || fmrom_req == 1 
                `ifdef ENABLE_MAPPER
                            || mapper_read == 1 || mapper_write == 1
                `endif
                            ) && bus_mreq_n == 0 )  begin
            if ((ram_re_w || ram_we_w) && ~ram_busy_w ) begin
                ff_mem_ack <= 1;
            end
        end else 
            ff_mem_ack <= 0;
    end
    
    assign ram_addr_w = (~flash_idle_w) ? rom_addr_w :
                `ifdef ENABLE_MAPPER
                        (ram_enabled_w && (mapper_read == 1 || mapper_write == 1) ) ? mapper_addr :
                `endif
                        (ram_enabled_w && bios_req == 1 ) ? bios_addr :
                        (ram_enabled_w && subrom_req == 1 ) ? subrom_addr :
                        (ram_enabled_w && msx_logo_req == 1 ) ? msx_logo_addr :
                        (ram_enabled_w && megarom_req == 1 ) ? megarom_addr :
                        (ram_enabled_w && fmrom_req == 1 ) ? fmrom_addr :
                        25'h1ffffff; 
    
    assign ram_re_w = (~flash_idle_w) ? 0 : 
                `ifdef ENABLE_MAPPER
                      (ram_enabled_w && ~ff_mem_ack && mapper_read == 1) ? ~bus_rd_n :
                `endif
                      (ram_enabled_w && ~ff_mem_ack && bios_req == 1) ? ~bus_rd_n :
                      (ram_enabled_w && ~ff_mem_ack && subrom_req == 1) ? ~bus_rd_n :
                      (ram_enabled_w && ~ff_mem_ack && msx_logo_req == 1) ? ~bus_rd_n :
                      (ram_enabled_w && ~ff_mem_ack && megarom_req == 1) ? ~bus_rd_n :
                      (ram_enabled_w && ~ff_mem_ack && fmrom_req == 1) ? ~bus_rd_n :
                      0; 
    
    assign ram_we_w = (~flash_idle_w) ? rom_wr_w : 
                      //(ram_enabled_w && ~ff_mem_ack ) ? ~wr_n_w :
                `ifdef ENABLE_MAPPER
                      (ram_enabled_w && ~ff_mem_ack && mapper_write == 1 ) ? ~bus_wr_n :
                `endif
                      0; 
    
    assign sdram_dout = (ram_addr_w[0] == 1'b0) ? ram_dout16_w[7:0] : ram_dout16_w[15:8];
    
    wire ram_fail_w;
    wire ram_enabled_w;
    wire ram_busy_w;
    //wire [19:0] ram_total_written_w;
    wire [15:0] ram_din_w;
    assign ram_din_w = (~flash_idle_w) ? { rom_dout_w, rom_dout_w }  : { cpu_dout, cpu_dout };
    wire [1:0] ram_wdm_w;
    assign ram_wdm_w = {~ram_addr_w[0], ram_addr_w[0]};
    wire [7:0] debug;
    
    memory_controller #(.FREQ(108_000_000) ) controller
       (.clk(clk_81m), 
        .clk_sdram(clk_81m_n), 
        .resetn(reset_ram_n), // keeps resetting until not fail
        .read(ram_re_w & ~ram_busy_w ),
        .write(ram_we_w & ~ram_busy_w ),
        .refresh(~bus_rfsh_n & ~ram_busy_w),
        .addr( ram_addr_w[22:1] ),
        .din(ram_din_w),
        .wdm( ram_wdm_w ),
        .dout( ram_dout16_w ),
        .busy(ram_busy_w), 
        .enabled(ram_enabled_w),
    
        .fail(ram_fail_w), 
        .total_written( ), //ram_total_written_w),
    
        .SDRAM_DQ(IO_sdram_dq), .SDRAM_A(O_sdram_addr), .SDRAM_BA(O_sdram_ba), .SDRAM_nCS(O_sdram_cs_n),
        .SDRAM_nWE(O_sdram_wen_n), .SDRAM_nRAS(O_sdram_ras_n), .SDRAM_nCAS(O_sdram_cas_n), 
        .SDRAM_CLK(O_sdram_clk), .SDRAM_CKE(O_sdram_cke), .SDRAM_DQM(O_sdram_dqm)
    );
    
    /// FLASH ROM LOADER - BIOS
    localparam FLASH_START_ADDRESS = 24'h400000;
    wire reset_rom_n;
    wire reset_ram_n;
    assign reset_ram_n = reset1_n;
    assign reset_rom_n = reset3_n;
    wire mspi_sclk;
    
    //wire mspi_sclk;
    reg ff_rom_wr = 0;
    reg [7:0] ff_rom_dout;
    reg [24:0] ff_rom_addr;
    
    wire rom_wr_w;
    wire [7:0] rom_dout_w;
    wire [24:0] rom_addr_w;
    assign rom_wr_w = ff_rom_wr;
    assign rom_dout_w = ff_rom_dout;
    assign rom_addr_w = ff_rom_addr;
    
    reg ff_flash_rd = 0;
    reg [23:0] ff_flash_addr = 24'd0;
    reg [31:0] ff_flash_counter;
    
    wire flash_data_ready_w;
    wire flash_busy_w;
    
    wire[7:0] flash_dout_w;
    reg ff_flash_terminate = 0;
    
    
    flash # (
        .STARTUP_WAIT(10)
    )
    flash1
    (
        .clk(clk_27m),
        .reset_n(reset_rom_n),
        .SCLK(mspi_sclk),
        .CS(mspi_cs),
        .MISO(mspi_miso),
        .MOSI(mspi_mosi),
        .addr(ff_flash_addr),
        .rd(ff_flash_rd),
        .dout(flash_dout_w),
        .data_ready(flash_data_ready_w),
        .busy(flash_busy_w),
        .terminate(ff_flash_terminate)
    );
    
    reg [7:0] ff_flash_state = 8'd0;
    
    localparam STATE_RESET          = 8'd0;
    localparam STATE_READ_START     = 8'd1;
    localparam STATE_READ_LOOP      = 8'd2;
    localparam STATE_IDLE           = 8'd3;
    localparam STATE_INIT1          = 8'd4;
    localparam STATE_INIT2          = 8'd5;
    localparam STATE_INIT3          = 8'd6;
    localparam STATE_INIT4          = 8'd7;
    reg [31:0] nose = 0;
    wire flash_idle_w;
    assign flash_idle_w = (ff_flash_state == STATE_IDLE ) ? 1'b1 : 1'b0;
    
    always @(posedge clk_27m, negedge reset_rom_n) begin
    if (reset_rom_n == 0) begin
        ff_flash_state = STATE_RESET;
        ff_flash_rd <= 0;
        ff_rom_wr <= 0;
        nose <= 0;
    end else
        case (ff_flash_state)
    
            STATE_RESET: begin   // reset
                ff_flash_state <= STATE_INIT1;
                ff_flash_rd <= 0;
                ff_rom_wr <= 0;
                ff_flash_terminate <= 0;
            end
    
            STATE_INIT1: begin  // start read
                if (flash_busy_w == 0) begin
                    ff_flash_addr <= 24'h000000;
                    ff_flash_rd <= 1;
                    ff_flash_state = STATE_INIT2;
                end
            end
    
            STATE_INIT2: begin  // start read
                if (flash_busy_w == 1) begin
                    ff_flash_rd <= 0;
                    ff_flash_state = STATE_INIT3;
                end
            end
            
            STATE_INIT3: begin  // start read
                if (flash_busy_w == 0) begin
                    nose <= 0;
                    ff_flash_terminate <= 1;
                    ff_flash_state = STATE_INIT4;
                end
            end
    
            STATE_INIT4: begin  // start read
                nose <= nose + 1;
                if (nose > 10) begin
                    ff_flash_terminate <= 0;
                    ff_flash_state = STATE_READ_START;
                end
            end
    
            STATE_READ_START: begin  // start read
                if (flash_busy_w == 0) begin
                    ff_flash_addr <= FLASH_START_ADDRESS;
                    ff_rom_addr <= 25'h1ffffff;
                    ff_flash_rd <= 1;
                    ff_flash_state = STATE_READ_LOOP;
                    ff_flash_counter <= 256*1024;
                end
            end
    
            STATE_READ_LOOP: begin  // loop read
                if (flash_busy_w == 0) begin
    
                    if (ff_flash_counter > 0) begin
                        
                        if (~ff_flash_rd) begin
    
                            ff_flash_addr <= ff_flash_addr + 1;
                            ff_flash_counter <= ff_flash_counter - 1;
                            ff_flash_rd <= 1;
    
                            ff_rom_wr <= 1;
                            ff_rom_addr <= ff_rom_addr + 1;
                            ff_rom_dout <= flash_dout_w; 
    
                        end
                    end else begin    
                        ff_rom_wr <= 0;
                        ff_flash_rd <= 0;
                        ff_flash_state <= STATE_IDLE;
                    end
                end else begin
                    ff_rom_wr <= 0;
                    ff_flash_rd <= 0;
                end
            end
    
            STATE_IDLE: begin  // idle
                ff_flash_terminate <= 1;
            end
    
        endcase
    end


   //access to flash clock
   STARTUPE2 STARTUPE2
     (.CLK(1'b0),
      .GSR(1'b0),
      .GTS(1'b0),
      .KEYCLEARB(1'b1),
      .PACK(1'b0),
      .PREQ(),

      // Drive clock.
      .USRCCLKO(mspi_sclk),
      .USRCCLKTS(1'b0),

      // These control the DONE pin.  UG470 says USRDONETS should
      // usually be low to enable DONE output.  But by default
      // (i.e. when the STARTUPE2 is not instaintiated), the DONE pin
      // goes to hi-z after initialization.  This is how to do that.
      .USRDONEO(1'b0),
      .USRDONETS(1'b1),

      .CFGCLK(),
      .CFGMCLK(),
      .EOS());


`ifdef ENABLE_SDCARD
    //sd card
    localparam int SDC_SDATA		=  16'h7C00;		 	// rw: 7C00h-7Dff - sector transfer area
    localparam int SDC_ENABLE  	    =  16'h7E00;		    // wo: 1: enable SDC register, 0: disable
    localparam int SDC_CMD			=  SDC_ENABLE+1; 		// wo: cmd to SDC fpga: 1=sd read, 2=sd write
    localparam int SDC_STATUS		=  SDC_CMD+1;	 		// ro: SDC status bits
    localparam int SDC_SADDR		=  SDC_STATUS+1;	 	// wo: 4 bytes: sector addr for read/write
    localparam int SDC_C_SIZE  	    =  SDC_SADDR+4;			// ro: 3 bytes: device size blocks
    localparam int SDC_C_SIZE_MULT	=  SDC_C_SIZE+3;		// ro: 3 bits size multiplier
    localparam int SDC_RD_BL_LEN	=  SDC_C_SIZE_MULT+1;	// ro: 4 bits block length
    localparam int SDC_CTYPE		=  SDC_RD_BL_LEN+1;		// ro: SDC Card type: 0=unknown, 1=SDv1, 2=SDv2, 3=SDHCv2 
    localparam int SDC_MID		    =  SDC_CTYPE+1;		    // ro: manufacture ID: 8 bits unsigned
    localparam int SDC_OID		    =  SDC_MID+1;		    // ro: oem id: 2 character
    localparam int SDC_PNM		    =  SDC_OID+2;		    // ro: product name: 5 character
    localparam int SDC_PSN		    =  SDC_PNM+5;		    // ro: serial number: 32 bits unsigned
    localparam int SCC_ENABLE       =  16'h7E80;            // wo: enable disable SCC+
    localparam int SDC_END          =  16'h7EFF; 
    
    wire [8:0] sram_addr_w;
    reg ff_sram_we = 0;
    reg [7:0] ff_sram_cdin;
    reg [7:0] ff_sram_cdout;
    //
    reg ff_sd_en = 0;
    wire sram_cs_w;
    wire sram_busreq_w;
    wire [7:0] sram_cd_w;
    
    wire [3:0] sd_card_stat_w;
    wire [1:0] sd_card_type_w;
    reg ff_sd_rstart;
    reg ff_sd_init;
    reg [31:0] ff_sd_sector;
    wire sd_busy_w;
    wire sd_done_w;
    wire sd_outen_w;
    wire [8:0] sd_outaddr_w;
    wire [7:0] sd_outbyte_w;
    reg ff_sd_wstart;
    wire [7:0] sd_inbyte_w;
    
    wire [21:0] sd_c_size_w;
    wire [2:0] sd_c_size_mult_w;
    wire [3:0] sd_read_bl_len_w;
    
    wire [7:0] sd_mid_w;
    wire [15:0] sd_oid_w;
    wire [39:0] sd_pnm_w;
    wire [31:0] sd_psn_w;
    wire sd_crc_error_w;
    wire sd_timeout_error_w;
    //reg ff_scc_enable;
    //wire scc_enable_w;
    //assign scc_enable_w = ff_scc_enable;
    assign led[0] = ~sd_busy_w;
    assign led[1] = ~flash_idle_w;
    assign sram_cs_w = ram_enabled_w && ff_sd_en && bus_iorq_n == 1 && bus_m1_n == 1 && bus_mreq_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[1] == 1 && ( bus_addr >= SDC_SDATA && bus_addr < SDC_ENABLE) ? 1 : 0;
    assign sram_busreq_w = sram_cs_w && ~bus_rd_n;
    
    dpram#(
        .widthad_a(9),
        .width_a(8)
    )(
        .clock_a(clk_81m),
        .wren_a(bus_clk_3m6 && sram_cs_w && ~bus_wr_n),
        .rden_a(bus_clk_3m6 && sram_cs_w && ~bus_rd_n),
        .address_a(bus_addr[8:0]),
        .data_a(cpu_dout),
        .q_a(sram_cd_w),
    
        .clock_b(clk_81m),
        .wren_b(ff_sd_rstart && sd_outen_w),
        .rden_b(ff_sd_wstart && sd_outen_w),
        .address_b(sd_outaddr_w),
        .data_b(sd_outbyte_w),
        .q_b(sd_inbyte_w)
    );
    
    sd_reader #(
        .CLK_DIV(3'd3),
        .SIMULATE(0)
    ) (
        .rstn(ram_enabled_w),
        .clk(clk_81m),
        .sdclk(sd_sclk),
        .sdcmd(sd_cmd),
        .sddat0(sd_dat0),                  
        .card_stat(sd_card_stat_w),        // show the sdcard initialize status
        .card_type(sd_card_type_w),        // 0=UNKNOWN    , 1=SDv1    , 2=SDv2  , 3=SDHCv2
        .rstart(ff_sd_rstart), 
        .rsector(ff_sd_sector),
        .rbusy(sd_busy_w),
        .rdone(sd_done_w),
        .outen(sd_outen_w),                // when outen=1, a byte of sector content is read out from outbyte
        .outaddr(sd_outaddr_w),            // outaddr from 0 to 511, because the sector size is 512
        .outbyte(sd_outbyte_w),            // a byte of sector content
        .wstart(ff_sd_wstart), 
        .inbyte(sd_inbyte_w),
        .c_size(sd_c_size_w),
        .c_size_mult(sd_c_size_mult_w),
        .read_bl_len(sd_read_bl_len_w),
        .mid(sd_mid_w),
        .oid(sd_oid_w),
        .pnm(sd_pnm_w),
        .psn(sd_psn_w),
        .crc_error(sd_crc_error_w),
        .timeout_error(sd_timeout_error_w),
        .init(ff_sd_init)
    );
    
    assign sd_dat1 = 1;
    assign sd_dat2 = 1;
    assign sd_dat3 = 1; // Must set sddat1~3 to 1 to avoid SD card from entering SPI mode
    
    
    always @(posedge clk_81m or negedge ram_enabled_w) begin
        if (~ram_enabled_w) begin
            ff_sd_en <= 0;
        end else begin
            if (pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[1] == 1 && bus_addr == SDC_ENABLE && ~bus_wr_n && bus_iorq_n && bus_m1_n) 
                ff_sd_en <= cpu_dout[0];
        end
    end
    
    wire sd_cs_w;
    assign sd_cs_w = ram_enabled_w && ff_sd_en && bus_iorq_n && bus_m1_n && bus_mreq_n == 0 && pri_slot_num[SD_SLOT] == 1 && exp_slot3_num[1] == 1 && (bus_addr >= SDC_ENABLE && bus_addr <= SDC_END) ? 1 : 0;
    wire sd_busreq_w;
    assign sd_busreq_w = sd_cs_w && ~bus_rd_n;
    reg [7:0] ff_sd_cd;
    wire [7:0] sd_cd_w;
    assign sd_cd_w = ff_sd_cd;
    
    always @(posedge clk_81m or negedge ram_enabled_w) begin
        if (~ram_enabled_w) begin
            ff_sd_rstart <= '0;
            ff_sd_wstart <= '0;
            ff_sd_init <= '0;
        end else begin
            if (sd_done_w) begin
                ff_sd_rstart <= '0;
                ff_sd_wstart <= '0;
            end
    
            if (sd_cs_w) begin
                if (~bus_wr_n) begin
                    case(bus_addr) 
                        SDC_CMD: begin
                            ff_sd_rstart <= ff_sd_rstart | cpu_dout[0];
                            ff_sd_wstart <= ff_sd_wstart | cpu_dout[1];
                            ff_sd_init   <= ff_sd_init   | cpu_dout[7];
                            //ff_sms_init  <= ff_sms_init  | cdin_w[7];
                        end
                        SDC_SADDR+0:    ff_sd_sector[ 7: 0] <= cpu_dout;
                        SDC_SADDR+1:    ff_sd_sector[15: 8] <= cpu_dout;
                        SDC_SADDR+2:    ff_sd_sector[23:16] <= cpu_dout;
                        SDC_SADDR+3:    ff_sd_sector[31:24] <= cpu_dout;
                    endcase
                end else
                if (~bus_rd_n) begin
                    case(bus_addr) 
                        SDC_ENABLE:     ff_sd_cd <= { 7'b0, ff_sd_en };
                        SDC_STATUS:     ff_sd_cd <= { sd_busy_w, 5'b0, sd_timeout_error_w, sd_crc_error_w };
                        SDC_C_SIZE+0:   ff_sd_cd <= sd_c_size_w[7:0];
                        SDC_C_SIZE+1:   ff_sd_cd <= sd_c_size_w[15:8];
                        SDC_C_SIZE+2:   ff_sd_cd <= { 2'b0, sd_c_size_w[21:16] };
                        SDC_C_SIZE_MULT:ff_sd_cd <= { 5'b0, sd_c_size_mult_w };
                        SDC_RD_BL_LEN:  ff_sd_cd <= { 4'b0, sd_read_bl_len_w };
                        SDC_CTYPE:      ff_sd_cd <= { 6'b0, sd_card_type_w };
                        SDC_MID:        ff_sd_cd <= sd_mid_w;
                        SDC_OID+0:      ff_sd_cd <= sd_oid_w[7:0];
                        SDC_OID+1:      ff_sd_cd <= sd_oid_w[15:8];
                        SDC_PNM+0:      ff_sd_cd <= sd_pnm_w[7:0];
                        SDC_PNM+1:      ff_sd_cd <= sd_pnm_w[15:8];
                        SDC_PNM+2:      ff_sd_cd <= sd_pnm_w[23:16];
                        SDC_PNM+3:      ff_sd_cd <= sd_pnm_w[31:24];
                        SDC_PNM+4:      ff_sd_cd <= sd_pnm_w[39:32];
                        SDC_PSN+0:      ff_sd_cd <= sd_psn_w[7:0];
                        SDC_PSN+1:      ff_sd_cd <= sd_psn_w[15:8];
                        SDC_PSN+2:      ff_sd_cd <= sd_psn_w[23:16];
                        SDC_PSN+3:      ff_sd_cd <= sd_psn_w[31:24];
                        default:        ff_sd_cd <= '1;
                    endcase
                end
            end
        end
    end

`endif

//ila_0 ila_0_inst(
//    .clk(clk_81m),
//    .probe0(fm_wav_filter),
//    .probe1(ram_addr_w[22:1]), //ff_flash_addr),
//    .probe2(flash_dout_w),
//    .probe3(flash_busy_w),
//    .probe4(ff_flash_rd),
//    .probe5(ff_flash_state[3:0]),
//    .probe6(ram_addr_w),
//    .probe7(ram_re_w),
//    .probe8(ram_we_w),
//    .probe9(sdram_dout),
//    .probe10(ram_dout16_w),
//    .probe11(ff_mem_ack),
//    .probe12(ram_busy_w),
//    .probe13(bios_state[3:0]),
//    .probe14(debug),
//    .probe15(fmrom_req),
//    .probe16(ff_flash_terminate),
//    .probe17(bus_reset_n),
//    .probe18(bus_m1_n),
//    .probe19(bus_rfsh_n),
//    .probe20(bus_mreq_n),
//    .probe21(bus_iorq_n),
//    .probe22(bus_rd_n),
//    .probe23(bus_wr_n),
//    .probe24(bus_addr),
//    .probe25(cpu_dout),
//    .probe26(mapper_read),
//    .probe27(mapper_write)
//);


endmodule