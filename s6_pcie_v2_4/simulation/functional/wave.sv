#
# Simulator
#

database require simulator -hints {
    simulator "ncsim -gui work.board"
}

#
# groups
#
catch {group new -name {SYS Interface} -overlay 0}
catch {group new -name {AXI Common} -overlay 0}
catch {group new -name {AXI Rx} -overlay 0}
catch {group new -name {AXI Tx} -overlay 0}

group using {SYS Interface}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    :EP:sys_clk_c \
    :EP:sys_reset_n_c

group using {AXI Common}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    :EP:user_clk \
    :EP:user_reset \
    :EP:user_lnk_up \
    :EP:fc_sel \
    :EP:fc_cpld \
    :EP:fc_cplh \
    :EP:fc_npd \
    :EP:fc_nph \
    :EP:fc_pd \
    :EP:fc_ph \
group using {AXI Rx}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    :EP:m_axis_rx_tdata \
    :EP:m_axis_rx_tready \
    :EP:m_axis_rx_tvalid \
    :EP:m_axis_rx_tlast \
    :EP:m_axis_rx_tuser \
    :EP:rx_np_ok

group using {AXI Tx}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    :EP: s_axis_tx_tdata \
    :EP: s_axis_tx_tready \
    :EP: s_axis_tx_tvalid \
    :EP: s_axis_tx_tlast  \
    :EP: s_axis_tx_tuser  \
    :EP: tx_buf_av \
    :EP: tx_err_drop \
    :EP: tx_cfg_req \
    :EP: tx_cfg_gnt

#
# Design Browser windows
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 700x500+0+462}] != ""} {
    window geometry "Design Browser 1" 700x500+0+462
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope simulator:::EP
browser yview see simulator:::EP
browser timecontrol set -lock 0

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 800x600+0+0}] != ""} {
    window geometry "Waveform 1" 800x600+0+0
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 0
cursor set -using TimeA -marching 1
waveform baseline set -time 0

set groupId [waveform add -groups {{SYS Interface}}]

set groupId [waveform add -groups {{AXI Common}}]

set groupId [waveform add -groups {{AXI Rx}}]

set groupId [waveform add -groups {{AXI Tx}}]


waveform xview limits 0 2000ns

#
# Console window
#
console set -windowname Console

