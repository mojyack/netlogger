#!/bin/sh

cd /sys/class/net

# $1 iface
# -> $ret
process_bandwidth() {
    id=${1/./_} # wlan0.sta1 -> wlan0_sta1

    eval prev_rx=\$${id}_rx
    eval prev_tx=\$${id}_tx
    eval ${id}_rx=$(cat $1/statistics/rx_bytes)
    eval ${id}_tx=$(cat $1/statistics/tx_bytes)
    if [[ -z $prev_rx ]] && [[ -z $prev_tx ]]; then
        # a first sample for this interface
        return
    fi
    diff_rx=$(( ${id}_rx - prev_rx ))
    diff_tx=$(( ${id}_tx - prev_tx ))
    if [[ $diff_rx -lt 0 ]] && [[ $diff_tx -lt 0 ]]; then
        # this interface maybe reappeared?
        return
    fi
    ret=$diff_rx,$diff_tx
}

# $1 iface
# -> $mac,$ret
process_rssi() {
    dump=$(iw dev $1 station dump)
    mac=$(echo "$dump" | head -n 1 | cut -d ' ' -f 2)
    ret=$(echo "$dump" | grep signal: | cut -f 3 | cut -d ' ' -f 1)
}

while true; do
    for iface in wl*; do
        now=$(date +%s)

        process_bandwidth $iface
        if ! [[ -z $ret ]]; then
            echo bandwidth-$iface
            echo $now,$ret
        fi

        process_rssi $iface
        if ! [[ -z $ret ]]; then
            echo signal-$mac
            echo $now,$ret
        fi
    done
    sleep 1
done
