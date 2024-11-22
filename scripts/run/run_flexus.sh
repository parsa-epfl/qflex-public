#!/bin/bash

QFLEX_PATH=/home/qflex

# Quit when any command fails
set -e

for idx in $(seq 0 99)
do
    # 1. Convert the checkpoint format to the flexus
    # if we have the directory, we remove it.
    if [ -d "snapshot_$idx-flexus" ]; then
        rm -rf "snapshot_$idx-flexus"
    fi
    
    mkdir snapshot_$idx-flexus
    ./checkpoint_conversion ./snapshot_$idx ./flexus_configuration.json ./snapshot_$idx-flexus

    # 2. Start flexus
    $QFLEX_PATH/qemu/build/qemu-system-aarch64 \
        -smp 2 \
        -M virt,gic-version=max,virtualization=off,secure=off \
        -cpu max,pauth=off \
        -m 32G \
        -boot menu=on \
        -bios $(pwd)/QEMU_EFI.fd \
        -drive if=virtio,file=root.qcow2,format=qcow2,snapshot=on,tmp-snapshot-name=snapshot_$idx \
        -nic none \
        -rtc clock=vm \
        -loadvm snapshot_$idx \
        -icount shift=0,align=off,sleep=off \
        -nographic -no-reboot \
        -singlestep -d nochain \
        -D "qemu-timing.log" \
        -libqflex \
        mode=timing,lib-path=$QFLEX_PATH/flexus/build/libknottykraken.so,cfg-path=$(pwd)/timing.cfg,cycles=10000000:500000,debug=crit,ckpt-path=./snapshot_$idx-flexus
        
    # 3. Backup results to the result directory
    # if we have the directory, we remove it.
    if [ -d "result_$idx" ]; then
        rm -rf "result_$idx"
    fi
    mkdir "result_$idx"

    # 4. Copy these log files
    mv *.log "result_$idx/"

    # 5. Create a tarball
    tar -czvf "result_$idx.tar.gz" "result_$idx/"

    # 6. Remove the directory
    rm -rf "result_$idx"
done
