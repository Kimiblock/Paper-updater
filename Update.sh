#!/bin/bash
######User Settings Start######
#export version=1.18.2
#export serverPath=/mnt/main/Cache/Paper
######User Settings End######

echo "Hello! `whoami` at `date`"
echo "Reading settings"

######Function Start######
#testPackageManager
function detectPackageManager(){
    if [[ $(sudo apt install 2>/dev/null) ]]; then
        echo 'Detected apt'
        return apt
    elif [[ $(sudo pacman -h 2>/dev/null) ]]; then
        echo 'Detected pacman'
        return pacman
    elif [[ $(sudo dnf install 2>/dev/null) ]]; then
        echo 'Detected dnf'
        return dnf
    else
        return unknown
    fi
}
#checkConfig
checkConfig(){
    if [ ! ${version} ]; then
        echo '$version not set, default to 1.18.2...'
        export version=1.18.2
    fi
    if [ ! ${serverPath} ]; then
        echo "Warning! serverPath not set, exiting..."
        exit 1
    fi
}
#removeJarFile
function clean(){
    if [ -f *.jar ]; then
        rm -rf *.jar
    fi
}
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
    if [ $isPlugin = true ]; then
        checkPath="${serverPath}/plugins"
    else
        checkPath="${serverPath}"
    fi
    diff -q '${checkPath}/${checkFile}' '${checkFile}'
    return $?
}
#integrityProtect
function integrityProtect(){
    if [ ${isPlugin} = false ]; then
        checkFile=Paper-latest.jar
        wget $url
        mv paper-*.*.*.jar Paper-latest.jar.check
        diff -q Paper-latest.jar.check Paper-latest.jar
        return $?
    else
        mv $checkFile ${checkFile.check}
        wget $url
        diff -q $checkFile ${checkFile.check}
    fi
    if [ $? = 1 ]; then
        redownload
    fi
}
function redownload(){
    if [ ${isPlugin} = false ]; then
        clean
        checkFile=Paper-latest.jar
        wget $url
        mv paper-*.*.*.jar Paper-latest.jar
        integrityProtect
    else
        clean
        wget $url
        integrityProtect
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
checkConfig
echo "Starting auto update for PaperMC, SAC and GeyserMC at `date`"
export build=700
cd ${serverPath}/Update/
echo "Starting download at `date`"
while [ ! -f paper-*.jar ]; do
    export build=`expr ${build} - 1`
    echo "Testing build ${build}"
    url="https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar"
    wget $url
done
if [ -f paper-*.jar ]; then
    mv paper-*.jar Paper-latest.jar
fi
export isPlugin=false
export checkFile=Paper-latest.jar
integrityProtect
versionCompare
if [ $? = 0 ]; then
    rm Paper-latest.jar
else
    update Paper-latest.jar
fi
clean
######Paper Update End######

######Plugin Update Start######
export isPlugin=true
pluginUpdate Geyser
export checkFile='Geyser-Spigot.jar'
integrityProtect
versionCompare
update *.jar
clean

export isPlugin=true
export checkFile='floodgate-spigot.jar'
pluginUpdate Floodgate
versionCompare
update *.jar
clean
######Plugin Update End######

######System Update Start######
echo "Notice: Script will try to do a full system update"
if [[ `whoami` = root ]]; then
    detectPackageManager
    if [ $? = "apt" ]; then
        apt -y full-upgrade
    elif [ $? = "dnf" ]; then
        dnf -y dnf update
    elif [ $? = "pacman" ]; then
        pacman --noconfirm -Syyu
    else
        unset packageManager
        echo "Package Manager not found! Enter command to update or type 'skip' to skip"
        read packageManager
        if [ ! ${packageManager} = "skip" ]; then
            $packageManager
        else
            echo "Skipping"
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
unset packageManager
unset checkFile
clean
######Clean Environment Variables End######

exit 0
