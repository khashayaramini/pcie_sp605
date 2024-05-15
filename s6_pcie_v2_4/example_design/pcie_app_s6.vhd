-------------------------------------------------------------------------------
--
-- (c) Copyright 2001, 2002, 2003, 2004, 2005, 2007, 2008, 2009 Xilinx, Inc. All rights reserved.
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
-- File       : pcie_app_s6.vhd
-- Description: PCI Express Endpoint sample application design.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pcie_app_s6 is
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
  cfg_bus_number            : in  std_logic_vector(7 downto 0);
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
end pcie_app_s6;

architecture rtl of pcie_app_s6 is

  component PIO is
  port (
  user_clk                : in  std_logic;
  user_reset            : in  std_logic;
  user_lnk_up           : in  std_logic;

  -- AXIS TX
  s_axis_tx_tready       : in  std_logic;
  s_axis_tx_tdata        : out std_logic_vector(31 downto 0);
  s_axis_tx_tkeep        : out std_logic_vector(3 downto 0);
  s_axis_tx_tlast        : out std_logic;
  s_axis_tx_tvalid       : out std_logic;
  tx_src_dsc             : out std_logic;

  -- AXIS RX
  m_axis_rx_tdata        : in std_logic_vector(31 downto 0);
  m_axis_rx_tkeep        : in std_logic_vector(3 downto 0);
  m_axis_rx_tlast        : in std_logic;
  m_axis_rx_tvalid       : in std_logic;
  m_axis_rx_tready       : out std_logic;
  m_axis_rx_tuser        : in std_logic_vector(21 downto 0);

  cfg_to_turnoff         : in  std_logic;
  cfg_turnoff_ok         : out std_logic;

  cfg_completer_id       : in  std_logic_vector(15 downto 0);
  cfg_bus_mstr_enable    : in  std_logic
);
  end component PIO;

  constant PCI_EXP_EP_OUI      : std_logic_vector(23 downto 0) := x"000A35";
  constant PCI_EXP_EP_DSN_1    : std_logic_vector(31 downto 0) := x"01" & PCI_EXP_EP_OUI;
  constant PCI_EXP_EP_DSN_2    : std_logic_vector(31 downto 0) := x"00000001";

  signal   cfg_completer_id    : std_logic_vector(15 downto 0);
  signal   cfg_bus_mstr_enable : std_logic;

begin

  --
  -- Core input tie-offs
  --

  fc_sel             <= "000";

  rx_np_ok           <= '1';

  tx_cfg_gnt         <= '1';

  cfg_err_cor          <= '0';
  cfg_err_ur           <= '0';
  cfg_err_ecrc         <= '0';
  cfg_err_cpl_timeout  <= '0';
  cfg_err_cpl_abort    <= '0';
  cfg_err_posted       <= '0';
  cfg_err_locked       <= '0';
  cfg_pm_wake          <= '0';
  cfg_trn_pending      <= '0';

  s_axis_tx_tuser(0)   <= '0'; -- Unused for S6
  s_axis_tx_tuser(1)   <= '0'; -- Error forward packet
  s_axis_tx_tuser(2)   <= '0'; -- Stream packet

  cfg_interrupt_assert <= '0';
  cfg_interrupt        <= '0';
  cfg_interrupt_di     <= x"00";

  cfg_err_tlp_cpl_header <= (OTHERS => '0');
  cfg_dwaddr             <= (OTHERS => '0');
  cfg_rd_en            <= '0';
  cfg_dsn                <= PCI_EXP_EP_DSN_2 & PCI_EXP_EP_DSN_1;

  --
  -- Programmed I/O Module
  --

  cfg_completer_id       <= cfg_bus_number & cfg_device_number & cfg_function_number;
  cfg_bus_mstr_enable    <= cfg_command(2);

  PIO_i : PIO
  port map (
    user_clk           => user_clk,            -- I
    user_reset         => user_reset,        -- I
    user_lnk_up        => user_lnk_up,       -- I

    s_axis_tx_tready  => s_axis_tx_tready ,       -- I
    s_axis_tx_tdata   => s_axis_tx_tdata ,        -- O
    s_axis_tx_tkeep   => s_axis_tx_tkeep ,        -- O
    s_axis_tx_tlast   => s_axis_tx_tlast ,        -- O
    s_axis_tx_tvalid  => s_axis_tx_tvalid ,       -- O
    tx_src_dsc        => s_axis_tx_tuser(3) ,     -- O

    m_axis_rx_tdata   => m_axis_rx_tdata ,        -- I
    m_axis_rx_tkeep   => m_axis_rx_tkeep ,        -- I
    m_axis_rx_tlast   => m_axis_rx_tlast ,        -- I
    m_axis_rx_tvalid  => m_axis_rx_tvalid ,       -- I
    m_axis_rx_tready  => m_axis_rx_tready ,       -- O
    m_axis_rx_tuser   => m_axis_rx_tuser ,        -- I

    cfg_to_turnoff    => cfg_to_turnoff,   -- I
    cfg_turnoff_ok    => cfg_turnoff_ok,   -- O

    cfg_completer_id    => cfg_completer_id,   -- I [15:0]
    cfg_bus_mstr_enable => cfg_bus_mstr_enable -- I
  );

end rtl;



