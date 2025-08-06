#!/bin/bash

rm -rv config.h & 
cp config.def.h config.h & 
sudo make & 
sudo make clean install
