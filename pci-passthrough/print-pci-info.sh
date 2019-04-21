#! /bin/bash


NUM_DEVICE_GROUPS="$(ls /sys/kernel/iommu_groups/ | wc -w)"
for DEVICE_GROUP in $(seq 0 $NUM_DEVICE_GROUPS);
do
    DEVICES_PATH="/sys/kernel/iommu_groups/$DEVICE_GROUP/devices/"
    if [ -d "$DEVICES_PATH" ]; then
        for DEVICE in $(ls $DEVICES_PATH);
        do
            MODALIAS="$(cat /sys/bus/pci/devices/$DEVICE/modalias)"
            BUS_ID="$(echo $DEVICE | cut -f 2,3 -d ":")"
            LSPCI_DEVICE_LINE=$(lspci -nn | grep $BUS_ID)
            echo "Group $DEVICE_GROUP: $LSPCI_DEVICE_LINE $MODALIAS" 
        done
    fi
done