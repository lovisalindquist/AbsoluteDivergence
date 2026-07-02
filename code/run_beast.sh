#!/bin/sh

mkdir results
cd results
mkdir BEAST
cd ..

for xmlfile in data/XMLs/*.xml;

do
filename=$(echo $xmlfile | sed s/"data\/XMLs\/"/""/g)
idname=$(echo $filename | sed s/[A-Za-z._]/""/g)
echo "Processing ${filename}"
echo "${idname}"

mkdir results/BEAST/${idname}/
cp $xmlfile results/BEAST/${idname}/
cd results/BEAST/${idname}/

beast $filename
#../../../bin/BEASTv1.10.4/bin/beast $filename

cd ../../../

done
