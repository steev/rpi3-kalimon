#!/bin/bash

#http://stackoverflow.com/a/15808052
prompt="Please select a file:"
options=( $(find rpi3-kali -iregex ".*\.\(img\)" -print0 | xargs -0) )

PS3="$prompt "
select OUTPUTFILE in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $OUTPUTFILE which is file $REPLY"
        break

    else
        echo "Invalid option. Try another one."
    fi
done

echo $OUTPUTFILE

if [ -f "${OUTPUTFILE}" ]; then

    dir=/tmp/rpi
    test "umount" = "${OUTPUTFILE}" && sudo umount $dir/boot && sudo umount $dir
    image="${OUTPUTFILE}"
    test -r "$image"

    o_boot=`sudo sfdisk -l $image | grep FAT32 | awk '{ print $2 }'`
    o_linux=`sudo sfdisk -l $image | grep Linux | awk '{ print $2 }'`

    echo "Mounting img o_linux: $o_linux and o_boot: $o_boot"
    test -d $dir || mkdir -p $dir
    sudo mount -o offset=`expr $o_linux \* 512`,loop $image $dir
    sudo mount -o offset=`expr $o_boot  \* 512`,loop $image $dir/boot
    systemd-nspawn -D $dir /bin/bash
    

    echo "[+] Unmounting"
    sleep 10
    sudo umount $dir/boot
    sudo umount $dir
    rm -rf $dir
else
	echo "File $OUTPUTFILE not found"
fi
