-------------------------------------------------------------------------------
--
-- (c) Copyright 2008, 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Spartan-6 Integrated Block for PCI Express
-- File       : s6_pcie_v2_4.vhd
-- Description: Spartan-6 solution wrapper : Endpoint for PCI Express
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
library unisim;
use unisim.vcomponents.all;
--synthesis translate_off
use unisim.vpkg.all;
library secureip;
use secureip.all;
--synthesis translate_on

entity s6_pcie_v2_4 is
  generic (
    TL_TX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_TX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_RX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_WRITE_LATENCY           : integer    := 0;
    VC0_TX_LASTPACKET                 : integer    := 14;
    VC0_RX_RAM_LIMIT                  : bit_vector := x"7FF";
    VC0_TOTAL_CREDITS_PH              : integer    := 32;
    VC0_TOTAL_CREDITS_PD              : integer    := 211;
    VC0_TOTAL_CREDITS_NPH             : integer    := 8;
    VC0_TOTAL_CREDITS_CH              : integer    := 40;
    VC0_TOTAL_CREDITS_CD              : integer    := 211;
    VC0_CPL_INFINITE                  : boolean    := TRUE;
    BAR0                              : bit_vector := x"FFF00000";
    BAR1                              : bit_vector := x"00000000";
    BAR2                              : bit_vector := x"00000000";
    BAR3                              : bit_vector := x"00000000";
    BAR4                              : bit_vector := x"00000000";
    BAR5                              : bit_vector := x"00000000";
    EXPANSION_ROM                     : bit_vector := "0000000000000000000000";
    DISABLE_BAR_FILTERING             : boolean    := FALSE;
    DISABLE_ID_CHECK                  : boolean    := FALSE;
    TL_TFC_DISABLE                    : boolean    := FALSE;
    TL_TX_CHECKS_DISABLE              : boolean    := FALSE;
    USR_CFG                           : boolean    := FALSE;
    USR_EXT_CFG                       : boolean    := FALSE;
    DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer    := 2;
    CLASS_CODE                        : bit_vector := x"050000";
    CARDBUS_CIS_POINTER               : bit_vector := x"00000000";
    PCIE_CAP_CAPABILITY_VERSION       : bit_vector := x"1";
    PCIE_CAP_DEVICE_PORT_TYPE         : bit_vector := x"0";
    PCIE_CAP_SLOT_IMPLEMENTED         : boolean    := FALSE;
    PCIE_CAP_INT_MSG_NUM              : bit_vector := "00000";
    DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer    := 0;
    DEV_CAP_EXT_TAG_SUPPORTED         : boolean    := FALSE;
    DEV_CAP_ENDPOINT_L0S_LATENCY      : integer    := 7;
    DEV_CAP_ENDPOINT_L1_LATENCY       : integer    := 7;
    SLOT_CAP_ATT_BUTTON_PRESENT       : boolean    := FALSE;
    SLOT_CAP_ATT_INDICATOR_PRESENT    : boolean    := FALSE;
    SLOT_CAP_POWER_INDICATOR_PRESENT  : boolean    := FALSE;
    DEV_CAP_ROLE_BASED_ERROR          : boolean    := TRUE;
    LINK_CAP_ASPM_SUPPORT             : integer    := 1;
    LINK_CAP_L0S_EXIT_LATENCY         : integer    := 7;
    LINK_CAP_L1_EXIT_LATENCY          : integer    := 7;
    LL_ACK_TIMEOUT                    : bit_vector := x"0000";
    LL_ACK_TIMEOUT_EN                 : boolean    := FALSE;
    LL_REPLAY_TIMEOUT                 : bit_vector := x"00FF";
    LL_REPLAY_TIMEOUT_EN              : boolean    := TRUE;
    MSI_CAP_MULTIMSGCAP               : integer    := 0;
    MSI_CAP_MULTIMSG_EXTENSION        : integer    := 0;
    LINK_STATUS_SLOT_CLOCK_CONFIG     : boolean    := FALSE;
    PLM_AUTO_CONFIG                   : boolean    := FALSE;
    FAST_TRAIN                        : boolean    := FALSE;
    ENABLE_RX_TD_ECRC_TRIM            : boolean    := TRUE;
    DISABLE_SCRAMBLING                : boolean    := FALSE;
    PM_CAP_VERSION                    : integer    := 3;
    PM_CAP_PME_CLOCK                  : boolean    := FALSE;
    PM_CAP_DSI                        : boolean    := FALSE;
    PM_CAP_AUXCURRENT                 : integer    := 0;
    PM_CAP_D1SUPPORT                  : boolean    := TRUE;
    PM_CAP_D2SUPPORT                  : boolean    := TRUE;
    PM_CAP_PMESUPPORT                 : bit_vector := x"0F";
    PM_DATA0                          : bit_vector := x"00";
    PM_DATA_SCALE0                    : bit_vector := x"0";
    PM_DATA1                          : bit_vector := x"00";
    PM_DATA_SCALE1                    : bit_vector := x"0";
    PM_DATA2                          : bit_vector := x"00";
    PM_DATA_SCALE2                    : bit_vector := x"0";
    PM_DATA3                          : bit_vector := x"00";
    PM_DATA_SCALE3                    : bit_vector := x"0";
    PM_DATA4                          : bit_vector := x"00";
    PM_DATA_SCALE4                    : bit_vector := x"0";
    PM_DATA5                          : bit_vector := x"00";
    PM_DATA_SCALE5                    : bit_vector := x"0";
    PM_DATA6                          : bit_vector := x"00";
    PM_DATA_SCALE6                    : bit_vector := x"0";
    PM_DATA7                          : bit_vector := x"00";
    PM_DATA_SCALE7                    : bit_vector := x"0";
    PCIE_GENERIC                      : bit_vector := "000011101111";
    GTP_SEL                           : integer    := 0;
    CFG_VEN_ID                        : std_logic_vector(15 downto 0) := x"10EE";
    CFG_DEV_ID                        : std_logic_vector(15 downto 0) := x"0007";
    CFG_REV_ID                        : std_logic_vector(7 downto 0)  := x"00";
    CFG_SUBSYS_VEN_ID                 : std_logic_vector(15 downto 0) := x"10EE";
    CFG_SUBSYS_ID                     : std_logic_vector(15 downto 0) := x"0007";
    REF_CLK_FREQ                      : integer    := 1
  );
  port (
    -- PCI Express Fabric Interface
    pci_exp_txp             : out std_logic;
    pci_exp_txn             : out std_logic;
    pci_exp_rxp             : in  std_logic;
    pci_exp_rxn             : in  std_logic;

    user_lnk_up             : out std_logic;

    -- Tx
    s_axis_tx_tdata         : in  std_logic_vector(31 downto 0);
    s_axis_tx_tlast         : in  std_logic;
    s_axis_tx_tvalid        : in  std_logic;
    s_axis_tx_tready        : out std_logic;
    s_axis_tx_tkeep         : in  std_logic_vector(3 downto 0);
    s_axis_tx_tuser         : in  std_logic_vector(3 downto 0);
    tx_err_drop             : out std_logic;
    tx_buf_av               : out std_logic_vector(5 downto 0);
    tx_cfg_req              : out std_logic;
    tx_cfg_gnt              : in  std_logic;

    -- Rx
    m_axis_rx_tdata         : out std_logic_vector(31 downto 0);
    m_axis_rx_tlast         : out std_logic;
    m_axis_rx_tvalid        : out std_logic;
    m_axis_rx_tkeep         : out std_logic_vector(3 downto 0);
    m_axis_rx_tready        : in  std_logic;
    m_axis_rx_tuser         : out std_logic_vector(21 downto 0);
    rx_np_ok                : in  std_logic;

    fc_sel                  : in  std_logic_vector(2 downto 0);
    fc_nph                  : out std_logic_vector(7 downto 0);
    fc_npd                  : out std_logic_vector(11 downto 0);
    fc_ph                   : out std_logic_vector(7 downto 0);
    fc_pd                   : out std_logic_vector(11 downto 0);
    fc_cplh                 : out std_logic_vector(7 downto 0);
    fc_cpld                 : out std_logic_vector(11 downto 0);

    -- Host (CFG) Interface
    cfg_do                  : out std_logic_vector(31 downto 0);
    cfg_rd_wr_done          : out std_logic;
    cfg_dwaddr              : in  std_logic_vector(9 downto 0);
    cfg_rd_en               : in  std_logic;
    cfg_err_ur              : in  std_logic;
    cfg_err_cor             : in  std_logic;
    cfg_err_ecrc            : in  std_logic;
    cfg_err_cpl_timeout     : in  std_logic;
    cfg_err_cpl_abort       : in  std_logic;
    cfg_err_posted          : in  std_logic;
    cfg_err_locked          : in  std_logic;
    cfg_err_tlp_cpl_header  : in  std_logic_vector(47 downto 0);
    cfg_err_cpl_rdy         : out std_logic;
    cfg_interrupt           : in  std_logic;
    cfg_interrupt_rdy       : out std_logic;
    cfg_interrupt_assert    : in  std_logic;
    cfg_interrupt_do        : out std_logic_vector(7 downto 0);
    cfg_interrupt_di        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable  : out std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : out std_logic;
    cfg_turnoff_ok          : in  std_logic;
    cfg_to_turnoff          : out std_logic;
    cfg_pm_wake             : in  std_logic;
    cfg_pcie_link_state     : out std_logic_vector(2 downto 0);
    cfg_trn_pending         : in  std_logic;
    cfg_dsn                 : in  std_logic_vector(63 downto 0);
    cfg_bus_number          : out std_logic_vector(7 downto 0);
    cfg_device_number       : out std_logic_vector(4 downto 0);
    cfg_function_number     : out std_logic_vector(2 downto 0);
    cfg_status              : out std_logic_vector(15 downto 0);
    cfg_command             : out std_logic_vector(15 downto 0);
    cfg_dstatus             : out std_logic_vector(15 downto 0);
    cfg_dcommand            : out std_logic_vector(15 downto 0);
    cfg_lstatus             : out std_logic_vector(15 downto 0);
    cfg_lcommand            : out std_logic_vector(15 downto 0);

    -- System Interface
    sys_clk                 : in  std_logic;
    sys_reset               : in  std_logic;
    user_clk_out            : out std_logic;
    user_reset_out          : out std_logic;
    received_hot_reset      : out std_logic
  );
