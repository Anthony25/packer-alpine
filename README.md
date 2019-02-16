Packer Alpine Linux
===================

[![Build Status](https://travis-ci.org/Anthony25/packer-alpine.svg?branch=master)](https://travis-ci.org/Anthony25/packer-alpine)

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
        -var ip4="192.168.0.10/24" \
        alpine-template.json

By default, the template enable DHCP and IPv6 autoconf, but a static IPv4 or
IPv6 can also be specified through the variables `ip4` and `ip6`.

License
-------

Tool under the BSD license. Do not hesitate to report bugs, ask me some
questions or do some pull request if you want to!
