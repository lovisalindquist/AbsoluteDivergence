#!/bin/sh

mkdir results/BEAST
for xmlfile in data/XMLs/*.xml;

do
filename=$(echo $xmlfile | sed s/"data\/XMLs\/"/""/g)
idname=$(echo $filename | sed s/[A-Za-z._]/""/g)
echo "Processing ${filename}"
echo "${idname}"
cp $xmlfile results/BEAST/
cd results/BEAST/

beast $filename

cd ../../

done
