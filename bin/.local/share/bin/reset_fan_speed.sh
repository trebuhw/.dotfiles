#!/usr/bin/bash

# restart tlp, powoduje także restart wentylatorów :)
echo "############################################################"
echo "##  Skrypt restartuje prędkość wentylatorów podaj hasło   ##"
echo "##           (sudo systemctl restart tlp --now)           ##"
echo "############################################################"
echo ""
sudo systemctl restart tlp --now
