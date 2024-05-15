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
-- File       : xilinx_pcie_1_1_ep_s6.vhd
-- Description: PCI Express Endpoint example FPGA design
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
library unisim;
use unisim.VCOMPONENTS.all;

entity xilinx_pcie_1_1_ep_s6 is
  generic
  (
    FAST_TRAIN                        : boolean    := FALSE
  );
  port
  (
    pci_exp_txp : out std_logic;
    pci_exp_txn : out std_logic;
    pci_exp_rxp : in  std_logic;
    pci_exp_rxn : in  std_logic;

    sys_clk_p   : in  std_logic;
    sys_clk_n   : in  std_logic;
    sys_reset_n : in  std_logic;

    led_0       : out std_logic;
    led_1       : out std_logic;
    led_2       : out std_logic
  );
end xilinx_pcie_1_1_ep_s6;

architecture rtl of xilinx_pcie_1_1_ep_s6 is

  -------------------------
  -- Component declarations
  -------------------------
  component pcie_app_s6 is
  port (
  user_clk               : in  std_logic;
  user_reset             : in  std_logic;
  user_lnk_up            : in  std_logic;

  -- Tx
  tx_buf_av              : in  std_logic_vector(5 downto 0);
  tx_cfg_req             : in  std_logic;
  tx_cfg_gnt             : out std_logic;
  tx_err_drop            : in  std_logic;

  s_axis_tx_tready       : in  std_logic;
  s_axis_tx_tdata        : out std_logic_vector(31 downto 0);
  s_axis_tx_tkeep        : out std_logic_vector(3 downto 0);
  s_axis_tx_tuser        : out std_logic_vector(3 downto 0);
  s_axis_tx_tlast        : out std_logic;
  s_axis_tx_tvalid       : out std_logic;

  --RX
  rx_np_ok               : out std_logic;
  m_axis_rx_tdata        : in std_logic_vector(31 downto 0);
  m_axis_rx_tkeep        : in std_logic_vector(3 downto 0);
  m_axis_rx_tlast        : in  std_logic;
  m_axis_rx_tvalid       : in  std_logic;
  m_axis_rx_tready       : out std_logic;
  m_axis_rx_tuser        : in std_logic_vector(21 downto 0);



  -- Flow Control
  fc_cpld                 : in  std_logic_vector(11 downto 0);
  fc_cplh                 : in  std_logic_vector(7 downto 0);
  fc_npd                  : in  std_logic_vector(11 downto 0);
  fc_nph                  : in  std_logic_vector(7 downto 0);
  fc_pd                   : in  std_logic_vector(11 downto 0);
  fc_ph                   : in  std_logic_vector(7 downto 0);
  fc_sel                  : out std_logic_vector(2 downto 0);

    cfg_do                  : in  std_logic_vector(31 downto 0);
  cfg_rd_wr_done          : in  std_logic;
    cfg_dwaddr              : out std_logic_vector(9 downto 0);
  cfg_rd_en               : out std_logic;

  cfg_err_cor             : out std_logic;
  cfg_err_ur              : out std_logic;
  cfg_err_ecrc            : out std_logic;
  cfg_err_cpl_timeout     : out std_logic;
  cfg_err_cpl_abort       : out std_logic;
  cfg_err_posted          : out std_logic;
  cfg_err_locked          : out std_logic;
    cfg_err_tlp_cpl_header  : out std_logic_vector(47 downto 0);
  cfg_err_cpl_rdy         : in  std_logic;
  cfg_interrupt           : out std_logic;
  cfg_interrupt_rdy       : in  std_logic;
  cfg_interrupt_assert    : out std_logic;
    cfg_interrupt_di        : out std_logic_vector(7 downto 0);
    cfg_interrupt_do        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable  : in  std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : in  std_logic;
  cfg_turnoff_ok          : out std_logic;
  cfg_to_turnoff          : in  std_logic;
  cfg_trn_pending         : out std_logic;
  cfg_pm_wake             : out std_logic;
    cfg_bus_number          : in  std_logic_vector(7 downto 0);
    cfg_device_number       : in  std_logic_vector(4 downto 0);
    cfg_function_number     : in  std_logic_vector(2 downto 0);
    cfg_status              : in  std_logic_vector(15 downto 0);
    cfg_command             : in  std_logic_vector(15 downto 0);
    cfg_dstatus             : in  std_logic_vector(15 downto 0);
    cfg_dcommand            : in  std_logic_vector(15 downto 0);
    cfg_lstatus             : in  std_logic_vector(15 downto 0);
    cfg_lcommand            : in  std_logic_vector(15 downto 0);
  cfg_pcie_link_state     : in  std_logic_vector(2 downto 0);

    cfg_dsn                 : out std_logic_vector(63 downto 0)
  );
  end component pcie_app_s6;

  component s6_pcie_v2_4 is
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
    LL_ACK_TIMEOUT                    : bit_vector := x"00B7";
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
  end component s6_pcie_v2_4;

  ----------------------
  -- Signal declarations
  ----------------------

  -- Common
  signal user_clk                    : std_logic;
  signal user_reset                  : std_logic;
  signal user_lnk_up                 : std_logic;

  -- Tx
  signal tx_buf_av                   : std_logic_vector(5 downto 0);
  signal tx_cfg_req                  : std_logic;
  signal tx_err_drop                 : std_logic;
  signal s_axis_tx_tready            : std_logic;
  signal s_axis_tx_tdata             : std_logic_vector(31 downto 0);
  signal s_axis_tx_tuser             : std_logic_vector(3 downto 0);
  signal s_axis_tx_tlast             : std_logic;
  signal s_axis_tx_tvalid            : std_logic;
  signal tx_cfg_gnt                  : std_logic;
  signal s_axis_tx_tkeep             : std_logic_vector(3 downto 0);

  -- Rx
  signal m_axis_rx_tdata             : std_logic_vector(31 downto 0);
  signal m_axis_rx_tkeep             : std_logic_vector (3 downto 0);
  signal m_axis_rx_tlast             : std_logic;
  signal m_axis_rx_tvalid            : std_logic;
  signal m_axis_rx_tready            : std_logic;
  signal m_axis_rx_tuser             : std_logic_vector(21 downto 0);
  signal rx_np_ok                    : std_logic;

  -- Flow Control
  signal fc_cpld                     : std_logic_vector(11 downto 0);
  signal fc_cplh                     : std_logic_vector(7 downto 0);
  signal fc_npd                      : std_logic_vector(11 downto 0);
  signal fc_nph                      : std_logic_vector(7 downto 0);
  signal fc_pd                       : std_logic_vector(11 downto 0);
  signal fc_ph                       : std_logic_vector(7 downto 0);
  signal fc_sel                      : std_logic_vector(2 downto 0);

  -- Config
  signal cfg_dsn                     : std_logic_vector(63 downto 0);
  signal cfg_do                      : std_logic_vector(31 downto 0);
  signal cfg_rd_wr_done              : std_logic;
  signal cfg_dwaddr                  : std_logic_vector(9 downto 0);
  signal cfg_rd_en                   : std_logic;

  -- Error signaling
  signal cfg_err_cor                 : std_logic;
  signal cfg_err_ur                  : std_logic;
  signal cfg_err_ecrc                : std_logic;
  signal cfg_err_cpl_timeout         : std_logic;
  signal cfg_err_cpl_abort           : std_logic;
  signal cfg_err_posted              : std_logic;
  signal cfg_err_locked              : std_logic;
  signal cfg_err_tlp_cpl_header      : std_logic_vector(47 downto 0);
  signal cfg_err_cpl_rdy             : std_logic;

  -- Interrupt signaling
  signal cfg_interrupt               : std_logic;
  signal cfg_interrupt_rdy           : std_logic;
  signal cfg_interrupt_assert        : std_logic;
  signal cfg_interrupt_di            : std_logic_vector(7 downto 0);
  signal cfg_interrupt_do            : std_logic_vector(7 downto 0);
  signal cfg_interrupt_mmenable      : std_logic_vector(2 downto 0);
  signal cfg_interrupt_msienable     : std_logic;

  -- Power management signaling
  signal cfg_turnoff_ok              : std_logic;
  signal cfg_to_turnoff              : std_logic;
  signal cfg_trn_pending             : std_logic;
  signal cfg_pm_wake                 : std_logic;

  -- System configuration and status
  signal cfg_bus_number              : std_logic_vector(7 downto 0);
  signal cfg_device_number           : std_logic_vector(4 downto 0);
  signal cfg_function_number         : std_logic_vector(2 downto 0);
  signal cfg_status                  : std_logic_vector(15 downto 0);
  signal cfg_command                 : std_logic_vector(15 downto 0);
  signal cfg_dstatus                 : std_logic_vector(15 downto 0);
  signal cfg_dcommand                : std_logic_vector(15 downto 0);
  signal cfg_lstatus                 : std_logic_vector(15 downto 0);
  signal cfg_lcommand                : std_logic_vector(15 downto 0);
  signal cfg_pcie_link_state         : std_logic_vector(2 downto 0);

  -- System (SYS) Interface
  signal sys_clk_c                   : std_logic;
  signal sys_reset_n_c               : std_logic;
  signal sys_reset                   : std_logic;

