echo "Started AutoUpdate.sh at `date`"

###########
#check md5#
###########
export isPlugin=false
export checkFile=Paper-latest.jar
./check-md5.sh
if [ -a sameFile ]; then
    echo "Server is up to date"
else
    mv Paper-latest.jar ${server_path}/
fi

########Plugins##########
echo "Checking Floodgate"
export isPlugin=true
export checkFile=floodgate-spigot.jar
export download_url="https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar"
wget ${download_url}
if [ -a sameFile ]; then
    echo "Skipping..."
else
    mv ${checkFile} ${server_path}/plugins/${checkFile}
fi

echo "Checking Geyser"
export isPlugin=true
export checkFile=Geyser-Spigot.jar
export download_url="https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar"
wget ${download_url}
if [ -a sameFile ]; then
    echo "${checkFile} is up to date"
else
    cp ${checkFile} ${server_path}/plugins/${checkFile}
fi
########OpenJDK##########
if [[ $(sudo apt install 2>/dev/null) ]]; then
    echo 'Updating apt' && sudo apt -y full-upgrade
elif [[ $(sudo pacman -h 2>/dev/null) ]]; then
    echo 'Updating pacman' && sudo pacman --noconfirm -Syu
elif [[ $(sudo dnf install 2>/dev/null) ]]; then
    echo 'Updating dnf' && sudo dnf -y dnf update
fi








echo '''
          ####     #######    ##     ##   ##   ####    ##   ##    ####
           ##       ##   #   ####    ###  ##    ##     ###  ##   ##  ##
  ####     ##       ## #    ##  ##   #### ##    ##     #### ##  ##
 ##  ##    ##       ####    ##  ##   ## ####    ##     ## ####  ##
 ##        ##   #   ## #    ######   ##  ###    ##     ##  ###  ##  ###
 ##  ##    ##  ##   ##   #  ##  ##   ##   ##    ##     ##   ##   ##  ##    ##       ##       ##
  ####    #######  #######  ##  ##   ##   ##   ####    ##   ##    #####    ##       ##       ##



'''
unset isPlugin
unset checkFile
unset download_url
echo "Done at `date`"
