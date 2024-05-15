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
-- File       : PIO_32_RX_ENGINE.vhd
-- Description: 32-bit Local-Link Receive Unit.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity PIO_32_RX_ENGINE is
port (
  clk                   : in  std_logic;
  rst_n                 : in  std_logic;

  --
  -- Receive AXI-S interface from PCIe core
  --
  m_axis_rx_tdata       : in  std_logic_vector(31 downto 0);
  m_axis_rx_tkeep       : in  std_logic_vector(3 downto 0);
  m_axis_rx_tlast       : in  std_logic;
  m_axis_rx_tvalid      : in  std_logic;
  m_axis_rx_tready      : out std_logic;
  m_axis_rx_tuser       : in  std_logic_vector(21 downto 0);

  --
  -- Memory Read data handshake with Completion
  -- transmit unit. Transmit unit reponds to
  -- req_compl assertion and responds with compl_done
  -- assertion when a Completion w/ data is transmitted.
  --
  req_compl_o           : out std_logic;
  req_compl_with_data_o : out std_logic;
  compl_done_i          : in  std_logic;

  req_tc_o              : out std_logic_vector(2 downto 0);  -- Memory Read TC
  req_td_o              : out std_logic;                     -- Memory Read TD
  req_ep_o              : out std_logic;                     -- Memory Read EP
  req_attr_o            : out std_logic_vector(1 downto 0);  -- Memory Read Attribute
  req_len_o             : out std_logic_vector(9 downto 0);  -- Memory Read Length (1DW)
  req_rid_o             : out std_logic_vector(15 downto 0); -- Memory Read Requestor ID
  req_tag_o             : out std_logic_vector(7 downto 0);  -- Memory Read Tag
  req_be_o              : out std_logic_vector(7 downto 0);  -- Memory Read Byte Enables
  req_addr_o            : out std_logic_vector(12 downto 0); -- Memory Read Address

  --
  -- Memory interface used to save 1 DW data received
  -- on Memory Write 32 TLP. Data extracted from
  -- inbound TLP is presented to the Endpoint memory
  -- unit. Endpoint memory unit reacts to wr_en_o
  -- assertion and asserts wr_busy_i when it is
  -- processing written information.
  --
  wr_addr_o             : out std_logic_vector(10 downto 0); -- Memory Write Address
  wr_be_o               : out std_logic_vector(7 downto 0);  -- Memory Write Byte Enable
  wr_data_o             : out std_logic_vector(31 downto 0); -- Memory Write Data
  wr_en_o               : out std_logic;                     -- Memory Write Enable
  wr_busy_i             : in std_logic                       -- Memory Write Busy
);
end PIO_32_RX_ENGINE;

architecture rtl of PIO_32_RX_ENGINE is

  -- Clock-to-out delay
  constant TCQ : time := 1 ns;

  -- TLP Header format/type values
  constant PIO_32_RX_MEM_RD32_FMT_TYPE : std_logic_vector(6 downto 0) := "0000000";
  constant PIO_32_RX_MEM_WR32_FMT_TYPE : std_logic_vector(6 downto 0) := "1000000";
  constant PIO_32_RX_MEM_RD64_FMT_TYPE : std_logic_vector(6 downto 0) := "0100000";
  constant PIO_32_RX_MEM_WR64_FMT_TYPE : std_logic_vector(6 downto 0) := "1100000";
  constant PIO_32_RX_IO_RD32_FMT_TYPE  : std_logic_vector(6 downto 0) := "0000010";
  constant PIO_32_RX_IO_WR32_FMT_TYPE  : std_logic_vector(6 downto 0) := "1000010";

  -- States
  type state_type is (
    PIO_32_RX_PRE_RST_STATE,
	 PIO_32_RX_PRE_RST_STATE2,
	 PIO_32_RX_PRE_RST_STATE3,
	 PIO_32_RX_RST_STATE,
    PIO_32_RX_MEM_RD32_DW1,
    PIO_32_RX_MEM_RD32_DW2,
    PIO_32_RX_IO_MEM_WR32_DW1,
    PIO_32_RX_IO_MEM_WR32_DW2,
    PIO_32_RX_IO_MEM_WR32_DW3,
    PIO_32_RX_IO_MEM_WR32_DW4,
    PIO_32_RX_MEM_RD64_DW1,
    PIO_32_RX_MEM_RD64_DW2,
    PIO_32_RX_MEM_RD64_DW3,
    PIO_32_RX_MEM_WR64_DW1,
    PIO_32_RX_MEM_WR64_DW2,
    PIO_32_RX_MEM_WR64_DW3,
    PIO_32_RX_MEM_WR64_DW4,
    PIO_32_RX_WAIT_STATE
  );

  signal state              : state_type;
  signal tlp_type           : std_logic_vector(6 downto 0);

  signal m_axis_rx_tready_int : std_logic;

  signal io_bar_hit_n       : std_logic;
  signal mem32_bar_hit_n    : std_logic;
  signal mem64_bar_hit_n    : std_logic;
  signal erom_bar_hit_n     : std_logic;
  signal bar_hit_select     : std_logic_vector(3 downto 0);

  signal region_select      : std_logic_vector(1 downto 0);

  signal in_packet_q        : std_logic;
  signal sop                : std_logic;