begin
  ---------------------------------------------------------
  -- Clock Input Buffer for differential system clock
  ---------------------------------------------------------
  refclk_ibuf : IBUFDS
  port map
  (
    O  => sys_clk_c,
    I  => sys_clk_p,
    IB => sys_clk_n
  );

  ---------------------------------------------------------
  -- Input buffer for system reset signal
  ---------------------------------------------------------
  sys_reset_n_ibuf : IBUF
  port map
  (
    O  => sys_reset_n_c,
    I  => sys_reset_n
  );

  sys_reset <= not sys_reset_n_c;

  ---------------------------------------------------------
  -- Output buffers for diagnostic LEDs
  ---------------------------------------------------------
  led_0_obuf : OBUF
  port map
  (
    O =>  led_0,
    I =>  sys_reset_n_c
  );
  led_1_obuf : OBUF
  port map
  (
    O =>  led_1,
    I =>  user_reset
  );
  led_2_obuf : OBUF
  port map
  (
    O =>  led_2,
    I =>  user_lnk_up
  );

  ---------------------------------------------------------
  -- User application
  ---------------------------------------------------------
  app : pcie_app_s6
  port map
  (
    -- Transaction (TRN) Interface
    -- Common lock & reset
    user_clk                           => user_clk,
    user_reset                         => user_reset,
    user_lnk_up                        => user_lnk_up,
    -- Common flow control
    fc_cpld                            => fc_cpld,
    fc_cplh                            => fc_cplh,
    fc_npd                             => fc_npd,
    fc_nph                             => fc_nph,
    fc_pd                              => fc_pd,
    fc_ph                              => fc_ph,
    fc_sel                             => fc_sel,
    -- Transaction Tx
    tx_buf_av                          => tx_buf_av,
    tx_cfg_req                         => tx_cfg_req,
    tx_err_drop                        => tx_err_drop,
    s_axis_tx_tready                   => s_axis_tx_tready,
    s_axis_tx_tdata                    => s_axis_tx_tdata,
    s_axis_tx_tkeep                    => s_axis_tx_tkeep,
    s_axis_tx_tuser                    => s_axis_tx_tuser,
    s_axis_tx_tlast                    => s_axis_tx_tlast,
    s_axis_tx_tvalid                   => s_axis_tx_tvalid,
    tx_cfg_gnt                         => tx_cfg_gnt,
    -- Transaction Rx
    m_axis_rx_tdata                    => m_axis_rx_tdata,
    m_axis_rx_tkeep                    => m_axis_rx_tkeep,
    m_axis_rx_tlast                    => m_axis_rx_tlast,
    m_axis_rx_tvalid                   => m_axis_rx_tvalid,
    m_axis_rx_tready                   => m_axis_rx_tready,
    m_axis_rx_tuser                    => m_axis_rx_tuser,
    rx_np_ok                           => rx_np_ok,

    -- Configuration (CFG) Interface
    -- Configuration space access
    cfg_do                             => cfg_do,
    cfg_rd_wr_done                     => cfg_rd_wr_done,
    cfg_dwaddr                         => cfg_dwaddr,
    cfg_rd_en                          => cfg_rd_en,
    -- Error signaling
    cfg_err_cor                        => cfg_err_cor,
    cfg_err_ur                         => cfg_err_ur,
    cfg_err_ecrc                       => cfg_err_ecrc,
    cfg_err_cpl_timeout                => cfg_err_cpl_timeout,
    cfg_err_cpl_abort                  => cfg_err_cpl_abort,
    cfg_err_posted                     => cfg_err_posted,
    cfg_err_locked                     => cfg_err_locked,
    cfg_err_tlp_cpl_header             => cfg_err_tlp_cpl_header,
    cfg_err_cpl_rdy                    => cfg_err_cpl_rdy,
    -- Interrupt generation
    cfg_interrupt                      => cfg_interrupt,
    cfg_interrupt_rdy                  => cfg_interrupt_rdy,
    cfg_interrupt_assert               => cfg_interrupt_assert,
    cfg_interrupt_di                   => cfg_interrupt_di,
    cfg_interrupt_do                   => cfg_interrupt_do,
    cfg_interrupt_mmenable             => cfg_interrupt_mmenable,
    cfg_interrupt_msienable            => cfg_interrupt_msienable,
    -- Power managemnt signaling
    cfg_turnoff_ok                     => cfg_turnoff_ok,
    cfg_to_turnoff                     => cfg_to_turnoff ,
    cfg_trn_pending                    => cfg_trn_pending ,
    cfg_pm_wake                        => cfg_pm_wake ,
    -- System configuration and status
    cfg_bus_number                     => cfg_bus_number,
    cfg_device_number                  => cfg_device_number,
    cfg_function_number                => cfg_function_number,
    cfg_status                         => cfg_status,
    cfg_command                        => cfg_command,
    cfg_dstatus                        => cfg_dstatus,
    cfg_dcommand                       => cfg_dcommand,
    cfg_lstatus                        => cfg_lstatus,
    cfg_lcommand                       => cfg_lcommand,
    cfg_pcie_link_state                => cfg_pcie_link_state,
    cfg_dsn                            => cfg_dsn
  );

  s6_pcie_v2_4_i : s6_pcie_v2_4  generic map
  (
    FAST_TRAIN                        => FAST_TRAIN
  )
  port map (
    -- PCI Express (PCI_EXP) Fabric Interface
    pci_exp_txp                        => pci_exp_txp,
    pci_exp_txn                        => pci_exp_txn,
    pci_exp_rxp                        => pci_exp_rxp,
    pci_exp_rxn                        => pci_exp_rxn,

    -- Transaction (TRN) Interface
    -- Common clock & reset
    user_lnk_up                        => user_lnk_up,
    user_clk_out                       => user_clk,
    user_reset_out                     => user_reset,
    -- Common flow control
    fc_sel                             => fc_sel,
    fc_nph                             => fc_nph,
    fc_npd                             => fc_npd,
    fc_ph                              => fc_ph,
    fc_pd                              => fc_pd,
    fc_cplh                            => fc_cplh,
    fc_cpld                            => fc_cpld,
    -- Transaction Tx
    s_axis_tx_tready                    => s_axis_tx_tready,
    s_axis_tx_tdata                     => s_axis_tx_tdata,
    s_axis_tx_tkeep                     => s_axis_tx_tkeep,
    s_axis_tx_tuser                     => s_axis_tx_tuser,
    s_axis_tx_tlast                     => s_axis_tx_tlast,
    s_axis_tx_tvalid                    => s_axis_tx_tvalid,
    tx_err_drop                         => tx_err_drop,
    tx_buf_av                           => tx_buf_av,
    tx_cfg_req                          => tx_cfg_req,
    tx_cfg_gnt                          => tx_cfg_gnt,
    -- Transaction Rx
    m_axis_rx_tdata                     => m_axis_rx_tdata,
    m_axis_rx_tkeep                     => m_axis_rx_tkeep,
    m_axis_rx_tlast                     => m_axis_rx_tlast,
    m_axis_rx_tvalid                    => m_axis_rx_tvalid,
    m_axis_rx_tready                    => m_axis_rx_tready,
    m_axis_rx_tuser                     => m_axis_rx_tuser,
    rx_np_ok                            => rx_np_ok,

    -- Configuration (CFG) Interface
    -- Configuration space access
    cfg_do                             => cfg_do,
    cfg_rd_wr_done                     => cfg_rd_wr_done,
    cfg_dwaddr                         => cfg_dwaddr,
    cfg_rd_en                          => cfg_rd_en,
    -- Error reporting
    cfg_err_ur                         => cfg_err_ur,
    cfg_err_cor                        => cfg_err_cor,
    cfg_err_ecrc                       => cfg_err_ecrc,
    cfg_err_cpl_timeout                => cfg_err_cpl_timeout,
    cfg_err_cpl_abort                  => cfg_err_cpl_abort,
    cfg_err_posted                     => cfg_err_posted,
    cfg_err_locked                     => cfg_err_locked,
    cfg_err_tlp_cpl_header             => cfg_err_tlp_cpl_header,
    cfg_err_cpl_rdy                    => cfg_err_cpl_rdy,
    -- Interrupt generation
    cfg_interrupt                      => cfg_interrupt,
    cfg_interrupt_rdy                  => cfg_interrupt_rdy,
    cfg_interrupt_assert               => cfg_interrupt_assert,
    cfg_interrupt_do                   => cfg_interrupt_do,
    cfg_interrupt_di                   => cfg_interrupt_di,
    cfg_interrupt_mmenable             => cfg_interrupt_mmenable,
    cfg_interrupt_msienable            => cfg_interrupt_msienable,
    -- Power management signaling
    cfg_turnoff_ok                     => cfg_turnoff_ok,
    cfg_to_turnoff                     => cfg_to_turnoff,
    cfg_pm_wake                        => cfg_pm_wake,
    cfg_pcie_link_state                => cfg_pcie_link_state,
    cfg_trn_pending                    => cfg_trn_pending,
    -- System configuration and status
    cfg_dsn                            => cfg_dsn,
    cfg_bus_number                     => cfg_bus_number,
    cfg_device_number                  => cfg_device_number,
    cfg_function_number                => cfg_function_number,
    cfg_status                         => cfg_status,
    cfg_command                        => cfg_command,
    cfg_dstatus                        => cfg_dstatus,
    cfg_dcommand                       => cfg_dcommand,
    cfg_lstatus                        => cfg_lstatus,
    cfg_lcommand                       => cfg_lcommand,

    -- System (SYS) Interface
    sys_clk                            => sys_clk_c,
    sys_reset                          => sys_reset,
    received_hot_reset                 => OPEN
  );

end rtl;
