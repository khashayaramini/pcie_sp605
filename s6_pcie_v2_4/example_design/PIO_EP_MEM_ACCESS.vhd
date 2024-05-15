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
-- File       : PIO_EP_MEM_ACCESS.vhd
-- Description: Endpoint Memory Access Unit. This module provides access
--              functions to the Endpoint memory aperture.
--
--              Read Access: Module returns data for the specifed address and
--              byte enables selected.
--
--              Write Access: Module accepts data, byte enables and updates
--              data when write enable is asserted. Modules signals write busy
--              when data write is in progress.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity PIO_EP_MEM_ACCESS is
port (
  clk          : in  std_logic;
  rst_n        : in  std_logic;

  --  Read Port
  rd_addr_i    : in  std_logic_vector(10 downto 0);
  rd_be_i      : in  std_logic_vector(3 downto 0);
  rd_data_o    : out std_logic_vector(31 downto 0);

  --  Write Port
  wr_addr_i    : in  std_logic_vector(10 downto 0);
  wr_be_i      : in  std_logic_vector(7 downto 0);
  wr_data_i    : in  std_logic_vector(31 downto 0);
  wr_en_i      : in  std_logic;
  wr_busy_o    : out std_logic
);
end PIO_EP_MEM_ACCESS;

architecture rtl of PIO_EP_MEM_ACCESS is

  constant TCQ : time := 1 ns;
  type state_type is (PIO_MEM_ACCESS_WR_RST,
                      PIO_MEM_ACCESS_WR_WAIT,
                      PIO_MEM_ACCESS_WR_READ,
                      PIO_MEM_ACCESS_WR_WRITE
                      );

  component PIO_EP_MEM port (
    clk_i       : in  std_logic;

    a_rd_a_i_0  : in  std_logic_vector(8 downto 0);
    a_rd_d_o_0  : out std_logic_vector(31 downto 0);
    a_rd_en_i_0 : in  std_logic;

    b_wr_a_i_0  : in  std_logic_vector(8 downto 0);
    b_wr_d_i_0  : in  std_logic_vector(31 downto 0);
    b_wr_en_i_0 : in  std_logic;
    b_rd_d_o_0  : out std_logic_vector(31 downto 0);
    b_rd_en_i_0 : in  std_logic;

    a_rd_a_i_1  : in  std_logic_vector(8 downto 0);
    a_rd_d_o_1  : out std_logic_vector(31 downto 0);
    a_rd_en_i_1 : in  std_logic;

    b_wr_a_i_1  : in  std_logic_vector(8 downto 0);
    b_wr_d_i_1  : in  std_logic_vector(31 downto 0);
    b_wr_en_i_1 : in  std_logic;
    b_rd_d_o_1  : out std_logic_vector(31 downto 0);
    b_rd_en_i_1 : in  std_logic;

    a_rd_a_i_2  : in  std_logic_vector(8 downto 0);
    a_rd_d_o_2  : out std_logic_vector(31 downto 0);
    a_rd_en_i_2 : in  std_logic;

    b_wr_a_i_2  : in  std_logic_vector(8 downto 0);
    b_wr_d_i_2  : in  std_logic_vector(31 downto 0);
    b_wr_en_i_2 : in  std_logic;
    b_rd_d_o_2  : out std_logic_vector(31 downto 0);
    b_rd_en_i_2 : in  std_logic;

    a_rd_a_i_3  : in  std_logic_vector(8 downto 0);
    a_rd_d_o_3  : out std_logic_vector(31 downto 0);
    a_rd_en_i_3 : in  std_logic;

    b_wr_a_i_3  : in  std_logic_vector(8 downto 0);
    b_wr_d_i_3  : in  std_logic_vector(31 downto 0);
    b_wr_en_i_3 : in  std_logic;
    b_rd_d_o_3  : out std_logic_vector(31 downto 0);
    b_rd_en_i_3 : in  std_logic
  );
  end component;

  signal rd_data_raw_o  : std_logic_vector(31 downto 0);

  signal rd_data0_o     : std_logic_vector(31 downto 0);
  signal rd_data1_o     : std_logic_vector(31 downto 0);
  signal rd_data2_o     : std_logic_vector(31 downto 0);
  signal rd_data3_o     : std_logic_vector(31 downto 0);

  signal write_en       : std_logic;
  signal post_wr_data   : std_logic_vector(31 downto 0);
  signal w_pre_wr_data  : std_logic_vector(31 downto 0);

  signal wr_mem_state   : state_type;

  signal pre_wr_data    : std_logic_vector(31 downto 0);
  signal w_pre_wr_data0 : std_logic_vector(31 downto 0);
  signal w_pre_wr_data1 : std_logic_vector(31 downto 0);
  signal w_pre_wr_data2 : std_logic_vector(31 downto 0);
  signal w_pre_wr_data3 : std_logic_vector(31 downto 0);

  --
  -- Memory Write Process
  --

  --
  --  Extract current data bytes. These need to be swizzled
  --  BRAM storage format :
  --    data[31:0] = { byte[3], byte[2], byte[1], byte[0] (lowest addr) }
  --
  signal w_pre_wr_data_b3 : std_logic_vector(7 downto 0);
  signal w_pre_wr_data_b2 : std_logic_vector(7 downto 0);
  signal w_pre_wr_data_b1 : std_logic_vector(7 downto 0);
  signal w_pre_wr_data_b0 : std_logic_vector(7 downto 0);

  --
  --  Extract new data bytes from payload
  --  TLP Payload format :
  --    data[31:0] = { byte[0] (lowest addr), byte[2], byte[1], byte[3] }
  --
  signal w_wr_data_b3 : std_logic_vector(7 downto 0);
  signal w_wr_data_b2 : std_logic_vector(7 downto 0);
  signal w_wr_data_b1 : std_logic_vector(7 downto 0);
  signal w_wr_data_b0 : std_logic_vector(7 downto 0);

  signal w_wr_data0_int : std_logic_vector(7 downto 0);
  signal w_wr_data1_int : std_logic_vector(7 downto 0);
  signal w_wr_data2_int : std_logic_vector(7 downto 0);
  signal w_wr_data3_int : std_logic_vector(7 downto 0);

  signal rd_data0_en : std_logic;
  signal rd_data1_en : std_logic;
  signal rd_data2_en : std_logic;
  signal rd_data3_en : std_logic;

  signal rd_data_raw_int0 : std_logic_vector(7 downto 0);
  signal rd_data_raw_int1 : std_logic_vector(7 downto 0);
  signal rd_data_raw_int2 : std_logic_vector(7 downto 0);
  signal rd_data_raw_int3 : std_logic_vector(7 downto 0);

  signal b_wr_en_0 : std_logic;
  signal b_wr_en_1 : std_logic;
  signal b_wr_en_2 : std_logic;
  signal b_wr_en_3 : std_logic;

  signal wr_addr_0 : std_logic;
  signal wr_addr_1 : std_logic;
  signal wr_addr_2 : std_logic;
  signal wr_addr_3 : std_logic;

