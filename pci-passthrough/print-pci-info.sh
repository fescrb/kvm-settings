#! /bin/bash

# Set the delimiter for the 'in' keyword be a newline rather than any whitespace
IFS=$'\n'
for DEVICE in $(lspci -nn);
do
    BUS_ID="$(echo $DEVICE | cut -f 1 -d " ")"
    MODALIAS="$(cat /sys/bus/pci/devices/0000:$BUS_ID/modalias)"
    echo $DEVICE $MODALIAS
done