end s6_pcie_v2_4;

architecture rtl of s6_pcie_v2_4 is

  attribute CORE_GENERATION_INFO : STRING;
  attribute CORE_GENERATION_INFO of rtl : architecture is
    "s6_pcie_v2_4,s6_pcie_v2_4,{TL_TX_RAM_RADDR_LATENCY=0,TL_TX_RAM_RDATA_LATENCY=2,TL_RX_RAM_RADDR_LATENCY=0,TL_RX_RAM_RDATA_LATENCY=2,TL_RX_RAM_WRITE_LATENCY=0,VC0_TX_LASTPACKET=14,VC0_RX_RAM_LIMIT=7FF,VC0_TOTAL_CREDITS_PH=32,VC0_TOTAL_CREDITS_PD=211,VC0_TOTAL_CREDITS_NPH=8,VC0_TOTAL_CREDITS_CH=40,VC0_TOTAL_CREDITS_CD=211,VC0_CPL_INFINITE=TRUE,BAR0=FFF00000,BAR1=00000000,BAR2=00000000,BAR3=00000000,BAR4=00000000,BAR5=00000000,EXPANSION_ROM=000000,USR_CFG=FALSE,USR_EXT_CFG=FALSE,DEV_CAP_MAX_PAYLOAD_SUPPORTED=2,CLASS_CODE=050000,CARDBUS_CIS_POINTER=00000000,PCIE_CAP_CAPABILITY_VERSION=1,PCIE_CAP_DEVICE_PORT_TYPE=0,DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT=0,DEV_CAP_EXT_TAG_SUPPORTED=FALSE,DEV_CAP_ENDPOINT_L0S_LATENCY=7,DEV_CAP_ENDPOINT_L1_LATENCY=7,LINK_CAP_ASPM_SUPPORT=1,MSI_CAP_MULTIMSGCAP=0,MSI_CAP_MULTIMSG_EXTENSION=0,LINK_STATUS_SLOT_CLOCK_CONFIG=FALSE,ENABLE_RX_TD_ECRC_TRIM=TRUE,DISABLE_SCRAMBLING=FALSE,PM_CAP_DSI=FALSE,PM_CAP_D1SUPPORT=TRUE,PM_CAP_D2SUPPORT=TRUE,PM_CAP_PMESUPPORT=0F,PM_DATA0=00,PM_DATA_SCALE0=0,PM_DATA1=00,PM_DATA_SCALE1=0,PM_DATA2=00,PM_DATA_SCALE2=0,PM_DATA3=00,PM_DATA_SCALE3=0,PM_DATA4=00,PM_DATA_SCALE4=0,PM_DATA5=00,PM_DATA_SCALE5=0,PM_DATA6=00,PM_DATA_SCALE6=0,PM_DATA7=00,PM_DATA_SCALE7=0,PCIE_GENERIC=000010101111,GTP_SEL=0,CFG_VEN_ID=10EE,CFG_DEV_ID=0007,CFG_REV_ID=00,CFG_SUBSYS_VEN_ID=10EE,CFG_SUBSYS_ID=0007,REF_CLK_FREQ=1}";

  ------------------------
  -- Function Declarations
  ------------------------
  function CALC_CLKFBOUT_MULT(FREQ_SEL : integer) return integer is
  begin
    case FREQ_SEL is
      when 0 => return 5;      -- 100 MHz
      when others => return 4; -- 125 MHz
    end case;
  end CALC_CLKFBOUT_MULT;
  function CALC_CLKIN_PERIOD(FREQ_SEL : integer) return real is
  begin
    case FREQ_SEL is
      when 0 => return 10.0;     -- 100 MHz
      when others => return 8.0; -- 125 MHz
    end case;
  end CALC_CLKIN_PERIOD;
  function CALC_CLK25_DIVIDER(FREQ_SEL : integer) return integer is
  begin
    case FREQ_SEL is
      when 0 => return 4;      -- 100 MHz
      when others => return 5; -- 125 MHz
    end case;
  end CALC_CLK25_DIVIDER;
  function CALC_PLL_DIVSEL_FB(FREQ_SEL : integer) return integer is
  begin
    case FREQ_SEL is
      when 0 => return 5;      -- 100 MHz
      when others => return 2; -- 125 MHz
    end case;
  end CALC_PLL_DIVSEL_FB;
  function CALC_PLL_DIVSEL_REF(FREQ_SEL : integer) return integer is
  begin
    case FREQ_SEL is
      when 0 => return 2;      -- 100 MHz
      when others => return 1; -- 125 MHz
    end case;
  end CALC_PLL_DIVSEL_REF;
  function SIM_INT(SIMULATION : boolean) return integer is
  begin
    if SIMULATION then
      return 1;
    else
      return 0;
    end if;
  end SIM_INT;

  ------------------------
  -- Constant Declarations
  ------------------------

  constant CLKFBOUT_MULT     : integer := CALC_CLKFBOUT_MULT(REF_CLK_FREQ);
  constant CLKIN_PERIOD      : real    := CALC_CLKIN_PERIOD(REF_CLK_FREQ);
  constant GT_CLK25_DIVIDER  : integer := CALC_CLK25_DIVIDER(REF_CLK_FREQ);
  constant GT_PLL_DIVSEL_FB  : integer := CALC_PLL_DIVSEL_FB(REF_CLK_FREQ);
  constant GT_PLL_DIVSEL_REF : integer := CALC_PLL_DIVSEL_REF(REF_CLK_FREQ);
  constant C_DATA_WIDTH              : INTEGER := 32;     -- RX/TX interface data width
  constant C_FAMILY                  : STRING := "S6";    -- Targeted FPGA family
  constant C_ROOT_PORT               : BOOLEAN := FALSE;  -- pcie block is in root port mode
  constant C_PM_PRIORITY             : BOOLEAN := TRUE;   -- disable tx packet boundary thrtl
  constant C_TCQ                     : INTEGER := 1;      -- Clock to Q time

  constant C_REM_WIDTH               : INTEGER := 1;      -- trem/rrem width
  constant C_STRB_WIDTH              : INTEGER := 4;      -- tkeep width


  -------------------------
  -- Component Declarations
  -------------------------
  component axi_basic_top is
  generic (
      C_DATA_WIDTH              : INTEGER := 32;     -- RX/TX interface data width
      C_FAMILY                  : STRING := "S6";    -- Targeted FPGA family
      C_ROOT_PORT               : BOOLEAN := FALSE; -- pcie block is in root port mode
      C_PM_PRIORITY             : BOOLEAN := FALSE; -- disable tx packet boundary thrtl
      TCQ                       : INTEGER := 1;      -- Clock to Q time

      C_REM_WIDTH               : INTEGER := 1;      -- trem/rrem width
      C_STRB_WIDTH              : INTEGER := 4       -- tkeep width
   );
   PORT (
      -----------------------------------------------
      -- User Design I/O
      -----------------------------------------------

      -- AXI TX
      -------------
      s_axis_tx_tdata         : in std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      s_axis_tx_tvalid        : in std_logic                                   := '0';
      s_axis_tx_tready        : out std_logic                                  := '0';
      s_axis_tx_tkeep         : in std_logic_vector(C_STRB_WIDTH - 1 downto 0) := (others=>'0');
      s_axis_tx_tlast         : in std_logic                                   := '0';
      s_axis_tx_tuser         : in std_logic_vector(3 downto 0) := (others=>'0');

      -- AXI RX
      -------------
      m_axis_rx_tdata         : out std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      m_axis_rx_tvalid        : out std_logic                                   := '0';
      m_axis_rx_tready        : in std_logic                                    := '0';
      m_axis_rx_tkeep         : out std_logic_vector(C_STRB_WIDTH - 1 downto 0) := (others=>'0');
      m_axis_rx_tlast         : out std_logic                                   := '0';
      m_axis_rx_tuser         : out std_logic_vector(21 downto 0) := (others=>'0');

      -- user misc.
      -------------
      user_turnoff_ok         : in std_logic                                   := '0';
      user_tcfg_gnt           : in std_logic                                   := '0';

      -----------------------------------------------
      -- PCIe block I/O
      -----------------------------------------------

      -- TRN TX
      -------------
      trn_td                  : out std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      trn_tsof                : out std_logic                                   := '0';
      trn_teof                : out std_logic                                   := '0';
      trn_tsrc_rdy            : out std_logic                                   := '0';
      trn_tdst_rdy            : in std_logic                                    := '0';
      trn_tsrc_dsc            : out std_logic                                   := '0';
      trn_trem                : out std_logic_vector(C_REM_WIDTH - 1 downto 0)  := (others=>'0');
      trn_terrfwd             : out std_logic                                   := '0';
      trn_tstr                : out std_logic                                   := '0';
      trn_tbuf_av             : in std_logic_vector(5 downto 0)                 := (others=>'0');
      trn_tecrc_gen           : out std_logic                                   := '0';

      -- TRN RX
      -------------
      trn_rd                  : in std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others=>'0');
      trn_rsof                : in std_logic                                   := '0';
      trn_reof                : in std_logic                                   := '0';
      trn_rsrc_rdy            : in std_logic                                   := '0';
      trn_rdst_rdy            : out std_logic                                  := '0';
      trn_rsrc_dsc            : in std_logic                                   := '0';
      trn_rrem                : in std_logic_vector(C_REM_WIDTH - 1 downto 0)  := (others=>'0');
      trn_rerrfwd             : in std_logic                                   := '0';
      trn_rbar_hit            : in std_logic_vector(6 downto 0)                := (others=>'0');
      trn_recrc_err           : in std_logic                                   := '0';

      -- TRN misc.
      -------------
      trn_tcfg_req            : in std_logic                                   := '0';
      trn_tcfg_gnt            : out std_logic                                  := '0';
      trn_lnk_up              : in std_logic                                   := '0';

      -- 7 series/Virtex6 PM
      -------------
      cfg_pcie_link_state     : in std_logic_vector(2 downto 0)                := (others=>'0');

      -- Virtex6 PM
      -------------
      cfg_pm_send_pme_to      : in std_logic                                   := '0';
      cfg_pmcsr_powerstate    : in std_logic_vector(1 downto 0)                := (others=>'0');
      trn_rdllp_data          : in std_logic_vector(31 downto 0)               := (others=>'0');
      trn_rdllp_src_rdy       : in std_logic                                   := '0';

      -- Virtex6/Spartan6 PM
      -------------
      cfg_to_turnoff          : in std_logic                                   := '0';
      cfg_turnoff_ok          : out std_logic                                  := '0';

      np_counter              : out std_logic_vector(2 downto 0)               := (others=>'0');
      user_clk                : in std_logic                                   := '0';
      user_rst                : in std_logic                                   := '0'
   );
