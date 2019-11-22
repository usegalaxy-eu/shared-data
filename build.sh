#!/bin/bash

wget https://github.com/galaxyproject/training-material/archive/master.zip
unzip master.zip
cd training-material-master/
./bin/mergeyaml.py --nondocker > ../GTN.yaml
cd ../
