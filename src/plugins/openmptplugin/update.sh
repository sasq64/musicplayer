#!/bin/sh

git clone https://github.com/OpenMPT/openmpt.git
cd openmpt
patch -p1 < ../openmpt.patch
