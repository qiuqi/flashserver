#!/bin/sh
exec erl +K true +P 10000 -ssl -detached \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -config dev\
    -sname flash_dev \
    -s flash \
    -s reloader