begin

  m_axis_rx_tready <= m_axis_rx_tready_int;

  -- Create logic to determine when a packet starts
  sop <= not(in_packet_q) and m_axis_rx_tvalid;

  process begin
    wait until rising_edge(clk);
    if (rst_n = '0') then
      in_packet_q    <= '0' after TCQ;
    elsif (m_axis_rx_tvalid = '1' and m_axis_rx_tready_int = '1' and m_axis_rx_tlast = '1') then
      in_packet_q    <= '0' after TCQ;
    elsif (sop = '1' and m_axis_rx_tready_int = '1') then
      in_packet_q    <= '1' after TCQ;
    end if;
  end process;


  -- RX receiver state machine and logic
  process begin
    wait until rising_edge(clk);
    if (rst_n = '0') then
      m_axis_rx_tready_int  <= '0' after TCQ;

      req_compl_o           <= '0' after TCQ;
      req_compl_with_data_o <= '1' after TCQ;

      req_tc_o              <= (others => '0') after TCQ;
      req_td_o              <= '0' after TCQ;
      req_ep_o              <= '0' after TCQ;
      req_attr_o            <= (others => '0') after TCQ;
      req_len_o             <= (others => '0') after TCQ;
      req_rid_o             <= (others => '0') after TCQ;
      req_tag_o             <= (others => '0') after TCQ;
      req_be_o              <= (others => '0') after TCQ;
      req_addr_o            <= (others => '0') after TCQ;

      wr_be_o               <= (others => '0') after TCQ;
      wr_addr_o             <= (others => '0') after TCQ;
      wr_data_o             <= (others => '0') after TCQ;
      wr_en_o               <= '0' after TCQ;

      state                 <= PIO_32_RX_RST_STATE after TCQ;
      tlp_type              <= (others => '0') after TCQ;
    else
      wr_en_o                  <= '0' after TCQ;
      req_compl_o              <= '0' after TCQ;
      req_compl_with_data_o    <= '1' after TCQ;

      case (state) is
