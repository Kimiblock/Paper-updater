export version=1.18.2
export serverPath=/mnt/main/Cache/Paper
echo "Hello! `whoami`"

######Function Start######
#moveFile
function update(){
    if [ $@ = Paper-latest.jar ]; then
        mv Paper-latest.jar $serverPath
    else
        mv $@ ${serverPath}/plugins/
    fi
}

#versionCompare
function versionCompare(){
    if [ ${isPlugin} = true ]; then
        checkPath="${serverPath}/plugins"
    else
        checkPath="${serverPath}"
    fi

    if [ "(md5sum ${checkPath}/${checkFile})" = "(md5sum ${checkFile})" ]; then
        export same=1
        echo "${checkFile} checked, you're up to date."
    else
        export same=0
        echo "${checkFile} checked, updates are available."
    fi
}

#pluginUpdate
function pluginUpdate(){
    if [ $@ = Floodgate ]; then
        export pluginName=Floodgate
        export url="https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar"
    elif [ $@ = Geyser ]; then
        export pluginName=Geyser
        export url="https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar"
    else
        echo "Sorry, but we don't have your plugin's download url. Please wait for support~"
    fi

    wget $url
    export isPlugin=true
    export checkFile="${pluginName}"
}

######Function End######

######Paper Update Start######
echo "Starting auto update for PaperMC, SAC and GeyserMC at `date`"
export build=700
cd ${serverPath}/Update/
echo "Starting download at `date`"
while [ ! -f paper-*.jar ]; do
    export build=`expr ${build} - 1`
    echo "Testing build ${build}"
    wget https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar
    if [ -f paper-*.jar ]; do
        mv paper-*.jar Paper-latest.jar
    fi
done
export isPlugin=false
export checkFile=Paper-latest.jar
versionCompare
if [ $same = 1 ]; then
    rm Paper-latest.jar
else
    update Paper-latest.jar
fi
######Paper Update End######

######Plugin Update Start######
pluginUpdate Geyser
versionCompare
update *.jar

pluginUpdate Floodgate
versionCompare
update *.jar
######Plugin Update End######

######System Update Start######
echo "Notice: Script will try to do a full system update"
if [[ `whoami` = root ]]; then
    if [[ $(sudo apt install 2>/dev/null) ]]; then
        echo 'Detected apt' && sudo apt -y full-upgrade
    elif [[ $(sudo pacman -h 2>/dev/null) ]]; then
        echo 'Detected pacman' && sudo pacman --noconfirm -Syu
    elif [[ $(sudo dnf install 2>/dev/null) ]]; then
        echo 'Detected dnf' && sudo dnf -y dnf update
    fi
else
    echo "Update Failed! You are running under `whoami`"
fi
######System Update End######

######Clean Environment Variables Start######
unset version
unset serverPath
unset checkPath
unset isPlugin
rm -r *.jar
######Clean Environment Variables End######
