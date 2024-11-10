#!/bin/bash

exec kitty -e sudo sh -c 'zypper ref; zypper dup; pkill -SIGRTMIN+8 waybar'
