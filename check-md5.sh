echo "Started check-md5.sh at `date`"
echo "Comparing version..."
if [ ${isPlugin} = true ]; then
    export check_path="${server_path}/plugins"
else
    export check_path="${server_path}"
fi

if [ "(md5sum ${check_path}/${checkFile})" = "(md5sum ${checkFile})" ]; then
    export sameFile=1
    touch sameFile 2> /dev/null
    echo "${checkFile} checked, you're up to date."
else
    export sameFile=0
    rm sameFile 2> /dev/null
    echo "${checkFile} checked, patching server..."
fi
echo "Tested ${checkFile}"
