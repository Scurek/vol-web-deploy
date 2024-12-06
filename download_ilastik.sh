#!/bin/sh

mkdir -p ./Ilastik
pip3 install gdown && gdown "https://drive.google.com/uc?id=1UqbeQGYrCOoe30u0z9qMFXto9tVTPPuw" -O Ilastik/ilastik-1.4.0b21-gpu-Linux.tar.bz2
tar -xf Ilastik/ilastik-1.4.0b21-gpu-Linux.tar.bz2 -C Ilastik
mv Ilastik/ilastik-1.4.0b21-gpu-Linux Ilastik/ilastik
rm Ilastik/ilastik-1.4.0b21-gpu-Linux.tar.bz2