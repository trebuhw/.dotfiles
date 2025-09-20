#!/bin/env bash
exec env QT_QPA_PLATFORMTHEME=qt5ct QT_STYLE_OVERRIDE=kvantum /usr/bin/virtualbox "$@"
