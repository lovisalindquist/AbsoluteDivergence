#!/bin/sh

mkdir data/XMLs/
for fastafile in data/Fasta/*.f*;

do
samp=$(echo $fastafile | sed s/[A-Za-z/._]/""/g)
echo "Processing sample ${samp}"

java -jar bin/beastgen.jar -date_order 3 -date_prefix "_" -D "outputStem=${samp}" code/Make_XML_for_absolute_divergence.template $fastafile data/XMLs/${samp}_AbsRate.xml

done
