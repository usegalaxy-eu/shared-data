#!/bin/bash

wget https://github.com/galaxyproject/training-material/archive/main.zip
unzip main.zip
cd training-material-main/
./bin/mergeyaml.py --nondocker > ../GTN.yaml
cd ../