END COMPONENT axi_basic_top;


  component pcie_bram_top_s6 is
  generic (
    DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer    := 0;

    VC0_TX_LASTPACKET             : integer    := 31;
    TLM_TX_OVERHEAD               : integer    := 24;
    TL_TX_RAM_RADDR_LATENCY       : integer    := 1;
    TL_TX_RAM_RDATA_LATENCY       : integer    := 1;
    TL_TX_RAM_WRITE_LATENCY       : integer    := 1;

    VC0_RX_LIMIT                  : integer    := 16#1FFF#;
    TL_RX_RAM_RADDR_LATENCY       : integer    := 1;
    TL_RX_RAM_RDATA_LATENCY       : integer    := 1;
    TL_RX_RAM_WRITE_LATENCY       : integer    := 1
    );
  port (
    user_clk_i                    : in std_logic;
    reset_i                       : in std_logic;

    mim_tx_wen                    : in std_logic;
    mim_tx_waddr                  : in std_logic_vector(11 downto 0);
    mim_tx_wdata                  : in std_logic_vector(35 downto 0);
    mim_tx_ren                    : in std_logic;
    mim_tx_rce                    : in std_logic;
    mim_tx_raddr                  : in std_logic_vector(11 downto 0);
    mim_tx_rdata                  : out std_logic_vector(35 downto 0);

    mim_rx_wen                    : in std_logic;
    mim_rx_waddr                  : in std_logic_vector(11 downto 0);
    mim_rx_wdata                  : in std_logic_vector(35 downto 0);
    mim_rx_ren                    : in std_logic;
    mim_rx_rce                    : in std_logic;
    mim_rx_raddr                  : in std_logic_vector(11 downto 0);
    mim_rx_rdata                  : out std_logic_vector(35 downto 0)
  );
  end component pcie_bram_top_s6;

  component GTPA1_DUAL_WRAPPER is
  generic
  (
    -- Simulation attributes
    WRAPPER_SIM_GTPRESET_SPEEDUP    : integer   := 0; -- Set to 1 to speed up sim reset
    WRAPPER_CLK25_DIVIDER_0         : integer   := 4;
    WRAPPER_CLK25_DIVIDER_1         : integer   := 4;
    WRAPPER_PLL_DIVSEL_FB_0         : integer   := 5;
    WRAPPER_PLL_DIVSEL_FB_1         : integer   := 5;
    WRAPPER_PLL_DIVSEL_REF_0        : integer   := 2;
    WRAPPER_PLL_DIVSEL_REF_1        : integer   := 2;
    WRAPPER_SIMULATION              : integer   := 0  -- Set to 1 for simulation
  );
  port
  (

    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE0  (X0_Y0)

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_RXPOWERDOWN0_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_RXPOWERDOWN1_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_TXPOWERDOWN0_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_TXPOWERDOWN1_IN                   : in   std_logic_vector(1 downto 0);
    --------------------------------- PLL Ports --------------------------------
    TILE0_CLK00_IN                          : in   std_logic;
    TILE0_CLK01_IN                          : in   std_logic;
    TILE0_GTPRESET0_IN                      : in   std_logic;
    TILE0_GTPRESET1_IN                      : in   std_logic;
    TILE0_PLLLKDET0_OUT                     : out  std_logic;
    TILE0_PLLLKDET1_OUT                     : out  std_logic;
    TILE0_RESETDONE0_OUT                    : out  std_logic;
    TILE0_RESETDONE1_OUT                    : out  std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISK0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXCHARISK1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE0_OUT                 : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE1_OUT                 : out  std_logic_vector(1 downto 0);
    ---------------------- Receive Ports - Clock Correction --------------------
    TILE0_RXCLKCORCNT0_OUT                  : out  std_logic_vector(2 downto 0);
    TILE0_RXCLKCORCNT1_OUT                  : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXRESET0_IN                       : in   std_logic;
    TILE0_RXRESET1_IN                       : in   std_logic;
    TILE0_RXUSRCLK0_IN                      : in   std_logic;
    TILE0_RXUSRCLK1_IN                      : in   std_logic;
    TILE0_RXUSRCLK20_IN                     : in   std_logic;
    TILE0_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_GATERXELECIDLE0_IN                : in   std_logic;
    TILE0_GATERXELECIDLE1_IN                : in   std_logic;
    TILE0_IGNORESIGDET0_IN                  : in   std_logic;
    TILE0_IGNORESIGDET1_IN                  : in   std_logic;
    TILE0_RXELECIDLE0_OUT                   : out  std_logic;
    TILE0_RXELECIDLE1_OUT                   : out  std_logic;
    TILE0_RXN0_IN                           : in   std_logic;
    TILE0_RXN1_IN                           : in   std_logic;
    TILE0_RXP0_IN                           : in   std_logic;
    TILE0_RXP1_IN                           : in   std_logic;
    ----------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    TILE0_RXSTATUS0_OUT                     : out  std_logic_vector(2 downto 0);
    TILE0_RXSTATUS1_OUT                     : out  std_logic_vector(2 downto 0);
    -------------- Receive Ports - RX Pipe Control for PCI Express -------------
    TILE0_PHYSTATUS0_OUT                    : out  std_logic;
    TILE0_PHYSTATUS1_OUT                    : out  std_logic;
    TILE0_RXVALID0_OUT                      : out  std_logic;
    TILE0_RXVALID1_OUT                      : out  std_logic;
    -------------------- Receive Ports - RX Polarity Control -------------------
    TILE0_RXPOLARITY0_IN                    : in   std_logic;
    TILE0_RXPOLARITY1_IN                    : in   std_logic;
    ---------------------------- TX/RX Datapath Ports --------------------------
    TILE0_GTPCLKOUT0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_GTPCLKOUT1_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Transmit Ports - 8b10b Encoder Control -----------------
    TILE0_TXCHARDISPMODE0_IN                : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARDISPMODE1_IN                : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARISK0_IN                     : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARISK1_IN                     : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXDATA1_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXUSRCLK0_IN                      : in   std_logic;
    TILE0_TXUSRCLK1_IN                      : in   std_logic;
    TILE0_TXUSRCLK20_IN                     : in   std_logic;
    TILE0_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT                          : out  std_logic;
    TILE0_TXN1_OUT                          : out  std_logic;
    TILE0_TXP0_OUT                          : out  std_logic;
    TILE0_TXP1_OUT                          : out  std_logic;
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    TILE0_TXDETECTRX0_IN                    : in   std_logic;
    TILE0_TXDETECTRX1_IN                    : in   std_logic;
    TILE0_TXELECIDLE0_IN                    : in   std_logic;
    TILE0_TXELECIDLE1_IN                    : in   std_logic
  );
  end component GTPA1_DUAL_WRAPPER;

  ----------------------
  -- Signal Declarations
  ----------------------

  signal trn_td               : std_logic_vector( 31 downto 0);
  signal trn_tsof             : std_logic;
  signal trn_teof             : std_logic;
  signal trn_tsrc_rdy         : std_logic;
  signal trn_tdst_rdy_n       : std_logic;
  signal trn_terr_drop_n      : std_logic;
  signal trn_tsrc_dsc         : std_logic;
  signal trn_terrfwd          : std_logic;
  signal trn_tstr             : std_logic;
  signal trn_tcfg_req_n       : std_logic;
  signal trn_tcfg_gnt         : std_logic;

  signal trn_rd               : std_logic_vector( 31 downto 0);
  signal trn_rsof_n           : std_logic;
  signal trn_reof_n           : std_logic;
  signal trn_rsrc_rdy_n       : std_logic;
  signal trn_rsrc_dsc_n       : std_logic;
  signal trn_rdst_rdy         : std_logic;
  signal trn_rerrfwd_n        : std_logic;
  signal trn_rbar_hit_n       : std_logic_vector( 6 downto 0);

  signal cfg_rd_wr_done_n     : std_logic;
  signal cfg_interrupt_rdy_n  : std_logic;
  signal cfg_turnoff_ok_w     : std_logic;
  signal cfg_to_turnoff_n     : std_logic;
  signal cfg_err_cpl_rdy_n    : std_logic;
  signal user_reset_out_n_w   : std_logic;
  signal user_lnk_up_w        : std_logic;

  -- PLL Signals
  signal mgt_clk            : std_logic;
  signal mgt_clk_2x         : std_logic;
  signal clock_locked       : std_logic;
  signal gt_refclk_out      : std_logic_vector(1 downto 0);
  signal gt_clk_fb_west_out : std_logic;
  signal pll_rst            : std_logic;
  signal clk_125            : std_logic;
  signal clk_250            : std_logic;
  signal clk_62_5           : std_logic;
  signal gt_refclk_buf      : std_logic;
  signal gt_refclk_fb       : std_logic;

  signal w_cfg_ven_id        : std_logic_vector(15 downto 0);
  signal w_cfg_dev_id        : std_logic_vector(15 downto 0);
  signal w_cfg_rev_id        : std_logic_vector(7 downto 0);
  signal w_cfg_subsys_ven_id : std_logic_vector(15 downto 0);
  signal w_cfg_subsys_id     : std_logic_vector(15 downto 0);

  signal cfg_ltssm_state                        : std_logic_vector(4 downto 0);
  signal cfg_link_control_aspm_control          : std_logic_vector(1 downto 0);
  signal cfg_link_control_rcb                   : std_logic;
  signal cfg_link_control_common_clock          : std_logic;
  signal cfg_link_control_extended_sync         : std_logic;
  signal cfg_command_interrupt_disable          : std_logic;
  signal cfg_command_serr_en                    : std_logic;
  signal cfg_command_bus_master_enable          : std_logic;
  signal cfg_command_mem_enable                 : std_logic;
  signal cfg_command_io_enable                  : std_logic;
  signal cfg_dev_status_ur_detected             : std_logic;
  signal cfg_dev_status_fatal_err_detected      : std_logic;
  signal cfg_dev_status_nonfatal_err_detected   : std_logic;
  signal cfg_dev_status_corr_err_detected       : std_logic;
  signal cfg_dev_control_max_read_req           : std_logic_vector(2 downto 0);
  signal cfg_dev_control_no_snoop_en            : std_logic;
  signal cfg_dev_control_aux_power_en           : std_logic;
  signal cfg_dev_control_phantom_en             : std_logic;
  signal cfg_dev_cntrol_ext_tag_en              : std_logic;
  signal cfg_dev_control_max_payload            : std_logic_vector(2 downto 0);
  signal cfg_dev_control_enable_ro              : std_logic;
  signal cfg_dev_control_ext_tag_en             : std_logic;
  signal cfg_dev_control_ur_err_reporting_en    : std_logic;
  signal cfg_dev_control_fatal_err_reporting_en : std_logic;
  signal cfg_dev_control_non_fatal_reporting_en : std_logic;
  signal cfg_dev_control_corr_err_reporting_en  : std_logic;

  signal mim_tx_waddr                           : std_logic_vector(11 downto 0);
  signal mim_tx_raddr                           : std_logic_vector(11 downto 0);
  signal mim_rx_waddr                           : std_logic_vector(11 downto 0);
  signal mim_rx_raddr                           : std_logic_vector(11 downto 0);
  signal mim_tx_wdata                           : std_logic_vector(35 downto 0);
  signal mim_tx_rdata                           : std_logic_vector(35 downto 0);
  signal mim_rx_wdata                           : std_logic_vector(34 downto 0);
  signal mim_rx_rdata_unused                    : std_logic;
  signal mim_rx_rdata                           : std_logic_vector(34 downto 0);
  signal mim_tx_wen                             : std_logic;
  signal mim_tx_ren                             : std_logic;
  signal mim_rx_wen                             : std_logic;
  signal mim_rx_ren                             : std_logic;

  signal dbg_bad_dllp_status                    : std_logic;
  signal dbg_bad_tlp_lcrc                       : std_logic;
  signal dbg_bad_tlp_seq_num                    : std_logic;
  signal dbg_bad_tlp_status                     : std_logic;
  signal dbg_dl_protocol_status                 : std_logic;
  signal dbg_fc_protocol_err_status             : std_logic;
  signal dbg_mlfrmd_length                      : std_logic;
  signal dbg_mlfrmd_mps                         : std_logic;
  signal dbg_mlfrmd_tcvc                        : std_logic;
  signal dbg_mlfrmd_tlp_status                  : std_logic;
  signal dbg_mlfrmd_unrec_type                  : std_logic;
  signal dbg_poistlpstatus                      : std_logic;
  signal dbg_rcvr_overflow_status               : std_logic;
  signal dbg_reg_detected_correctable           : std_logic;
  signal dbg_reg_detected_fatal                 : std_logic;
  signal dbg_reg_detected_non_fatal             : std_logic;
  signal dbg_reg_detected_unsupported           : std_logic;
  signal dbg_rply_rollover_status               : std_logic;
  signal dbg_rply_timeout_status                : std_logic;
  signal dbg_ur_no_bar_hit                      : std_logic;
  signal dbg_ur_pois_cfg_wr                     : std_logic;
  signal dbg_ur_status                          : std_logic;
  signal dbg_ur_unsup_msg                       : std_logic;

  signal pipe_gt_power_down_a                   : std_logic_vector(1 downto 0);
  signal pipe_gt_power_down_b                   : std_logic_vector(1 downto 0);
  signal pipe_gt_reset_done_a                   : std_logic;
  signal pipe_gt_reset_done_b                   : std_logic;
  signal pipe_gt_tx_elec_idle_a                 : std_logic;
  signal pipe_gt_tx_elec_idle_b                 : std_logic;
  signal pipe_phy_status_a                      : std_logic;
  signal pipe_phy_status_b                      : std_logic;
  signal pipe_rx_charisk_a                      : std_logic_vector(1 downto 0);
  signal pipe_rx_charisk_b                      : std_logic_vector(1 downto 0);
  signal pipe_rx_data_a                         : std_logic_vector(15 downto 0);
  signal pipe_rx_data_b                         : std_logic_vector(15 downto 0);
  signal pipe_rx_enter_elec_idle_a              : std_logic;
  signal pipe_rx_enter_elec_idle_b              : std_logic;
  signal pipe_rx_polarity_a                     : std_logic;
  signal pipe_rx_polarity_b                     : std_logic;
  signal pipe_rxreset_a                         : std_logic;
  signal pipe_rxreset_b                         : std_logic;
  signal pipe_rx_status_a                       : std_logic_vector(2 downto 0);
  signal pipe_rx_status_b                       : std_logic_vector(2 downto 0);
  signal pipe_tx_char_disp_mode_a               : std_logic_vector(1 downto 0);
  signal pipe_tx_char_disp_mode_b               : std_logic_vector(1 downto 0);
  signal pipe_tx_char_disp_val_a                : std_logic_vector(1 downto 0);
  signal pipe_tx_char_disp_val_b                : std_logic_vector(1 downto 0);
  signal pipe_tx_char_is_k_a                    : std_logic_vector(1 downto 0);
  signal pipe_tx_char_is_k_b                    : std_logic_vector(1 downto 0);
  signal pipe_tx_data_a                         : std_logic_vector(15 downto 0);
  signal pipe_tx_data_b                         : std_logic_vector(15 downto 0);
  signal pipe_tx_rcvr_det_a                     : std_logic;
  signal pipe_tx_rcvr_det_b                     : std_logic;

  -- GT->PLM PIPE Interface rx
  signal rx_char_is_k                           : std_logic_vector(1 downto 0);
  signal rx_data                                : std_logic_vector(15 downto 0);
  signal rx_enter_elecidle                      : std_logic;
  signal rx_status                              : std_logic_vector(2 downto 0);
  signal rx_polarity                            : std_logic;

  -- GT<-PLM PIPE Interface tx
  signal tx_char_disp_mode                      : std_logic_vector(1 downto 0);
  signal tx_char_is_k                           : std_logic_vector(1 downto 0);
  signal tx_rcvr_det                            : std_logic;
  signal tx_data                                : std_logic_vector(15 downto 0);

  -- GT<->PLM PIPE Interface Misc
  signal phystatus                              : std_logic;

  -- GT<->PLM PIPE Interface MGT Logic I/O
  signal gt_reset_done                          : std_logic;
  signal gt_rx_valid                            : std_logic;
  signal gt_tx_elec_idle                        : std_logic;
  signal gt_power_down                          : std_logic_vector(1 downto 0);
  signal rxreset                                : std_logic;
  signal gt_plllkdet_out                        : std_logic;

  -- Core outputs which are also used in this module - must make local copies
  signal user_clk_out_c                         : std_logic;

  signal cfg_rd_en_n                            : std_logic;
  signal cfg_trn_pending_n                      : std_logic;
  signal cfg_turnoff_ok_n                       : std_logic;
  signal cfg_pm_wake_n                          : std_logic;
  signal cfg_interrupt_n                        : std_logic;
  signal cfg_interrupt_assert_n                 : std_logic;
  signal cfg_err_ecrc_n                         : std_logic;
  signal cfg_err_ur_n                           : std_logic;
  signal cfg_err_cpl_timeout_n                  : std_logic;
  signal cfg_err_cpl_abort_n                    : std_logic;
  signal cfg_err_posted_n                       : std_logic;
  signal cfg_err_cor_n                          : std_logic;
  signal cfg_err_locked_n                       : std_logic;
  signal sys_reset_n                            : std_logic;

  signal trn_rdst_rdy_n                         : std_logic;
  signal rx_np_ok_n                             : std_logic;
  signal trn_tcfg_gnt_n                         : std_logic;
  signal trn_teof_n                             : std_logic;
  signal trn_terrfwd_n                          : std_logic;
  signal trn_tsof_n                             : std_logic;
  signal trn_tsrc_dsc_n                         : std_logic;
  signal trn_tsrc_rdy_n                         : std_logic;
  signal trn_tstr_n                             : std_logic;

  signal trn_tdst_rdy                           : std_logic;
  signal trn_rsof                               : std_logic;
  signal trn_reof                               : std_logic;
  signal trn_rsrc_rdy                           : std_logic;
  signal trn_rsrc_dsc                           : std_logic;
  signal trn_rerrfwd                            : std_logic;
  signal trn_rbar_hit                           : std_logic_vector ( 6 downto 0);


  signal tx_buf_av_c                            : std_logic_vector(5 downto 0);
  signal tx_cfg_req_c                           : std_logic;
  signal cfg_to_turnoff_c                       : std_logic;
  signal user_lnk_up_c                          : std_logic;
  signal cfg_pcie_link_state_c                  : std_logic_vector(2 downto 0);
  signal user_reset_out_c                       : std_logic;

