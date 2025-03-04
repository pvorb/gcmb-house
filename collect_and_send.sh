#!/bin/bash

function send_data {
    mosquitto_pub \
        -h gcmb.io \
        -p 8883 \
        -i $MQTT_CLIENT_ID/pub \
        -u $MQTT_CLIENT_ID \
        -P $MQTT_CLIENT_SECRET \
        -t paul/house/$1 \
        -r \
        -m "$2"
}

while true; do
    read battery_level p_grid p_pv p_battery < <(echo $(curl -s 'http://fronius/solar_api/v1/GetPowerFlowRealtimeData.fcgi' | 
         jq -r '.Body.Data.Inverters["1"].SOC, .Body.Data.Site.P_Grid, .Body.Data.Site.P_PV, .Body.Data.Site.P_Akku'))

    printf -v battery_level "%.1f" $battery_level
    printf -v p_grid "%.1f" $p_grid
    printf -v p_pv "%.1f" $p_pv
    printf -v p_battery "%.1f" $p_battery

    date
    echo "battery charge: $battery_level"
    echo "P grid: $p_grid"
    echo "P PV: $p_pv"
    echo "P battery: $p_battery"
    echo ""

    send_data "battery_level" "$battery_level"
    send_data "battery_power" "$p_battery"
    send_data "pv_power" "$p_pv"
    send_data "grid_power" "$p_grid"

    sleep 600
done
