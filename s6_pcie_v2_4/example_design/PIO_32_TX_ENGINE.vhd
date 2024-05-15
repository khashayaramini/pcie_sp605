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
-- File       : PIO_32_TX_ENGINE.vhd
-- Description: 32 bit LocalLink Transmit Unit.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PIO_32_TX_ENGINE is
port (
  clk                   : in  std_logic;
  rst_n                 : in  std_logic;


  -- AXIS
  s_axis_tx_tready      : in  std_logic;
  s_axis_tx_tdata       : out  std_logic_vector(31 downto 0);
  s_axis_tx_tkeep       : out std_logic_vector(3 downto 0);
  s_axis_tx_tlast       : out std_logic;
  s_axis_tx_tvalid      : out std_logic;
  tx_src_dsc            : out std_logic;

  req_compl_i           : in  std_logic;
  req_compl_with_data_i : in  std_logic;
  compl_done_o          : out  std_logic;

  req_tc_i              : in std_logic_vector(2 downto 0);
  req_td_i              : in  std_logic;
  req_ep_i              : in  std_logic;
  req_attr_i            : in std_logic_vector(1 downto 0);
  req_len_i             : in std_logic_vector(9 downto 0);
  req_rid_i             : in std_logic_vector(15 downto 0);
  req_tag_i             : in std_logic_vector(7 downto 0);
  req_be_i              : in std_logic_vector(7 downto 0);
  req_addr_i            :in std_logic_vector(12 downto 0);

  rd_addr_o             :out std_logic_vector(10 downto 0);
  rd_be_o               :out std_logic_vector(3 downto 0);
  rd_data_i             :in std_logic_vector(31 downto 0);

  completer_id_i        :in std_logic_vector(15 downto 0);
  cfg_bus_mstr_enable_i : in  std_logic


);
end pio_32_tx_engine;

architecture rtl of pio_32_tx_engine is

  -- Clock-to-out delay
  constant TCQ : time := 1 ns;

  -- TLP Header format/type values
  constant PIO_32_CPLD_FMT_TYPE : std_logic_vector(6 downto 0) := "1001010";
  constant PIO_32_CPL_FMT_TYPE  : std_logic_vector(6 downto 0) := "0001010";

  -- States
  type state_type is (
    PIO_32_TX_RST_STATE,
    PIO_32_TX_CPL_CPLD_DW1,
    PIO_32_TX_CPL_CPLD_DW2,
    PIO_32_TX_CPLD_DW3,
    PIO_32_TX_WAIT_STATE
  );
  signal state                 : state_type;

  -- Local signals
  signal byte_count            : std_logic_vector(11 downto 0);
  signal lower_addr            : std_logic_vector(6 downto 0);
  signal cpl_w_data            : std_logic;
  signal req_compl_q           : std_logic;
  signal req_compl_with_data_q : std_logic;
  signal rd_be_o_int           : std_logic_vector(3 downto 0);
  signal random_num           : std_logic_vector(31 downto 0);