--			when PIO_32_RX_RST_STATE =>
--						wr_addr_o <= "00000000000";
--						--wr_data_o <= std_logic_vector(to_unsigned(counter, 32));
--						wr_data_o <= X"A0A0A0A0";
--						wr_be_o <= (others => '1');
--						wr_en_o <= '1';
--						state <= PIO_32_RX_PRE_RST_STATE2 after TCQ;
--						
--			when PIO_32_RX_PRE_RST_STATE2 =>
--				if wr_busy_i = '0' then
--					wr_en_o <= '0';
--					state <= PIO_32_RX_PRE_RST_STATE3 after TCQ;
--				else
--					state <= PIO_32_RX_PRE_RST_STATE2 after TCQ;
--				end if;
				
        when PIO_32_RX_RST_STATE =>
          m_axis_rx_tready_int <= '1' after TCQ;
          tlp_type           <= m_axis_rx_tdata(30 downto 24) after TCQ;
          req_tc_o           <= m_axis_rx_tdata(22 downto 20) after TCQ;
          req_td_o           <= m_axis_rx_tdata(15) after TCQ;
          req_ep_o           <= m_axis_rx_tdata(14) after TCQ;
          req_attr_o         <= m_axis_rx_tdata(13 downto 12) after TCQ;
          req_len_o          <= m_axis_rx_tdata(9 downto 0) after TCQ;

          if ((sop = '1') and (m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            case (m_axis_rx_tdata(30 downto 24)) is
              when PIO_32_RX_MEM_RD32_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_MEM_RD32_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when PIO_32_RX_MEM_WR32_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_IO_MEM_WR32_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when PIO_32_RX_MEM_RD64_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_MEM_RD64_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when PIO_32_RX_MEM_WR64_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_MEM_WR64_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when PIO_32_RX_IO_RD32_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_MEM_RD32_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when PIO_32_RX_IO_WR32_FMT_TYPE =>
                if (m_axis_rx_tdata(9 downto 0) = "0000000001") then
                  state        <= PIO_32_RX_IO_MEM_WR32_DW1 after TCQ;
                else
                  state        <= PIO_32_RX_RST_STATE after TCQ;
                end if;

              when others => -- other TLPs
                  state        <= PIO_32_RX_RST_STATE after TCQ;
            end case; -- m_axis_rx_tdata(30 downto 24)
          else -- ((trn_rsof_n = '0') and (trn_rsrc_rdy_n = '0') and (trn_rdst_rdy_n_int = '0'))
            state <= PIO_32_RX_RST_STATE after TCQ;
          end if;
        -- end of PIO_32_RX_RST_STATE

        when PIO_32_RX_MEM_RD32_DW1 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int ='1')) then
            req_rid_o    <= m_axis_rx_tdata(31 downto 16) after TCQ;
            req_tag_o    <= m_axis_rx_tdata(15 downto 8) after TCQ;
            req_be_o     <= m_axis_rx_tdata(7 downto 0) after TCQ;
            state        <= PIO_32_RX_MEM_RD32_DW2 after TCQ;
          else
            state        <= PIO_32_RX_MEM_RD32_DW1 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_RD32_DW1

        when PIO_32_RX_MEM_RD32_DW2 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            req_addr_o         <= region_select(1 downto 0) & m_axis_rx_tdata(10 downto 2) & "00" after TCQ;
            req_compl_o        <= '1' after TCQ;
            m_axis_rx_tready_int <= '0' after TCQ;
            state              <= PIO_32_RX_WAIT_STATE after TCQ;
          else
            state              <= PIO_32_RX_MEM_RD32_DW2 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_RD32_DW2

        when PIO_32_RX_IO_MEM_WR32_DW1 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            req_rid_o    <= m_axis_rx_tdata(31 downto 16) after TCQ;
            req_tag_o    <= m_axis_rx_tdata(15 downto 8) after TCQ;
            wr_be_o      <= m_axis_rx_tdata(7 downto 0) after TCQ;
            state        <= PIO_32_RX_IO_MEM_WR32_DW2 after TCQ;
          else
            state        <= PIO_32_RX_IO_MEM_WR32_DW1 after TCQ;
          end if;
        -- end of PIO_32_RX_IO_MEM_WR32_DW1

        when PIO_32_RX_IO_MEM_WR32_DW2 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            wr_addr_o    <= region_select(1 downto 0) & m_axis_rx_tdata(10 downto 2) after TCQ;
            state        <= PIO_32_RX_IO_MEM_WR32_DW3 after TCQ;
          else
            state        <= PIO_32_RX_IO_MEM_WR32_DW2 after TCQ;
          end if;
        -- end of PIO_32_RX_IO_MEM_WR32_DW2

        when PIO_32_RX_IO_MEM_WR32_DW3 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            wr_data_o             <= m_axis_rx_tdata(31 downto 0) after TCQ;
            wr_en_o               <= '1' after TCQ;
            if (tlp_type = PIO_32_RX_IO_WR32_FMT_TYPE) then
              req_compl_o         <= '1' after TCQ;
            else
              req_compl_o         <= '0' after TCQ;
            end if;
            req_compl_with_data_o <= '0' after TCQ;
            m_axis_rx_tready_int    <= '0' after TCQ;
            state                 <= PIO_32_RX_WAIT_STATE after TCQ;

          else
            state                 <= PIO_32_RX_IO_MEM_WR32_DW3 after TCQ;
          end if;
        -- end of PIO_32_RX_IO_MEM_WR32_DW3

        when PIO_32_RX_MEM_RD64_DW1 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int ='1')) then
            req_rid_o    <= m_axis_rx_tdata(31 downto 16) after TCQ;
            req_tag_o    <= m_axis_rx_tdata(15 downto 8) after TCQ;
            req_be_o     <= m_axis_rx_tdata(7 downto 0) after TCQ;
            state        <= PIO_32_RX_MEM_RD64_DW2 after TCQ;
          else
            state        <= PIO_32_RX_MEM_RD64_DW1 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_RD64_DW1

        when PIO_32_RX_MEM_RD64_DW2 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            state        <= PIO_32_RX_MEM_RD64_DW3 after TCQ;
          else
            state        <= PIO_32_RX_MEM_RD64_DW2 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_RD64_DW2

        when PIO_32_RX_MEM_RD64_DW3 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            req_addr_o         <= region_select(1 downto 0) & m_axis_rx_tdata(10 downto 2) & "00" after TCQ;
            req_compl_o        <= '1' after TCQ;
            m_axis_rx_tready_int <= '0' after TCQ;
            state              <= PIO_32_RX_WAIT_STATE after TCQ;
          else
            state              <= PIO_32_RX_MEM_RD64_DW3 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_RD64_DW3

        when PIO_32_RX_MEM_WR64_DW1 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            wr_be_o      <= m_axis_rx_tdata(7 downto 0) after TCQ;
            state        <= PIO_32_RX_MEM_WR64_DW2 after TCQ;
          else
            state        <= PIO_32_RX_MEM_WR64_DW1 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_WR64_DW1

        when PIO_32_RX_MEM_WR64_DW2 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            state        <= PIO_32_RX_MEM_WR64_DW3 after TCQ;
          else
            state        <= PIO_32_RX_MEM_WR64_DW2 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_WR64_DW2

        when PIO_32_RX_MEM_WR64_DW3 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            wr_addr_o  <= region_select(1 downto 0) & m_axis_rx_tdata(10 downto 2) after TCQ;
            state      <= PIO_32_RX_MEM_WR64_DW4 after TCQ;
          else
            state      <= PIO_32_RX_MEM_WR64_DW3 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_WR64_DW3

        when PIO_32_RX_MEM_WR64_DW4 =>
          if ((m_axis_rx_tvalid = '1') and (m_axis_rx_tready_int = '1')) then
            wr_data_o          <= m_axis_rx_tdata(31 downto 0) after TCQ;
            wr_en_o            <= '1' after TCQ;
            m_axis_rx_tready_int <= '0' after TCQ;
            state              <= PIO_32_RX_WAIT_STATE after TCQ;
          else
            state              <= PIO_32_RX_MEM_WR64_DW4 after TCQ;
          end if;
        -- end of PIO_32_RX_MEM_WR64_DW4

        when PIO_32_RX_WAIT_STATE =>
          wr_en_o              <= '0' after TCQ;
          req_compl_o          <= '0' after TCQ;
          if ((tlp_type = PIO_32_RX_MEM_WR32_FMT_TYPE) and (wr_busy_i = '0')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          elsif ((tlp_type = PIO_32_RX_IO_WR32_FMT_TYPE) and (wr_busy_i = '0')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          elsif ((tlp_type = PIO_32_RX_MEM_WR64_FMT_TYPE) and (wr_busy_i = '0')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          elsif ((tlp_type = PIO_32_RX_MEM_RD32_FMT_TYPE) and (compl_done_i = '1')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          elsif ((tlp_type = PIO_32_RX_IO_RD32_FMT_TYPE) and (compl_done_i = '1')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          elsif ((tlp_type = PIO_32_RX_MEM_RD64_FMT_TYPE) and (compl_done_i = '1')) then
            m_axis_rx_tready_int <= '1' after TCQ;
            state              <= PIO_32_RX_RST_STATE after TCQ;
          else
            state              <= PIO_32_RX_WAIT_STATE after TCQ;
          end if;
        -- end of PIO_32_RX_WAIT_STATE

        when others =>
          state <= PIO_32_RX_WAIT_STATE after TCQ;
      end  case;
    end if;
  end process;

  mem64_bar_hit_n <= '1';
  io_bar_hit_n    <= '1';
  mem32_bar_hit_n <= not(m_axis_rx_tuser(2));
  erom_bar_hit_n  <= not(m_axis_rx_tuser(8));
  bar_hit_select  <= io_bar_hit_n & mem32_bar_hit_n & mem64_bar_hit_n & erom_bar_hit_n;

  process (bar_hit_select) begin
    case (bar_hit_select) is
      when "0111" =>
        region_select <= "00";
      when "1011" =>
        region_select <= "01";
      when "1101" =>
        region_select <= "10";
      when "1110" =>
        region_select <= "11";
      when others =>
        region_select <= "00";
    end  case;
  end process;
--  region_select <= "00";
--   process(clk)
--		variable counter: integer range 0 to 500000000 := 0;
--		variable time_counter: integer range 0 to 500000000 := 0;
--		variable was_enabled: std_logic := '0';
--		
--		begin
--			if rising_edge(clk) then
--				time_counter := time_counter + 1;
--				if time_counter > 10000000 then
--					counter := counter + 1;
--					time_counter := 0;
--					if wr_busy_i = '0' and was_enabled = '0' then
--						wr_addr_o <= "00000000011";
--						--wr_data_o <= std_logic_vector(to_unsigned(counter, 32));
--						wr_data_o <= X"A0A0A0A0";
--						wr_be_o <= (others => '1');
--						wr_en_o <= '1';
--						was_enabled := '1';
--					end if;
--				else
--					if wr_busy_i = '0' and was_enabled = '1' then
--						wr_en_o <= '0';
--						was_enabled := '0';
--					end if;
--				end if;
--			end if;	
--		end process;

end; -- PIO_32_RX_ENGINE