begin

  -- These values may be brought out and driven dynamically
  -- from pins rather than attributes if desired. Note -
  -- if they are not statically driven, the values must be
  -- stable before sys_reset   is released
  w_cfg_ven_id         <= CFG_VEN_ID;
  w_cfg_dev_id         <= CFG_DEV_ID;
  w_cfg_rev_id         <= CFG_REV_ID;
  w_cfg_subsys_ven_id  <= CFG_SUBSYS_VEN_ID;
  w_cfg_subsys_id      <= CFG_SUBSYS_ID;

  -- Assign outputs from internal copies
  user_clk_out         <= user_clk_out_c;

  -- Assign logic inversions
  cfg_rd_en_n             <= not cfg_rd_en ;
  cfg_trn_pending_n       <= not cfg_trn_pending ;
  cfg_turnoff_ok_n        <= not cfg_turnoff_ok_w ;
  cfg_pm_wake_n           <= not cfg_pm_wake ;
  cfg_interrupt_n         <= not cfg_interrupt ;
  cfg_interrupt_assert_n  <= not cfg_interrupt_assert ;
  cfg_err_ecrc_n          <= not cfg_err_ecrc ;
  cfg_err_ur_n            <= not cfg_err_ur ;
  cfg_err_cpl_timeout_n   <= not cfg_err_cpl_timeout ;
  cfg_err_cpl_abort_n     <= not cfg_err_cpl_abort ;
  cfg_err_posted_n        <= not cfg_err_posted ;
  cfg_err_cor_n           <= not cfg_err_cor ;
  cfg_err_locked_n        <= not cfg_err_locked ;
  sys_reset_n             <= not sys_reset;

  cfg_rd_wr_done          <= not cfg_rd_wr_done_n ;
  cfg_to_turnoff          <= not cfg_to_turnoff_n;
  user_lnk_up             <= not user_lnk_up_w;
  cfg_interrupt_rdy       <= not cfg_interrupt_rdy_n ;
  cfg_err_cpl_rdy         <= not cfg_err_cpl_rdy_n ;
  tx_err_drop             <= not trn_terr_drop_n;
  tx_cfg_req              <= not trn_tcfg_req_n;
  user_reset_out          <= not user_reset_out_n_w;

  trn_rdst_rdy_n          <= not trn_rdst_rdy;
  rx_np_ok_n              <= not rx_np_ok;
  trn_tcfg_gnt_n          <= not trn_tcfg_gnt;
  trn_teof_n              <= not trn_teof;
  trn_terrfwd_n           <= not trn_terrfwd;
  trn_tsof_n              <= not trn_tsof;
  trn_tsrc_dsc_n          <= not trn_tsrc_dsc;
  trn_tsrc_rdy_n          <= not trn_tsrc_rdy;
  trn_tstr_n              <= not trn_tstr;

  trn_tdst_rdy            <= not trn_tdst_rdy_n;
  trn_rsof                <= not trn_rsof_n;
  trn_reof                <= not trn_reof_n;
  trn_rsrc_rdy            <= not trn_rsrc_rdy_n;
  trn_rsrc_dsc            <= not trn_rsrc_dsc_n;
  trn_rerrfwd             <= not trn_rerrfwd_n;
  trn_rbar_hit            <= not trn_rbar_hit_n;

  tx_buf_av               <= tx_buf_av_c;
  tx_cfg_req              <= not trn_tcfg_req_n;
  cfg_to_turnoff_c        <= not cfg_to_turnoff_n;
  user_lnk_up_c           <= not user_lnk_up_w;
  cfg_pcie_link_state     <= cfg_pcie_link_state_c;
  user_reset_out_c        <= not user_reset_out_n_w;
  tx_cfg_req_c            <= not trn_tcfg_req_n;

  -- Buffer reference clock from MGT
  gt_refclk_bufio2 : BUFIO2
  port map (
    DIVCLK       => gt_refclk_buf,
    IOCLK        => OPEN,
    SERDESSTROBE => OPEN,
    I            => gt_refclk_out(0)
  );

  pll_base_i : PLL_BASE
  generic map (
    CLKFBOUT_MULT   => CLKFBOUT_MULT,
    CLKFBOUT_PHASE  => 0.0,
    CLKIN_PERIOD    => CLKIN_PERIOD,
    CLKOUT0_DIVIDE  => 2,
    CLKOUT0_PHASE   => 0.0,
    CLKOUT1_DIVIDE  => 4,
    CLKOUT1_PHASE   => 0.0,
    CLKOUT2_DIVIDE  => 8,
    CLKOUT2_PHASE   => 0.0,
    COMPENSATION    => "INTERNAL"
  )
  port map (
    CLKIN     => gt_refclk_buf,
    CLKFBIN   => gt_refclk_fb,
    RST       => pll_rst,
    CLKOUT0   => clk_250,
    CLKOUT1   => clk_125,
    CLKOUT2   => clk_62_5,
    CLKOUT3   => OPEN,
    CLKOUT4   => OPEN,
    CLKOUT5   => OPEN,
    CLKFBOUT  => gt_refclk_fb,
    LOCKED    => clock_locked
  );

  -------------------------------------
  -- Instantiate buffers where required
  -------------------------------------
  mgt_bufg   : BUFG port map (O => mgt_clk,    I => clk_125);
  mgt2x_bufg : BUFG port map (O => mgt_clk_2x, I => clk_250);
  phy_bufg   : BUFG port map (O => user_clk_out_c,  I => clk_62_5);

  ----------------------------
  -- PCI Express BRAM Instance
  ----------------------------
  pcie_bram_top: pcie_bram_top_s6
  generic map (
    DEV_CAP_MAX_PAYLOAD_SUPPORTED => DEV_CAP_MAX_PAYLOAD_SUPPORTED,

    VC0_TX_LASTPACKET             => VC0_TX_LASTPACKET,
    TLM_TX_OVERHEAD               => 20,
    TL_TX_RAM_RADDR_LATENCY       => TL_TX_RAM_RADDR_LATENCY,
    TL_TX_RAM_RDATA_LATENCY       => TL_TX_RAM_RDATA_LATENCY,
    -- NOTE: use the RX value here since there is no separate TX value
    TL_TX_RAM_WRITE_LATENCY       => TL_RX_RAM_WRITE_LATENCY,

    VC0_RX_LIMIT                  => conv_integer(to_stdlogicvector(VC0_RX_RAM_LIMIT)),
    TL_RX_RAM_RADDR_LATENCY       => TL_RX_RAM_RADDR_LATENCY,
    TL_RX_RAM_RDATA_LATENCY       => TL_RX_RAM_RDATA_LATENCY,
    TL_RX_RAM_WRITE_LATENCY       => TL_RX_RAM_WRITE_LATENCY
  )
  port map (
    user_clk_i                    => user_clk_out_c,
    reset_i                       => user_reset_out_c,

    mim_tx_waddr                  => mim_tx_waddr,
    mim_tx_wen                    => mim_tx_wen,
    mim_tx_ren                    => mim_tx_ren,
    mim_tx_rce                    => '1',
    mim_tx_wdata                  => mim_tx_wdata,
    mim_tx_raddr                  => mim_tx_raddr,
    mim_tx_rdata                  => mim_tx_rdata,

    mim_rx_waddr                  => mim_rx_waddr,
    mim_rx_wen                    => mim_rx_wen,
    mim_rx_ren                    => mim_rx_ren,
    mim_rx_rce                    => '1',
    mim_rx_wdata(35)              => '0',
    mim_rx_wdata(34 downto 0)     => mim_rx_wdata,
    mim_rx_raddr                  => mim_rx_raddr,
    mim_rx_rdata(35)              => mim_rx_rdata_unused,
    mim_rx_rdata(34 downto 0)     => mim_rx_rdata
  );

  ---------------------------------
  -- PCI Express GTA1_DUAL Instance
  ---------------------------------
  GT_i : GTPA1_DUAL_WRAPPER
  generic map (
    -- Simulation attributes
    WRAPPER_SIM_GTPRESET_SPEEDUP => 1,
    WRAPPER_CLK25_DIVIDER_0      => GT_CLK25_DIVIDER,
    WRAPPER_CLK25_DIVIDER_1      => GT_CLK25_DIVIDER,
    WRAPPER_PLL_DIVSEL_FB_0      => GT_PLL_DIVSEL_FB,
    WRAPPER_PLL_DIVSEL_FB_1      => GT_PLL_DIVSEL_FB,
    WRAPPER_PLL_DIVSEL_REF_0     => GT_PLL_DIVSEL_REF,
    WRAPPER_PLL_DIVSEL_REF_1     => GT_PLL_DIVSEL_REF,
    WRAPPER_SIMULATION           => SIM_INT(FAST_TRAIN)
  )
  port map (

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_RXPOWERDOWN0_IN => gt_power_down,
    TILE0_RXPOWERDOWN1_IN => "10",
    TILE0_TXPOWERDOWN0_IN => gt_power_down,
    TILE0_TXPOWERDOWN1_IN => "10",
    --------------------------------- PLL Ports --------------------------------
    TILE0_CLK00_IN       => sys_clk,
    TILE0_CLK01_IN       => '0',
    TILE0_GTPRESET0_IN   => sys_reset,
    TILE0_GTPRESET1_IN   => '1',
    TILE0_PLLLKDET0_OUT  => gt_plllkdet_out,
    TILE0_PLLLKDET1_OUT  => OPEN,
    TILE0_RESETDONE0_OUT => gt_reset_done,
    TILE0_RESETDONE1_OUT => OPEN,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISK0_OUT(1) => rx_char_is_k(0),
    TILE0_RXCHARISK0_OUT(0) => rx_char_is_k(1),
    TILE0_RXCHARISK1_OUT    => OPEN,
    TILE0_RXDISPERR0_OUT    => OPEN,
    TILE0_RXDISPERR1_OUT    => OPEN,
    TILE0_RXNOTINTABLE0_OUT => OPEN,
    TILE0_RXNOTINTABLE1_OUT => OPEN,
    ---------------------- Receive Ports - Clock Correction --------------------
    TILE0_RXCLKCORCNT0_OUT => OPEN,
    TILE0_RXCLKCORCNT1_OUT => OPEN,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN => '1',
    TILE0_RXENMCOMMAALIGN1_IN => '1',
    TILE0_RXENPCOMMAALIGN0_IN => '1',
    TILE0_RXENPCOMMAALIGN1_IN => '1',
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT(15 downto 8) => rx_data(7 downto 0),
    TILE0_RXDATA0_OUT(7 downto 0)  => rx_data(15 downto 8),
    TILE0_RXDATA1_OUT              => OPEN,
    TILE0_RXRESET0_IN              => rxreset,
    TILE0_RXRESET1_IN              => '1',
    TILE0_RXUSRCLK0_IN             => mgt_clk_2x,
    TILE0_RXUSRCLK1_IN             => '0',
    TILE0_RXUSRCLK20_IN            => mgt_clk,
    TILE0_RXUSRCLK21_IN            => '0',
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_GATERXELECIDLE0_IN => '0',
    TILE0_GATERXELECIDLE1_IN => '0',
    TILE0_IGNORESIGDET0_IN   => '0',
    TILE0_IGNORESIGDET1_IN   => '0',
    TILE0_RXELECIDLE0_OUT    => rx_enter_elecidle,
    TILE0_RXELECIDLE1_OUT    => OPEN,
    TILE0_RXN0_IN            => pci_exp_rxn,
    TILE0_RXN1_IN            => '0',
    TILE0_RXP0_IN            => pci_exp_rxp,
    TILE0_RXP1_IN            => '0',
    ----------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    TILE0_RXSTATUS0_OUT => rx_status,
    TILE0_RXSTATUS1_OUT => OPEN,
    -------------- Receive Ports - RX Pipe Control for PCI Express -------------
    TILE0_PHYSTATUS0_OUT => phystatus,
    TILE0_PHYSTATUS1_OUT => OPEN,
    TILE0_RXVALID0_OUT   => gt_rx_valid,
    TILE0_RXVALID1_OUT   => OPEN,
    -------------------- Receive Ports - RX Polarity Control -------------------
    TILE0_RXPOLARITY0_IN => rx_polarity,
    TILE0_RXPOLARITY1_IN => '0',
    ---------------------------- TX/RX Datapath Ports --------------------------
    TILE0_GTPCLKOUT0_OUT => gt_refclk_out,
    TILE0_GTPCLKOUT1_OUT => OPEN,
    ------------------- Transmit Ports - 8b10b Encoder Control -----------------
    TILE0_TXCHARDISPMODE0_IN(1) => tx_char_disp_mode(0),
    TILE0_TXCHARDISPMODE0_IN(0) => tx_char_disp_mode(1),
    TILE0_TXCHARDISPMODE1_IN(1) => '0',
    TILE0_TXCHARDISPMODE1_IN(0) => '0',
    TILE0_TXCHARISK0_IN(1)   => tx_char_is_k(0),
    TILE0_TXCHARISK0_IN(0)   => tx_char_is_k(1),
    TILE0_TXCHARISK1_IN(1)   => '0',
    TILE0_TXCHARISK1_IN(0)   => '0',
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN(15 downto 8) => tx_data(7 downto 0),
    TILE0_TXDATA0_IN(7 downto 0)  => tx_data(15 downto 8),
    TILE0_TXDATA1_IN(15 downto 8) => x"00",
    TILE0_TXDATA1_IN(7 downto 0)  => x"00",
    TILE0_TXUSRCLK0_IN            => mgt_clk_2x,
    TILE0_TXUSRCLK1_IN            => '0',
    TILE0_TXUSRCLK20_IN           => mgt_clk,
    TILE0_TXUSRCLK21_IN           => '0',
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT => pci_exp_txn,
    TILE0_TXN1_OUT => OPEN,
    TILE0_TXP0_OUT => pci_exp_txp,
    TILE0_TXP1_OUT => OPEN,
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    TILE0_TXDETECTRX0_IN => tx_rcvr_det,
    TILE0_TXDETECTRX1_IN => '0',
    TILE0_TXELECIDLE0_IN => gt_tx_elec_idle,
    TILE0_TXELECIDLE1_IN => '0'  );

  -- Generate the reset for the PLL
  pll_rst <= (not gt_plllkdet_out) or (not sys_reset_n);

  ---------------------------------------------------------------------------
  -- Generate the connection between PCIE_A1 block and the GTPA1_DUAL.  When
  -- the parameter GTP_SEL is 0, connect to PIPEA, when it is a 1, connect to
  -- PIPEB.
  ---------------------------------------------------------------------------
  PIPE_A_SEL : if (GTP_SEL = 0) generate
    -- Signals from GTPA1_DUAL to PCIE_A1
    pipe_rx_charisk_a         <= rx_char_is_k;
    pipe_rx_data_a            <= rx_data;
    pipe_rx_enter_elec_idle_a <= rx_enter_elecidle;
    pipe_rx_status_a          <= rx_status;
    pipe_phy_status_a         <= phystatus;
    pipe_gt_reset_done_a      <= gt_reset_done;

    -- Unused PCIE_A1 inputs
    pipe_rx_charisk_b         <= "00";
    pipe_rx_data_b            <= x"0000";
    pipe_rx_enter_elec_idle_b <= '0';
    pipe_rx_status_b          <= "000";
    pipe_phy_status_b         <= '0';
    pipe_gt_reset_done_b      <= '0';

    -- Signals from PCIE_A1 to GTPA1_DUAL
    rx_polarity               <= pipe_rx_polarity_a;
    tx_char_disp_mode         <= pipe_tx_char_disp_mode_a;
    tx_char_is_k              <= pipe_tx_char_is_k_a;
    tx_rcvr_det               <= pipe_tx_rcvr_det_a;
    tx_data                   <= pipe_tx_data_a;
    gt_tx_elec_idle           <= pipe_gt_tx_elec_idle_a;
    gt_power_down             <= pipe_gt_power_down_a;
    rxreset                   <= pipe_rxreset_a;
  end generate PIPE_A_SEL;

  PIPE_B_SEL : if (GTP_SEL = 1) generate
    -- Signals from GTPA1_DUAL to PCIE_A1
    pipe_rx_charisk_b         <= rx_char_is_k;
    pipe_rx_data_b            <= rx_data;
    pipe_rx_enter_elec_idle_b <= rx_enter_elecidle;
    pipe_rx_status_b          <= rx_status;
    pipe_phy_status_b         <= phystatus;
    pipe_gt_reset_done_b      <= gt_reset_done;

    -- Unused PCIE_A1 inputs
    pipe_rx_charisk_a         <= "00";
    pipe_rx_data_a            <= x"0000";
    pipe_rx_enter_elec_idle_a <= '0';
    pipe_rx_status_a          <= "000";
    pipe_phy_status_a         <= '0';
    pipe_gt_reset_done_a      <= '0';

    -- Signals from PCIE_A1 to GTPA1_DUAL
    rx_polarity               <= pipe_rx_polarity_b;
    tx_char_disp_mode         <= pipe_tx_char_disp_mode_b;
    tx_char_is_k              <= pipe_tx_char_is_k_b;
    tx_rcvr_det               <= pipe_tx_rcvr_det_b;
    tx_data                   <= pipe_tx_data_b;
    gt_tx_elec_idle           <= pipe_gt_tx_elec_idle_b;
    gt_power_down             <= pipe_gt_power_down_b;
    rxreset                   <= pipe_rxreset_b;
  end generate PIPE_B_SEL;

  ---------------------------------------------------------------
  -- Integrated Endpoint Block for PCI Express Instance (PCIE_A1)
  ---------------------------------------------------------------

  PCIE_A1_inst : PCIE_A1
  generic map (
    BAR0                               => BAR0,
    BAR1                               => BAR1,
    BAR2                               => BAR2,
    BAR3                               => BAR3,
    BAR4                               => BAR4,
    BAR5                               => BAR5,
    CARDBUS_CIS_POINTER                => CARDBUS_CIS_POINTER,
    CLASS_CODE                         => CLASS_CODE,
    DEV_CAP_ENDPOINT_L0S_LATENCY       => DEV_CAP_ENDPOINT_L0S_LATENCY,
    DEV_CAP_ENDPOINT_L1_LATENCY        => DEV_CAP_ENDPOINT_L1_LATENCY,
    DEV_CAP_EXT_TAG_SUPPORTED          => DEV_CAP_EXT_TAG_SUPPORTED,
    DEV_CAP_MAX_PAYLOAD_SUPPORTED      => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
    DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT  => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT,
    DEV_CAP_ROLE_BASED_ERROR           => DEV_CAP_ROLE_BASED_ERROR,
    DISABLE_BAR_FILTERING              => DISABLE_BAR_FILTERING,
    DISABLE_ID_CHECK                   => DISABLE_ID_CHECK,
    DISABLE_SCRAMBLING                 => DISABLE_SCRAMBLING,
    ENABLE_RX_TD_ECRC_TRIM             => ENABLE_RX_TD_ECRC_TRIM,
    EXPANSION_ROM                      => EXPANSION_ROM,
    FAST_TRAIN                         => FAST_TRAIN,
    GTP_SEL                            => GTP_SEL,
    LINK_CAP_ASPM_SUPPORT              => LINK_CAP_ASPM_SUPPORT,
    LINK_CAP_L0S_EXIT_LATENCY          => LINK_CAP_L0S_EXIT_LATENCY,
    LINK_CAP_L1_EXIT_LATENCY           => LINK_CAP_L1_EXIT_LATENCY,
    LINK_STATUS_SLOT_CLOCK_CONFIG      => LINK_STATUS_SLOT_CLOCK_CONFIG,
    LL_ACK_TIMEOUT                     => LL_ACK_TIMEOUT,
    LL_ACK_TIMEOUT_EN                  => LL_ACK_TIMEOUT_EN,
    LL_REPLAY_TIMEOUT                  => LL_REPLAY_TIMEOUT,
    LL_REPLAY_TIMEOUT_EN               => LL_REPLAY_TIMEOUT_EN,
    MSI_CAP_MULTIMSG_EXTENSION         => MSI_CAP_MULTIMSG_EXTENSION,
    MSI_CAP_MULTIMSGCAP                => MSI_CAP_MULTIMSGCAP,
    PCIE_CAP_CAPABILITY_VERSION        => PCIE_CAP_CAPABILITY_VERSION,
    PCIE_CAP_DEVICE_PORT_TYPE          => PCIE_CAP_DEVICE_PORT_TYPE,
    PCIE_CAP_INT_MSG_NUM               => PCIE_CAP_INT_MSG_NUM,
    PCIE_CAP_SLOT_IMPLEMENTED          => PCIE_CAP_SLOT_IMPLEMENTED,
    PCIE_GENERIC                       => PCIE_GENERIC,
    PLM_AUTO_CONFIG                    => PLM_AUTO_CONFIG,
    PM_CAP_AUXCURRENT                  => PM_CAP_AUXCURRENT,
    PM_CAP_DSI                         => PM_CAP_DSI,
    PM_CAP_D1SUPPORT                   => PM_CAP_D1SUPPORT,
    PM_CAP_D2SUPPORT                   => PM_CAP_D2SUPPORT,
    PM_CAP_PME_CLOCK                   => PM_CAP_PME_CLOCK,
    PM_CAP_PMESUPPORT                  => PM_CAP_PMESUPPORT,
    PM_CAP_VERSION                     => PM_CAP_VERSION,
    PM_DATA_SCALE0                     => PM_DATA_SCALE0,
    PM_DATA_SCALE1                     => PM_DATA_SCALE1,
    PM_DATA_SCALE2                     => PM_DATA_SCALE2,
    PM_DATA_SCALE3                     => PM_DATA_SCALE3,
    PM_DATA_SCALE4                     => PM_DATA_SCALE4,
    PM_DATA_SCALE5                     => PM_DATA_SCALE5,
    PM_DATA_SCALE6                     => PM_DATA_SCALE6,
    PM_DATA_SCALE7                     => PM_DATA_SCALE7,
    PM_DATA0                           => PM_DATA0,
    PM_DATA1                           => PM_DATA1,
    PM_DATA2                           => PM_DATA2,
    PM_DATA3                           => PM_DATA3,
    PM_DATA4                           => PM_DATA4,
    PM_DATA5                           => PM_DATA5,
    PM_DATA6                           => PM_DATA6,
    PM_DATA7                           => PM_DATA7,
    SLOT_CAP_ATT_BUTTON_PRESENT        => SLOT_CAP_ATT_BUTTON_PRESENT,
    SLOT_CAP_ATT_INDICATOR_PRESENT     => SLOT_CAP_ATT_INDICATOR_PRESENT,
    SLOT_CAP_POWER_INDICATOR_PRESENT   => SLOT_CAP_POWER_INDICATOR_PRESENT,
    TL_RX_RAM_RADDR_LATENCY            => TL_RX_RAM_RADDR_LATENCY,
    TL_RX_RAM_RDATA_LATENCY            => TL_RX_RAM_RDATA_LATENCY,
    TL_RX_RAM_WRITE_LATENCY            => TL_RX_RAM_WRITE_LATENCY,
    TL_TFC_DISABLE                     => TL_TFC_DISABLE,
    TL_TX_CHECKS_DISABLE               => TL_TX_CHECKS_DISABLE,
    TL_TX_RAM_RADDR_LATENCY            => TL_TX_RAM_RADDR_LATENCY,
    TL_TX_RAM_RDATA_LATENCY            => TL_TX_RAM_RDATA_LATENCY,
    USR_CFG                            => USR_CFG,
    USR_EXT_CFG                        => USR_EXT_CFG,
    VC0_CPL_INFINITE                   => VC0_CPL_INFINITE,
    VC0_RX_RAM_LIMIT                   => VC0_RX_RAM_LIMIT,
    VC0_TOTAL_CREDITS_CD               => VC0_TOTAL_CREDITS_CD,
    VC0_TOTAL_CREDITS_CH               => VC0_TOTAL_CREDITS_CH,
    VC0_TOTAL_CREDITS_NPH              => VC0_TOTAL_CREDITS_NPH,
    VC0_TOTAL_CREDITS_PD               => VC0_TOTAL_CREDITS_PD,
    VC0_TOTAL_CREDITS_PH               => VC0_TOTAL_CREDITS_PH,
    VC0_TX_LASTPACKET                  => VC0_TX_LASTPACKET
  )
  port map (
    CFGBUSNUMBER                       => cfg_bus_number,
    CFGCOMMANDBUSMASTERENABLE          => cfg_command_bus_master_enable,
    CFGCOMMANDINTERRUPTDISABLE         => cfg_command_interrupt_disable,
    CFGCOMMANDIOENABLE                 => cfg_command_io_enable,
    CFGCOMMANDMEMENABLE                => cfg_command_mem_enable,
    CFGCOMMANDSERREN                   => cfg_command_serr_en,
    CFGDEVCONTROLAUXPOWEREN            => cfg_dev_control_aux_power_en,
    CFGDEVCONTROLCORRERRREPORTINGEN    => cfg_dev_control_corr_err_reporting_en,
    CFGDEVCONTROLENABLERO              => cfg_dev_control_enable_ro,
    CFGDEVCONTROLEXTTAGEN              => cfg_dev_control_ext_tag_en,
    CFGDEVCONTROLFATALERRREPORTINGEN   => cfg_dev_control_fatal_err_reporting_en,
    CFGDEVCONTROLMAXPAYLOAD            => cfg_dev_control_max_payload,
    CFGDEVCONTROLMAXREADREQ            => cfg_dev_control_max_read_req,
    CFGDEVCONTROLNONFATALREPORTINGEN   => cfg_dev_control_non_fatal_reporting_en,
    CFGDEVCONTROLNOSNOOPEN             => cfg_dev_control_no_snoop_en,
    CFGDEVCONTROLPHANTOMEN             => cfg_dev_control_phantom_en,
    CFGDEVCONTROLURERRREPORTINGEN      => cfg_dev_control_ur_err_reporting_en,
    CFGDEVICENUMBER                    => cfg_device_number,
    CFGDEVID                           => w_cfg_dev_id,
    CFGDEVSTATUSCORRERRDETECTED        => cfg_dev_status_corr_err_detected,
    CFGDEVSTATUSFATALERRDETECTED       => cfg_dev_status_fatal_err_detected,
    CFGDEVSTATUSNONFATALERRDETECTED    => cfg_dev_status_nonfatal_err_detected,
    CFGDEVSTATUSURDETECTED             => cfg_dev_status_ur_detected,
    CFGDO                              => cfg_do,
    CFGDSN                             => cfg_dsn,
    CFGDWADDR                          => cfg_dwaddr,
    CFGERRCORN                         => cfg_err_cor_n,
    CFGERRCPLABORTN                    => cfg_err_cpl_abort_n,
    CFGERRCPLRDYN                      => cfg_err_cpl_rdy_n,
    CFGERRCPLTIMEOUTN                  => cfg_err_cpl_timeout_n,
    CFGERRECRCN                        => cfg_err_ecrc_n,
    CFGERRLOCKEDN                      => cfg_err_locked_n,
    CFGERRPOSTEDN                      => cfg_err_posted_n,
    CFGERRTLPCPLHEADER                 => cfg_err_tlp_cpl_header,
    CFGERRURN                          => cfg_err_ur_n,
    CFGFUNCTIONNUMBER                  => cfg_function_number,
    CFGINTERRUPTASSERTN                => cfg_interrupt_assert_n,
    CFGINTERRUPTDI                     => cfg_interrupt_di,
    CFGINTERRUPTDO                     => cfg_interrupt_do,
    CFGINTERRUPTMMENABLE               => cfg_interrupt_mmenable,
    CFGINTERRUPTMSIENABLE              => cfg_interrupt_msienable,
    CFGINTERRUPTN                      => cfg_interrupt_n,
    CFGINTERRUPTRDYN                   => cfg_interrupt_rdy_n,
    CFGLINKCONTOLRCB                   => cfg_link_control_rcb,
    CFGLINKCONTROLASPMCONTROL          => cfg_link_control_aspm_control,
    CFGLINKCONTROLCOMMONCLOCK          => cfg_link_control_common_clock,
    CFGLINKCONTROLEXTENDEDSYNC         => cfg_link_control_extended_sync,
    CFGLTSSMSTATE                      => cfg_ltssm_state,
    CFGPCIELINKSTATEN                  => cfg_pcie_link_state_c,
    CFGPMWAKEN                         => cfg_pm_wake_n,
    CFGRDENN                           => cfg_rd_en_n,
    CFGRDWRDONEN                       => cfg_rd_wr_done_n,
    CFGREVID                           => w_cfg_rev_id,
    CFGSUBSYSID                        => w_cfg_subsys_id,
    CFGSUBSYSVENID                     => w_cfg_subsys_ven_id,
    CFGTOTURNOFFN                      => cfg_to_turnoff_n,
    CFGTRNPENDINGN                     => cfg_trn_pending_n,
    CFGTURNOFFOKN                      => cfg_turnoff_ok_n,
    CFGVENID                           => w_cfg_ven_id,
    CLOCKLOCKED                        => clock_locked,
    DBGBADDLLPSTATUS                   => dbg_bad_dllp_status,
    DBGBADTLPLCRC                      => dbg_bad_tlp_lcrc,
    DBGBADTLPSEQNUM                    => dbg_bad_tlp_seq_num,
    DBGBADTLPSTATUS                    => dbg_bad_tlp_status,
    DBGDLPROTOCOLSTATUS                => dbg_dl_protocol_status,
    DBGFCPROTOCOLERRSTATUS             => dbg_fc_protocol_err_status,
    DBGMLFRMDLENGTH                    => dbg_mlfrmd_length,
    DBGMLFRMDMPS                       => dbg_mlfrmd_mps,
    DBGMLFRMDTCVC                      => dbg_mlfrmd_tcvc,
    DBGMLFRMDTLPSTATUS                 => dbg_mlfrmd_tlp_status,
    DBGMLFRMDUNRECTYPE                 => dbg_mlfrmd_unrec_type,
    DBGPOISTLPSTATUS                   => dbg_poistlpstatus,
    DBGRCVROVERFLOWSTATUS              => dbg_rcvr_overflow_status,
    DBGREGDETECTEDCORRECTABLE          => dbg_reg_detected_correctable,
    DBGREGDETECTEDFATAL                => dbg_reg_detected_fatal,
    DBGREGDETECTEDNONFATAL             => dbg_reg_detected_non_fatal,
    DBGREGDETECTEDUNSUPPORTED          => dbg_reg_detected_unsupported,
    DBGRPLYROLLOVERSTATUS              => dbg_rply_rollover_status,
    DBGRPLYTIMEOUTSTATUS               => dbg_rply_timeout_status,
    DBGURNOBARHIT                      => dbg_ur_no_bar_hit,
    DBGURPOISCFGWR                     => dbg_ur_pois_cfg_wr,
    DBGURSTATUS                        => dbg_ur_status,
    DBGURUNSUPMSG                      => dbg_ur_unsup_msg,
    MGTCLK                             => mgt_clk,
    MIMRXRADDR                         => mim_rx_raddr,
    MIMRXRDATA                         => mim_rx_rdata,
    MIMRXREN                           => mim_rx_ren,
    MIMRXWADDR                         => mim_rx_waddr,
    MIMRXWDATA                         => mim_rx_wdata,
    MIMRXWEN                           => mim_rx_wen,
    MIMTXRADDR                         => mim_tx_raddr,
    MIMTXRDATA                         => mim_tx_rdata,
    MIMTXREN                           => mim_tx_ren,
    MIMTXWADDR                         => mim_tx_waddr,
    MIMTXWDATA                         => mim_tx_wdata,
    MIMTXWEN                           => mim_tx_wen,
    PIPEGTPOWERDOWNA                   => pipe_gt_power_down_a,
    PIPEGTPOWERDOWNB                   => pipe_gt_power_down_b,
    PIPEGTRESETDONEA                   => pipe_gt_reset_done_a,
    PIPEGTRESETDONEB                   => pipe_gt_reset_done_b,
    PIPEGTTXELECIDLEA                  => pipe_gt_tx_elec_idle_a,
    PIPEGTTXELECIDLEB                  => pipe_gt_tx_elec_idle_b,
    PIPEPHYSTATUSA                     => pipe_phy_status_a,
    PIPEPHYSTATUSB                     => pipe_phy_status_b,
    PIPERXCHARISKA                     => pipe_rx_charisk_a,
    PIPERXCHARISKB                     => pipe_rx_charisk_b,
    PIPERXDATAA                        => pipe_rx_data_a,
    PIPERXDATAB                        => pipe_rx_data_b,
    PIPERXENTERELECIDLEA               => pipe_rx_enter_elec_idle_a,
    PIPERXENTERELECIDLEB               => pipe_rx_enter_elec_idle_b,
    PIPERXPOLARITYA                    => pipe_rx_polarity_a,
    PIPERXPOLARITYB                    => pipe_rx_polarity_b,
    PIPERXRESETA                       => pipe_rxreset_a,
    PIPERXRESETB                       => pipe_rxreset_b,
    PIPERXSTATUSA                      => pipe_rx_status_a,
    PIPERXSTATUSB                      => pipe_rx_status_b,
    PIPETXCHARDISPMODEA                => pipe_tx_char_disp_mode_a,
    PIPETXCHARDISPMODEB                => pipe_tx_char_disp_mode_b,
    PIPETXCHARDISPVALA                 => pipe_tx_char_disp_val_a,
    PIPETXCHARDISPVALB                 => pipe_tx_char_disp_val_b,
    PIPETXCHARISKA                     => pipe_tx_char_is_k_a,
    PIPETXCHARISKB                     => pipe_tx_char_is_k_b,
    PIPETXDATAA                        => pipe_tx_data_a,
    PIPETXDATAB                        => pipe_tx_data_b,
    PIPETXRCVRDETA                     => pipe_tx_rcvr_det_a,
    PIPETXRCVRDETB                     => pipe_tx_rcvr_det_b,
    RECEIVEDHOTRESET                   => received_hot_reset,
    SYSRESETN                          => sys_reset_n,
    TRNFCCPLD                          => fc_cpld,
    TRNFCCPLH                          => fc_cplh,
    TRNFCNPD                           => fc_npd,
    TRNFCNPH                           => fc_nph,
    TRNFCPD                            => fc_pd,
    TRNFCPH                            => fc_ph,
    TRNFCSEL                           => fc_sel,
    TRNLNKUPN                          => user_lnk_up_w,
    TRNRBARHITN                        => trn_rbar_hit_n,
    TRNRD                              => trn_rd,
    TRNRDSTRDYN                        => trn_rdst_rdy_n,
    TRNREOFN                           => trn_reof_n,
    TRNRERRFWDN                        => trn_rerrfwd_n,
    TRNRNPOKN                          => rx_np_ok_n,
    TRNRSOFN                           => trn_rsof_n,
    TRNRSRCDSCN                        => trn_rsrc_dsc_n,
    TRNRSRCRDYN                        => trn_rsrc_rdy_n,
    TRNTBUFAV                          => tx_buf_av_c,
    TRNTCFGGNTN                        => trn_tcfg_gnt_n,
    TRNTCFGREQN                        => trn_tcfg_req_n,
    TRNTD                              => trn_td,
    TRNTDSTRDYN                        => trn_tdst_rdy_n,
    TRNTEOFN                           => trn_teof_n,
    TRNTERRDROPN                       => trn_terr_drop_n,
    TRNTERRFWDN                        => trn_terrfwd_n,
    TRNTSOFN                           => trn_tsof_n,
    TRNTSRCDSCN                        => trn_tsrc_dsc_n,
    TRNTSRCRDYN                        => trn_tsrc_rdy_n,
    TRNTSTRN                           => trn_tstr_n,
    USERCLK                            => user_clk_out_c,
    USERRSTN                           => user_reset_out_n_w
  );

  axi_basic_top_inst : axi_basic_top
  generic map (
    C_DATA_WIDTH                      => C_DATA_WIDTH,  -- RX/TX interface data width
    C_FAMILY                          => C_FAMILY,      -- Targeted FPGA family
    C_ROOT_PORT                       => C_ROOT_PORT,   -- PCIe block is in root port mode
    C_PM_PRIORITY                     => C_PM_PRIORITY, -- Disable TX packet boundary thrtl
    TCQ                               => 1,             -- Clock to Q time

    C_REM_WIDTH                       => 1,             -- trem/rrem width
    C_STRB_WIDTH                      => 4              -- tkeep width
   )
   port map (
      -----------------------------------------------
      -- User Design I/O
      -----------------------------------------------

      -- AXI TX
      -------------
      s_axis_tx_tdata                 => s_axis_tx_tdata,
      s_axis_tx_tvalid                => s_axis_tx_tvalid,
      s_axis_tx_tready                => s_axis_tx_tready,
      s_axis_tx_tkeep                 => s_axis_tx_tkeep,
      s_axis_tx_tlast                 => s_axis_tx_tlast,
      s_axis_tx_tuser                 => s_axis_tx_tuser,

      -- AXI RX
      -------------
      m_axis_rx_tdata                 => m_axis_rx_tdata,
      m_axis_rx_tvalid                => m_axis_rx_tvalid,
      m_axis_rx_tready                => m_axis_rx_tready,
      m_axis_rx_tkeep                 => m_axis_rx_tkeep,
      m_axis_rx_tlast                 => m_axis_rx_tlast,
      m_axis_rx_tuser                 => m_axis_rx_tuser,

      -- User Misc.
      -------------
      user_turnoff_ok                 => cfg_turnoff_ok,
      user_tcfg_gnt                   => tx_cfg_gnt,

      -----------------------------------------------
      -- PCIe Block I/O
      -----------------------------------------------

      -- TRN TX
      -------------
      trn_td                          => trn_td,
      trn_tsof                        => trn_tsof,
      trn_teof                        => trn_teof,
      trn_tsrc_rdy                    => trn_tsrc_rdy,
      trn_tdst_rdy                    => trn_tdst_rdy,
      trn_tsrc_dsc                    => trn_tsrc_dsc,
      trn_trem                        => OPEN,
      trn_terrfwd                     => trn_terrfwd,
      trn_tstr                        => trn_tstr,
      trn_tbuf_av                     => tx_buf_av_c,
      trn_tecrc_gen                   => OPEN,

      -- TRN RX
      -------------
      trn_rd                          => trn_rd,
      trn_rsof                        => trn_rsof,
      trn_reof                        => trn_reof,
      trn_rsrc_rdy                    => trn_rsrc_rdy,
      trn_rdst_rdy                    => trn_rdst_rdy,
      trn_rsrc_dsc                    => trn_rsrc_dsc,
      trn_rrem                        => (OTHERS=>'1'),
      trn_rerrfwd                     => trn_rerrfwd,
      trn_rbar_hit                    => trn_rbar_hit,
      trn_recrc_err                   => '0',

      -- TRN Misc.
      -------------
      trn_tcfg_req                    => tx_cfg_req_c,
      trn_tcfg_gnt                    => trn_tcfg_gnt,
      trn_lnk_up                      => user_lnk_up_c,

      -- 7 Series/Virtex6 PM
      -------------
      cfg_pcie_link_state             => cfg_pcie_link_state_c,

      -- Virtex6 PM
      -------------
      cfg_pm_send_pme_to              => '0',
      cfg_pmcsr_powerstate            => (OTHERS=>'0'),
      trn_rdllp_data                  => (OTHERS=>'0'),
      trn_rdllp_src_rdy               => '0',

      -- Virtex6/Spartan6 PM
      -------------
      cfg_to_turnoff                  => cfg_to_turnoff_c,
      cfg_turnoff_ok                  => cfg_turnoff_ok_w,

      np_counter                      => OPEN,
      user_clk                        => user_clk_out_c,
      user_rst                        => user_reset_out_c
   );


  ----------------------------------------------------
  -- Recreate wrapper outputs from the PCIE_A1 signals
  ----------------------------------------------------
  cfg_status   <= x"0000";

  cfg_command  <= "00000" &
                  cfg_command_interrupt_disable &
                  "0" &
                  cfg_command_serr_en &
                  "00000" &
                  cfg_command_bus_master_enable &
                  cfg_command_mem_enable &
                  cfg_command_io_enable;

  cfg_dstatus  <= "0000000000" &
                  cfg_trn_pending &
                  '0' &
                  cfg_dev_status_ur_detected &
                  cfg_dev_status_fatal_err_detected &
                  cfg_dev_status_nonfatal_err_detected &
                  cfg_dev_status_corr_err_detected;

  cfg_dcommand <= '0' &
                  cfg_dev_control_max_read_req &
                  cfg_dev_control_no_snoop_en &
                  cfg_dev_control_aux_power_en &
                  cfg_dev_control_phantom_en &
                  cfg_dev_control_ext_tag_en &
                  cfg_dev_control_max_payload &
                  cfg_dev_control_enable_ro &
                  cfg_dev_control_ur_err_reporting_en &
                  cfg_dev_control_fatal_err_reporting_en &
                  cfg_dev_control_non_fatal_reporting_en &
                  cfg_dev_control_corr_err_reporting_en;

  cfg_lstatus  <= x"0011";

  cfg_lcommand <= x"00" &
                  cfg_link_control_extended_sync &
                  cfg_link_control_common_clock &
                  "00" &
                  cfg_link_control_rcb &
                  '0' &
                  cfg_link_control_aspm_control;

end rtl;
