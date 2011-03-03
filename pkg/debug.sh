#!/bin/bash

echo Build R package
R CMD build --no-vignettes rnavgraph/
echo Compile R package
sudo R CMD INSTALL RnavGraph_0.0.7.tar.gz
echo Start R with debug Code
R 

#echo  "source('debug.R')" | R --vanilla 

#R --slave --vanilla --quiet --no-save <<EOF
#a <- 1
#print(a)
#EOF