#!/bin/sh

mkdir data/XMLs/
for fastafile in data/Fasta/*.f*;

do
samp=$(echo $fastafile | sed s/[A-Za-z/._]/""/g)
echo "Processing sample ${samp}"
N=$(cat $fastafile | grep ">" | tr "_" "\t" | cut -f 4 | sort -u)

../../../Bin/BEASTGen_v0.3pre_thorney/bin/beastgen -date_order 4 -date_prefix "_" -D "outputStem=${samp}" code/Make_XML_for_absolute_divergence.template $fastafile data/XMLs/${samp}_AbsRate.xml

done
