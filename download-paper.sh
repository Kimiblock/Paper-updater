echo "Started at `date`"
if [ ${build} ]; then
    echo "Loaded build list"
else
    export build=900
fi

cd ${server_path}/Update/
echo "Started download-paper.sh at `date`"
echo "Testing build ${build}"
wget https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar >> /dev/null
if [ -f *.jar ]; then
    mv paper*.jar Paper-latest.jar
    echo 'Downloaded Paper'
    export again=0
else
    export build=`expr ${build} - 1`
    export again=1
fi
######loop#######

if [ ${again} = 0 ]; then
    unset build
    ./AutoUpdate.sh
    echo "Ready to pull AutoUpdate.sh"
else
    cd ${server_path}/Update/
    ./download-paper.sh
fi
