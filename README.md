Packer Alpine Linux
===================

Packer Alpine is a bare bones [Packer](https://www.packer.io/) template and
installation script that can be used to generate qemu image for [Alpine
Linux](https://www.alpinelinux.org/).

Overview
--------

It installed an image with these characteristics by default:

* 64-bit
* 5 GB disk
* No swap (but configurable through the `swap_size` variable)
* OpenSSH is also installed and enabled on boot
* Python2 is installed, for ansible

Usage
-----

Assuming that you already have Packer, you should be good to clone
this repo and go:

    $ git clone https://github.com/elasticdog/packer-alpine.git
    $ cd packer-alpine/
    $ packer build alpine-template.json

It is possible to tweak the defined variables (see alpine-template.json for
more details):

    $ packer build \
        -vars ip4="192.168.0.10" netmask4="255.255.255.0" \
        alpine-template.json

By default, the template enable DHCP and IPv6 autoconf, but a static IPv4 or
IPv6 can also be specified through the variables `ip4`, `netmask4`, `ip6` and
`netmask6`.