begin

  --
  --  Extract current data bytes. These need to be swizzled
  --  BRAM storage format :
  --    data[31:0] = { byte[3], byte[2], byte[1], byte[0] (lowest addr) }
  --
  w_pre_wr_data_b3 <= pre_wr_data(31 downto 24);
  w_pre_wr_data_b2 <= pre_wr_data(23 downto 16);
  w_pre_wr_data_b1 <= pre_wr_data(15 downto 08);
  w_pre_wr_data_b0 <= pre_wr_data(07 downto 00);

  --
  --  Extract new data bytes from payload
  --  TLP Payload format :
  --    data[31:0] = { byte[0] (lowest addr), byte[2], byte[1], byte[3] }
  --
  w_wr_data_b3 <= wr_data_i(7 downto 0);
  w_wr_data_b2 <= wr_data_i(15 downto 8);
  w_wr_data_b1 <= wr_data_i(23 downto 16);
  w_wr_data_b0 <= wr_data_i(31 downto 24);

  w_wr_data3_int <= w_wr_data_b3 when (wr_be_i(3) = '1') else w_pre_wr_data_b3;
  w_wr_data2_int <= w_wr_data_b2 when (wr_be_i(2) = '1') else w_pre_wr_data_b2;
  w_wr_data1_int <= w_wr_data_b1 when (wr_be_i(1) = '1') else w_pre_wr_data_b1;
  w_wr_data0_int <= w_wr_data_b0 when (wr_be_i(0) = '1') else w_pre_wr_data_b0;

  process begin
    wait until rising_edge(clk);
    if (rst_n = '0') then
      write_en       <= '0';
      pre_wr_data    <= (OTHERS => '0') after TCQ;
      post_wr_data   <= (OTHERS => '0') after TCQ;
      pre_wr_data    <= (OTHERS => '0') after TCQ;
      wr_mem_state   <= PIO_MEM_ACCESS_WR_RST after TCQ;
    else
      case (wr_mem_state) is
        when PIO_MEM_ACCESS_WR_RST =>
          if (wr_en_i = '1') then -- read state
            -- Pipelining happens in RAM's internal output reg
            wr_mem_state <= PIO_MEM_ACCESS_WR_WAIT after TCQ;
          else
            write_en     <= '0' after TCQ;
            wr_mem_state <= PIO_MEM_ACCESS_WR_RST after TCQ;
          end if;

        when PIO_MEM_ACCESS_WR_WAIT =>
          --
          -- Pipeline B port data before processing. Block RAMs
          -- have internal output register enabled
          --
          write_en       <= '0' after TCQ;
          wr_mem_state   <= PIO_MEM_ACCESS_WR_READ after TCQ;

        when PIO_MEM_ACCESS_WR_READ =>
          --
          -- Now save the selected BRAM B port data out
          --

          pre_wr_data    <= w_pre_wr_data after TCQ;
          write_en       <= '0' after TCQ;
          wr_mem_state   <= PIO_MEM_ACCESS_WR_WRITE after TCQ;

        when PIO_MEM_ACCESS_WR_WRITE =>
          --
          -- Merge new enabled data and write target BlockRAM location
          --
          post_wr_data   <= w_wr_data3_int &
                            w_wr_data2_int &
                            w_wr_data1_int &
                            w_wr_data0_int after TCQ;
          write_en       <= '1' after TCQ;
          wr_mem_state   <= PIO_MEM_ACCESS_WR_RST after TCQ;

        when others => null;
          wr_mem_state   <= PIO_MEM_ACCESS_WR_RST after TCQ;
      end case;
    end if;
  end process;

  --
  -- Write controller busy
  --
  wr_busy_o <= '1' when ((wr_mem_state /= PIO_MEM_ACCESS_WR_RST) or wr_en_i = '1') else '0';

  --
  -- Select BlockRAM output based on higher 2 address bits
  --
  process (wr_addr_i, w_pre_wr_data0, w_pre_wr_data1, w_pre_wr_data2,
           w_pre_wr_data3) begin
    case (wr_addr_i(10 downto 9)) is
      when "00" => w_pre_wr_data <= w_pre_wr_data0;
      when "01" => w_pre_wr_data <= w_pre_wr_data1;
      when "10" => w_pre_wr_data <= w_pre_wr_data2;
      when "11" => w_pre_wr_data <= w_pre_wr_data3;
      when others => null;
    end case;
  end process;

  --
  -- Memory Read Controller
  --
  rd_data0_en <= '1' when (rd_addr_i(10 downto 9) = "00") else '0';
  rd_data1_en <= '1' when (rd_addr_i(10 downto 9) = "01") else '0';
  rd_data2_en <= '1' when (rd_addr_i(10 downto 9) = "10") else '0';
  rd_data3_en <= '1' when (rd_addr_i(10 downto 9) = "11") else '0';

  process(rd_addr_i, rd_data0_o, rd_data1_o,
          rd_data2_o, rd_data3_o) begin
    case (rd_addr_i(10 downto 9)) is
      when "00" => rd_data_raw_o <= rd_data0_o;
      when "01" => rd_data_raw_o <= rd_data1_o;
      when "10" => rd_data_raw_o <= rd_data2_o;
      when "11" => rd_data_raw_o <= rd_data3_o;
      when others => null;
    end case;
  end process;

  -- Handle Read byte enables  --
  rd_data_raw_int0 <= rd_data_raw_o(7 downto 0)    when (rd_be_i(0) = '1')
                      else (others => '0');
  rd_data_raw_int1 <= rd_data_raw_o(15 downto 8)   when (rd_be_i(1) = '1')
                      else (others => '0');
  rd_data_raw_int2 <= rd_data_raw_o(23 downto 16)  when (rd_be_i(2) = '1')
                      else (others => '0');
  rd_data_raw_int3 <= rd_data_raw_o (31 downto 24) when (rd_be_i(3) = '1')
                      else (others => '0');

  rd_data_o        <= rd_data_raw_int0 &
                      rd_data_raw_int1 &
                      rd_data_raw_int2 &
                      rd_data_raw_int3 ;

  b_wr_en_0    <= write_en when (wr_addr_i(10 downto 9) = "00") else '0';
  b_wr_en_1    <= write_en when (wr_addr_i(10 downto 9) = "01") else '0';
  b_wr_en_2    <= write_en when (wr_addr_i(10 downto 9) = "10") else '0';
  b_wr_en_3    <= write_en when (wr_addr_i(10 downto 9) = "11") else '0';

  wr_addr_0    <= '1' when (wr_addr_i(10 downto 9) = "00") else '0';
  wr_addr_1    <= '1' when (wr_addr_i(10 downto 9) = "01") else '0';
  wr_addr_2    <= '1' when (wr_addr_i(10 downto 9) = "10") else '0';
  wr_addr_3    <= '1' when (wr_addr_i(10 downto 9) = "11") else '0';

  PIO_EP_MEM_inst : PIO_EP_MEM
  port map (
    clk_i       => clk,

    a_rd_a_i_0  => rd_addr_i(8 downto 0),       -- I [8:0]
    a_rd_en_i_0 => rd_data0_en,                 -- I [1:0]
    a_rd_d_o_0  => rd_data0_o,                  -- O [31:0]

    b_wr_a_i_0  => wr_addr_i(8 downto 0),       -- I [8:0]
    b_wr_d_i_0  => post_wr_data,                -- I [31:0]
    b_wr_en_i_0 => b_wr_en_0,                   -- I
    b_rd_d_o_0  => w_pre_wr_data0(31 downto 0), -- O [31:0]
    b_rd_en_i_0 => wr_addr_0,                   -- I

    a_rd_a_i_1  => rd_addr_i(8 downto 0),       -- I [8:0]
    a_rd_en_i_1 => rd_data1_en,                 -- I [1:0]
    a_rd_d_o_1  => rd_data1_o,                  -- O [31:0]

    b_wr_a_i_1  => wr_addr_i(8 downto 0),       -- I [8:0]
    b_wr_d_i_1  => post_wr_data,                -- I [31:0]
    b_wr_en_i_1 => b_wr_en_1,                   -- I
    b_rd_d_o_1  => w_pre_wr_data1(31 downto 0), -- O [31:0]
    b_rd_en_i_1 => wr_addr_1,                   -- I

    a_rd_a_i_2  => rd_addr_i(8 downto 0),       -- I [8:0]
    a_rd_en_i_2 => rd_data2_en,                 -- I [1:0]
    a_rd_d_o_2  => rd_data2_o,                  -- O [31:0]

    b_wr_a_i_2  => wr_addr_i(8 downto 0),       -- I [8:0]
    b_wr_d_i_2  => post_wr_data,                -- I [31:0]
    b_wr_en_i_2 => b_wr_en_2,                   -- I
    b_rd_d_o_2  => w_pre_wr_data2(31 downto 0), -- I [31:0]
    b_rd_en_i_2 => wr_addr_2,                   -- I

    a_rd_a_i_3  => rd_addr_i(8 downto 0),       -- I [8:0]
    a_rd_en_i_3 => rd_data3_en,                 -- I [1:0]
    a_rd_d_o_3  => rd_data3_o,                  -- O [31:0]

    b_wr_a_i_3  => wr_addr_i(8 downto 0),       -- I [8:0]
    b_wr_d_i_3  => post_wr_data,                -- I [31:0]
    b_wr_en_i_3 => b_wr_en_3,                   -- I
    b_rd_d_o_3  => w_pre_wr_data3(31 downto 0), -- I [31:0]
    b_rd_en_i_3 => wr_addr_3                    -- I
  );

end rtl;
