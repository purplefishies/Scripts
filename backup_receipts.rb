#!/usr/bin/env ruby 

#
# 
#
if [[ ! -d $PRE_RECEIPTS_DIRECTORY ]] ; then
    pre_receipt_dir=$HOME/Projects/org/PreReceipts
else
    pre_receipt_dir=$PRE_RECEIPTS_DIRECTORY
fi


if [[ ! -d $RECEIPTS_DIRECTORY ]] ; then
    receipt_dir=$HOME/Projects/org/receipts
else
    receipt_dir=$RECEIPTS_DIRECTORY
fi

if [[ ! -f $PRE_RECEIPTS_FILE ]] ; then
    pre_receipt_file=$HOME/Projects/org/prereceipt.org
else
    pre_receipt_file=$PRE_RECEIPTS_FILE
fi


for i in $(ls $pre_receipt_dir/*.eml)
do
    entry=$(echo $i | perl -ne 's/.*receipt-(.*?)\.eml$/$1/g;s/-/ /g;print;');
    #/bin/cp -f "$i" ${receipt_dir}//;
    reffile=$(gvfs-ls -u ${final_receipts_dir} | grep "$(basename $i)");
    amount=$(echo $i | perl -ne 's/^.*a-(\d+).*$/$1/;print sprintf "%.2f",$_ * 0.01;')
    to=$(echo $i | perl -ne 's/^.*t-(\S+)\.eml$/$1/;tr/-/ /;print $_')

    echo -ne "\n* TODO ${entry}\n\n  - $reffile\n\n" >> ${pre_receipt_file} 
    echo -ne "#+begin_src ledger\n" >> ${pre_receipt_file}
    echo -ne "${DATE} * ${TO}\n" >> ${pre_receipt_file}


    elements=$(munpack $(basename $i))
    IFS=$(echo -ne "\n\b")
    counter=""
    for j in $elements
    do
        file=$(echo $j | perl -ane 'print "$F[0]\n";')
        extension="${file##*.}"
        filename="${file%.*}"
        nfile="${filename}_$(sha1sum $file | perl -pne 's/^(.{8}).*/$1/;').${extension}"
        mv $file $nfile
        rm ${filename}.desc
        urifile=$(gvfs-ls -u . | grep $nfile)
        #echo -ne "  - ${urifile}\n\n" >> $HOME/Projects/org/todo.org ;
        echo -ne "    ; receipt${counter}: " >> ${pre_receipt_file}
        counter=counter=$((counter+1))
    done
    echo -ne "    ${FROM}    ${AMOUNT}\n" >> ${pre_receipt_file}
    echo -ne "    ${TO}\n" >> ${pre_receipt_file}
    echo -ne "#+end_src\n\n" >> ${pre_receipt_file}


    /usr/local/bin/trash "$i"
done
