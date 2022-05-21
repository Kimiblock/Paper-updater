echo 'Type your Paper version:'
read version
echo 'Type server path'
read server_path
#Uncomment and set your desired value
#export version=1.18.2
#export server_path=/mnt/main/Cache/Paper
logFile=`date`.log
echo "Started at `date`"
./download-paper.sh >> ${logFile}
unset build
echo "Done at `date`"
