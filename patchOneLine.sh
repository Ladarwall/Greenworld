#!/bin/bash
# patchOneLine.sh *fasta to patch*

### to change sequence on multiple lines to sequence on one line ###

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < $1 > doomed
rm $1
mv doomed $1

# to remove a possible empty first line

line=$(sed -n 1p $1)
if [ "$line" == "" ];then

	echo "The first line of the patched file was empty, it has been removed."
	sed -i '1d' $1

fi

echo ""
echo "Success, the file $1 has been one lined."
echo "Don't forget to check if the first line of your fasta is not an empty line !"
echo "(in which case it is necessary to delete it for reads2snp)"
echo "See you at the next 'multi-line sequences' fasta file."
echo ""