begin

  --
  -- Unused discontinue signal
  --

  tx_src_dsc <= '0';

  --
  -- Assign byte enables to output bus
  --

  rd_be_o <= rd_be_o_int;

  --
  -- Present address and byte enable to memory module
  --
  rd_addr_o    <= req_addr_i(12 downto 2);
  rd_be_o_int  <= req_be_i(3 downto 0);

  --
  -- Calculate byte count based on byte enable
  --
  process(rd_be_o_int) begin
    case rd_be_o_int(3 downto 0) is
      when "1001" => byte_count <= X"004";
      when "1011" => byte_count <= X"004";
      when "1101" => byte_count <= X"004";
      when "1111" => byte_count <= X"004";
      when "0101" => byte_count <= X"003";
      when "0111" => byte_count <= X"003";
      when "1010" => byte_count <= X"003";
      when "1110" => byte_count <= X"003";
      when "0011" => byte_count <= X"002";
      when "0110" => byte_count <= X"002";
      when "1100" => byte_count <= X"002";
      when "0001" => byte_count <= X"001";
      when "0010" => byte_count <= X"001";
      when "0100" => byte_count <= X"001";
      when "1000" => byte_count <= X"001";
      when others => byte_count <= X"001"; -- "0000"
    end case;
  end process;

  --
  -- Calculate lower address based on  byte enable
  --
  process(rd_be_o_int, req_addr_i) begin
    case (rd_be_o_int(3 downto 0)) is
      when "0000" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "0001" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "0011" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "0101" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "0111" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "1001" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "1011" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "1101" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "1111" => lower_addr <= req_addr_i(6 downto 2) & "00";
      when "0010" => lower_addr <= req_addr_i(6 downto 2) & "01";
      when "0110" => lower_addr <= req_addr_i(6 downto 2) & "01";
      when "1010" => lower_addr <= req_addr_i(6 downto 2) & "01";
      when "1110" => lower_addr <= req_addr_i(6 downto 2) & "01";
      when "0100" => lower_addr <= req_addr_i(6 downto 2) & "10";
      when "1100" => lower_addr <= req_addr_i(6 downto 2) & "10";
      when others => lower_addr <= req_addr_i(6 downto 2) & "11"; -- "1000"
    end case;
  end process;

  process begin
    wait until rising_edge(clk);
    if (rst_n = '0') then
      req_compl_q            <= '0' after TCQ;
      req_compl_with_data_q  <= '1' after TCQ;
    else
      req_compl_q            <= req_compl_i after TCQ;
      req_compl_with_data_q  <= req_compl_with_data_i after TCQ;
    end if;
  end process;

  --
  --  Generate Completion with 1 DW Payload or Completion with
  --  no data
  --
  process begin
    wait until rising_edge(clk);
    if (rst_n = '0') then

      s_axis_tx_tlast   <= '0' after TCQ;
      s_axis_tx_tvalid  <= '0' after TCQ;
      s_axis_tx_tdata   <= (others => '0') after TCQ;
      s_axis_tx_tkeep   <= x"F" after TCQ;

      compl_done_o      <= '0' after TCQ;

      state             <= PIO_32_TX_RST_STATE after TCQ;
    else
      compl_done_o      <= '0' after TCQ;

      case (state) is
        when PIO_32_TX_RST_STATE =>

          if ((req_compl_q = '1') and (req_compl_with_data_q = '1'))  then
            -- Begin a CplD TLP
            s_axis_tx_tlast   <= '0' after TCQ;
            s_axis_tx_tvalid  <= '1' after TCQ;
            s_axis_tx_tdata   <= '0' &
                                 PIO_32_CPLD_FMT_TYPE &
                                 '0' &
                                 req_tc_i &
                                 "0000" &
                                 req_td_i &
                                 req_ep_i &
                                 req_attr_i &
                                 "00" &
                                 req_len_i after TCQ;
            cpl_w_data        <= req_compl_with_data_q after TCQ;
            state             <= PIO_32_TX_CPL_CPLD_DW1 after TCQ;
          elsif ((req_compl_q = '1') and (req_compl_with_data_q = '0')) then
            -- Begin a Cpl TLP
            s_axis_tx_tlast   <= '0' after TCQ;
            s_axis_tx_tvalid  <= '1' after TCQ;
            s_axis_tx_tdata   <= '0' &
                                 PIO_32_CPL_FMT_TYPE &
                                 '0' &
                                 req_tc_i &
                                 "0000" &
                                 req_td_i &
                                 req_ep_i &
                                 req_attr_i &
                                 "00" &
                                req_len_i after TCQ;
            cpl_w_data        <= req_compl_with_data_q after TCQ;
            state             <= PIO_32_TX_CPL_CPLD_DW1 after TCQ;
          else
            s_axis_tx_tlast   <= '0' after TCQ;
            s_axis_tx_tvalid  <= '0' after TCQ;
            s_axis_tx_tdata   <= (others => '0') after TCQ; -- 32-bit
            s_axis_tx_tkeep   <= x"F" after TCQ;
            state             <= PIO_32_TX_RST_STATE after TCQ;
          end if;
        -- end of PIO_32_TX_RST_STATE

        when PIO_32_TX_CPL_CPLD_DW1 =>
          if (s_axis_tx_tready = '1') then
            -- Output next DW of TLP
            s_axis_tx_tlast   <= '0' after TCQ;
            s_axis_tx_tvalid  <= '1' after TCQ;

            s_axis_tx_tdata   <= completer_id_i &
                                 "000" &
                                 '0' &
                                 byte_count after TCQ;
            state            <= PIO_32_TX_CPL_CPLD_DW2 after TCQ;
          else
            -- Wait for core to accept previous DW
            state            <= PIO_32_TX_CPL_CPLD_DW1 after TCQ;
          end if;
        -- end of PIO_32_TX_CPL_CPLD_DW1

        when PIO_32_TX_CPL_CPLD_DW2 =>
          if (s_axis_tx_tready = '1') then
            -- Output next DW of TLP
            s_axis_tx_tlast   <= '0' after TCQ;
            s_axis_tx_tvalid  <= '1' after TCQ;
            s_axis_tx_tdata   <= req_rid_i &
                                 req_tag_i &
                                 '0' &
                                 lower_addr after TCQ;
            if (cpl_w_data = '1') then
              -- For a CplD, there is one more DW
              s_axis_tx_tlast     <= '0' after TCQ;
              state          <= PIO_32_TX_CPLD_DW3 after TCQ;
            else
              -- For a Cpl, this is the final DW
              s_axis_tx_tlast     <= '1' after TCQ;
              state          <= PIO_32_TX_WAIT_STATE after TCQ;
            end if;
          else
            -- Wait for core to accept previous DW
            state            <= PIO_32_TX_CPL_CPLD_DW2 after TCQ;
          end if;
        -- end of PIO_32_TX_CPL_CPLD_DW2

        when PIO_32_TX_CPLD_DW3 =>
          if (s_axis_tx_tready = '1') then
            -- Output next DW of TLP
            s_axis_tx_tlast  <=  '1' after TCQ;
            s_axis_tx_tvalid <= '1' after TCQ;
            --s_axis_tx_tdata  <= rd_data_i after TCQ;
				s_axis_tx_tdata  <= random_num after TCQ;
                        state            <= PIO_32_TX_WAIT_STATE after TCQ;
          else
            -- Wait for core to accept previous DW
            state            <= PIO_32_TX_CPLD_DW3 after TCQ;
          end if;

        when PIO_32_TX_WAIT_STATE =>
          if (s_axis_tx_tready = '1') then
            -- Core has accepted final DW of TLP
            s_axis_tx_tlast  <= '0' after TCQ;
            s_axis_tx_tvalid <= '0' after TCQ;
            compl_done_o     <= '1' after TCQ;
            s_axis_tx_tdata  <= (others => '0') after TCQ;
            state            <= PIO_32_TX_RST_STATE after TCQ;
          else
            -- Wait for core to accept previous DW
            state            <= PIO_32_TX_WAIT_STATE after TCQ;
          end if;
        -- end of PIO_32_TX_WAIT_STATE

        when others =>
          state              <= PIO_32_TX_RST_STATE after TCQ;
      end case;
    end if;
  end process;
  
  process(clk)
		variable counter: integer range 0 to 500000000 := 0;
		variable time_counter: integer range 0 to 500000000 := 0;
		
		begin
			if rising_edge(clk) then
				time_counter := time_counter + 1;
				if time_counter > 10000000 then
					counter := counter + 1;
					time_counter := 0;
				
						 random_num <= std_logic_vector(to_unsigned(counter, 32));
				end if;
			end if;	
		end process;

end rtl;

