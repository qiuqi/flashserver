#!/bin/sh

erl -sname admnode -remsh flash_dev@`hostname -s` -setcookie 7aebbaa7bbf2a4db7c5016e172ce9cc5
