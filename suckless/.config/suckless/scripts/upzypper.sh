#!/bin/bash

exec kitty -e sudo sh -c 'zypper ref; zypper up --no-recommends; zypper dup --no-recommends; pkill -SIGRTMIN+8 waybar'
