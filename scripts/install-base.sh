#!/usr/bin/env ash

# stop on errors
set -eu

DISK="/dev/vda"
TARGET_DIR="/mnt"
ANSWERS="/root/answers"

INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

iface eth0 inet6 manual
    pre-up echo 1 > /proc/sys/net/ipv6/conf/eth0/accept_ra
"

install_os() {
    complete_answers_file
    yes "y" | setup-alpine -e -f "$ANSWERS"

    prepare_chroot
    install_pkg

    enable_ipv6
    add_ssh_keys
    enable_serial_tty

    clean_up
}

complete_answers_file() {
    echo '==> Complete the answers file'

    echo "HOSTNAMEOPTS=\"$HOSTNAMEOPTS\"" >> "$ANSWERS"
    echo "PROXYOPTS=\"$PROXYOPTS\"" >> "$ANSWERS"

    if [ -n "$IP4" -a -z "$NETMASK4" -o -n "$IP6" -a -z "$NETMASK6" ]; then
        echo "IP4 and IP6 should have a netmask"
        exit 1
    elif [ -n "$IP4" -o -n "$IP6" ]; then
        INTERFACESOPTS=`echo "$INTERFACESOPTS"$'\n'"auto eth0:0"`

        if [ -n "$IP4" ]; then
            INTERFACESOPTS=`echo "$INTERFACESOPTS" \
                $'\niface eth0:0 inet static' \
                $'\n\taddress' "$IP4" \
                $'\n\tnetmask' "$NETMASK4"`
        fi
        if [ -n "$IP6" ]; then
            INTERFACESOPTS=`echo "$INTERFACESOPTS" \
                $'\niface eth0:0 inet6 static' \
                $'\n\taddress' "$IP6" \
                $'\n\tnetmask' "$NETMASK6"`
        fi
    fi
    echo "INTERFACESOPTS=\"$INTERFACESOPTS\"" >> "$ANSWERS"
}

prepare_chroot() {
    echo '==> Prepare chroot'

    mount "$DISK"3 "$TARGET_DIR"
    mount "$DISK"1 "$TARGET_DIR"/boot

    cd /mnt
    mount --bind /dev ./dev
    mount -t devpts devpts ./dev/pts -o nosuid,noexec
    mount -t sysfs sys ./sys -o nosuid,nodev,noexec,ro
    mount -t proc proc ./proc -o nosuid,nodev,noexec
    mount -t tmpfs tmp ./tmp -o mode=1777,nosuid,nodev,strictatime
    mount -t tmpfs run ./run -o mode=0755,nosuid,nodev
    if [ -L ./dev/shm ]; then
        mkdir -p ./`readlink ./dev/shm`
        mount -t tmpfs shm ./`readlink ./dev/shm` -o mode=1777,nosuid,nodev
    else
        mount -t tmpfs shm ./dev/shm -o mode=1777,nosuid,nodev
    fi
}

install_pkg() {
    echo '==> Install packages'

    chroot "$TARGET_DIR" apk add python2
}

enable_ipv6() {
    echo "ipv6" >> "$TARGET_DIR"/etc/modules
}

tweak_syslinux() {
    sed -i 's/timeout=.*/timeout=1/' "$TARGET_DIR"/etc/update-extlinux.conf

    chroot "$TARGET_DIR" update-extlinux
}

enable_serial_tty() {
    echo "ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100" >> \
        "$TARGET_DIR"/etc/inittab

    echo "ttyS0" >> "$TARGET_DIR"/etc/securetty
}

add_ssh_keys() {
    echo '==> Add SSH keys'

    mkdir -p "${TARGET_DIR}/root/.ssh"
    chmod 700 "${TARGET_DIR}/root/.ssh"
    echo "${AUTHORIZED_KEYS}" >> "${TARGET_DIR}/root/.ssh/authorized_keys"
    chmod 600 "${TARGET_DIR}/root/.ssh/authorized_keys"
}

clean_up() {
    echo '==> Clean Up'

    sed -i 's/PermitRootLogin yes//' "${TARGET_DIR}"/etc/ssh/sshd_config
    chroot "${TARGET_DIR}" passwd -d root

    zerofile=$(mktemp "${TARGET_DIR}"/zerofile.XXXXXX)
    dd if=/dev/zero of="$zerofile" bs=1M || true
    rm -f "$zerofile"
    sync
}


install_os

echo '==> Installation complete!'
