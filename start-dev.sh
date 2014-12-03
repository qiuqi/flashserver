#!/bin/sh
exec erl -smp enable +K true +P 10000 -ssl \
    -setcookie 7aebbaa7bbf2a4db7c5016e172ce9cc5 \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -config dev\
    -sname flash_dev \
    -s flash \
    -s reloader
